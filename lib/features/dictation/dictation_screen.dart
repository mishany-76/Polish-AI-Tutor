import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../review/drill_progress_service.dart';
import '../scanner/translation_service.dart';
import 'dictation_item.dart';
import 'dictation_service.dart';

/// Экран тренировки «Режим Диктант» (Active Recall Speller).
class DictationScreen extends ConsumerStatefulWidget {
  const DictationScreen({
    super.key,
    this.initialMode = DictationMode.traps,
  });

  final DictationMode initialMode;

  static Future<void> show(BuildContext context, {DictationMode mode = DictationMode.traps}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DictationScreen(initialMode: mode),
      ),
    );
  }

  @override
  ConsumerState<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends ConsumerState<DictationScreen> {
  late DictationMode _mode;
  List<DictationItem> _items = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int _correctCount = 0;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSlowSpeed = false;
  bool _isAnswerChecked = false;
  bool _isLastAnswerCorrect = false;
  String _userSubmittedText = '';
  String? _detectedMistakeTip;

  static const List<String> _polishDiacritics = [
    'ą', 'ć', 'ę', 'ł', 'ń', 'ó', 'ś', 'ź', 'ż',
  ];

  DictationItem? get _currentItem {
    if (_items.isEmpty || _currentIndex >= _items.length) return null;
    return _items[_currentIndex];
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _loadRound();
    AchievementService.instance.increment('drills_used');
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    ref.read(ttsProvider).stop();
    super.dispose();
  }

  Future<void> _loadRound() async {
    setState(() {
      _isLoading = true;
      _items = [];
      _currentIndex = 0;
      _correctCount = 0;
      _isAnswerChecked = false;
      _textController.clear();
    });

    final service = ref.read(dictationServiceProvider);
    final items = await service.buildRound(mode: _mode, count: 8);

    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
      if (items.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _speakCurrent();
          _focusNode.requestFocus();
        });
      }
    }
  }

  Future<void> _speakCurrent({bool? slow}) async {
    final item = _currentItem;
    if (item == null) return;
    final rate = (slow ?? _isSlowSpeed) ? 0.28 : 0.45;
    await ref.read(ttsProvider).speak(item.word, rate: rate);
  }

  void _insertDiacritic(String char) {
    HapticFeedback.lightImpact();
    final text = _textController.text;
    final selection = _textController.selection;

    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, char);
      final newPosition = selection.start + char.length;
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newPosition),
      );
    } else {
      _textController.text = text + char;
      _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
    }
    _focusNode.requestFocus();
  }

  void _checkAnswer() {
    final item = _currentItem;
    if (item == null || _isAnswerChecked) return;

    final userInput = _textController.text.trim();
    if (userInput.isEmpty) return;

    final isCorrect = DictationService.checkAnswer(userInput, item.word);
    final mistakeTip = DictationService.detectOrthographyMistake(userInput, item.word);

    if (isCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    // Сохраняем в адаптивный прогресс
    final category = _mode == DictationMode.myDeck ? 'dictation_deck' : 'dictation';
    DrillProgressService.instance.recordAnswer(category, item.id, isCorrect);

    setState(() {
      _isAnswerChecked = true;
      _isLastAnswerCorrect = isCorrect;
      _userSubmittedText = userInput;
      _detectedMistakeTip = mistakeTip;
      if (isCorrect) {
        _correctCount++;
      }
    });
  }

  void _nextWord() {
    if (_currentIndex + 1 >= _items.length) {
      // Завершение раунда
      AchievementService.instance.increment('quiz_rounds_done');
      _showRoundCompletedDialog();
      return;
    }

    setState(() {
      _currentIndex++;
      _isAnswerChecked = false;
      _isLastAnswerCorrect = false;
      _detectedMistakeTip = null;
      _userSubmittedText = '';
      _textController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrent();
      _focusNode.requestFocus();
    });
  }

  void _showRoundCompletedDialog() {
    final strings = ref.read(appStringsProvider);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(strings.dictationFinishedTitle, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_correctCount / ${_items.length}',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCarmine,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.isPl
                    ? 'Świetny trening ortografii i słuchu!'
                    : (strings.isUk
                        ? 'Чудове тренування орфографії та слуху!'
                        : 'Отличная тренировка орфографии и слуха!'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: Text(strings.isPl ? 'Wyjście' : (strings.isUk ? 'Вихід' : 'Выход')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryCarmine),
              onPressed: () {
                Navigator.of(ctx).pop();
                _loadRound();
              },
              child: Text(strings.dictationNewRoundBtn),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));
    final item = _currentItem;

    return Scaffold(
      backgroundColor: AppTheme.bgWarmMilk,
      appBar: AppBar(
        title: Text(
          strings.drillDictationTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryCarmine,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<DictationMode>(
                  value: _mode,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryCarmine),
                  items: [
                    DropdownMenuItem(
                      value: DictationMode.traps,
                      child: Text(
                        strings.dictationModeTraps,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    DropdownMenuItem(
                      value: DictationMode.myDeck,
                      child: Text(
                        strings.dictationModeDeck,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  onChanged: (newMode) {
                    if (newMode != null && newMode != _mode) {
                      setState(() => _mode = newMode);
                      _loadRound();
                    }
                  },
                ),
                if (!_isLoading && _items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCarmine.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      strings.dictationProgress(_currentIndex + 1, _items.length),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryCarmine,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryCarmine),
            )
          : (_items.isEmpty
              ? _buildEmptyState(strings)
              : _buildActiveExercise(strings, lang, item!)),
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              strings.dictationEmptyDeckNotice,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryCarmine),
              onPressed: () {
                setState(() => _mode = DictationMode.traps);
                _loadRound();
              },
              icon: const Icon(Icons.replay_rounded),
              label: Text(strings.dictationModeTraps),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveExercise(AppStrings strings, UiLang lang, DictationItem item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // КАРТОЧКА С ДИНАМИКОМ И СКОРОСТЬЮ
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [AppTheme.cardShadow],
            ),
            child: Column(
              children: [
                // Большая круглая кнопка воспроизведения
                InkWell(
                  onTap: () => _speakCurrent(),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryCarmine, Color(0xFF8C1D2F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryCarmine.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Переключатели скорости: 1.0x и 0.3x
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilterChip(
                      selected: !_isSlowSpeed,
                      label: Text(strings.dictationNormalBtn),
                      selectedColor: AppTheme.primaryCarmine.withValues(alpha: 0.15),
                      checkmarkColor: AppTheme.primaryCarmine,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: !_isSlowSpeed ? AppTheme.primaryCarmine : Colors.black87,
                      ),
                      onSelected: (val) {
                        setState(() => _isSlowSpeed = false);
                        _speakCurrent(slow: false);
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: _isSlowSpeed,
                      label: Text(strings.dictationSlowBtn),
                      selectedColor: AppTheme.primaryCarmine.withValues(alpha: 0.15),
                      checkmarkColor: AppTheme.primaryCarmine,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isSlowSpeed ? AppTheme.primaryCarmine : Colors.black87,
                      ),
                      onSelected: (val) {
                        setState(() => _isSlowSpeed = true);
                        _speakCurrent(slow: true);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Подсказка значения слова (перевод)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${strings.dictationMeaningLabel} ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        item.translation(lang),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ПОЛЕ ВВОДА
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [AppTheme.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.dictationListenHint,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  enabled: !_isAnswerChecked,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                  decoration: InputDecoration(
                    hintText: strings.dictationInputPlaceholder,
                    prefixIcon: const Icon(Icons.edit_note, color: AppTheme.primaryCarmine),
                    suffixIcon: _textController.text.isNotEmpty && !_isAnswerChecked
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => _textController.clear(),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.primaryCarmine, width: 2),
                    ),
                  ),
                  onSubmitted: (_) => _checkAnswer(),
                ),
                const SizedBox(height: 12),

                // ПАНЕЛЬ БЫСТРЫХ ДИАКРИТИК (ą, ć, ę, ł, ń, ó, ś, ź, ż)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _polishDiacritics.map((char) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: _isAnswerChecked ? null : () => _insertDiacritic(char),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.bgWarmMilk,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              char,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryCarmine,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // КНОПКА ПРОВЕРКИ (если еще не проверено)
          if (!_isAnswerChecked)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryCarmine,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _textController.text.trim().isEmpty ? null : _checkAnswer,
              child: Text(
                strings.dictationCheckBtn,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

          // БЛОК РЕЗУЛЬТАТА И ОРФОГРАФИЧЕСКОГО ПРАВИЛА
          if (_isAnswerChecked) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isLastAnswerCorrect
                    ? Colors.green.shade50
                    : Colors.red.shade50.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isLastAnswerCorrect ? Colors.green.shade300 : Colors.red.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isLastAnswerCorrect
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        color: _isLastAnswerCorrect
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isLastAnswerCorrect
                              ? strings.dictationCorrectTitle
                              : strings.dictationIncorrectTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isLastAnswerCorrect
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),

                  // Сравнение написания
                  if (!_isLastAnswerCorrect) ...[
                    Row(
                      children: [
                        Text(
                          '${strings.dictationYourInputLabel} ',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        ),
                        Text(
                          _userSubmittedText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  Row(
                    children: [
                      Text(
                        '${strings.dictationCorrectWordLabel} ',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      Text(
                        item.word,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCarmine,
                        ),
                      ),
                    ],
                  ),

                  // Подсказка об ошибке (например, rz vs ż)
                  if (_detectedMistakeTip != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _detectedMistakeTip!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown.shade900,
                        ),
                      ),
                    ),
                  ],

                  // Мнемоническое правило
                  if (item.rule(lang).isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      strings.dictationRuleTipLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.rule(lang),
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                    ),
                  ],

                  // Пример в предложении
                  if (item.examplePl != null && item.examplePl!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      strings.dictationExampleLabel,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '„${item.examplePl}”',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Кнопка Следующее слово
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryCarmine,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _nextWord,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                strings.dictationNextBtn,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
