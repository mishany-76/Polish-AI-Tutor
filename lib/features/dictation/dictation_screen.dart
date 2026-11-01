import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../review/drill_progress_service.dart';
import '../scanner/translation_service.dart';
import 'dictation_item.dart';
import 'dictation_service.dart';

/// Экран тренировки «Режим Диктант» (Active Recall Speller) с 3 уровнями сложности.
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
  DictationDifficulty _difficulty = DictationDifficulty.veryEasy;
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

  List<String> _currentLetterTiles = [];
  bool _isPeeking = false;
  Timer? _peekTimer;

  static const String _prefDifficultyKey = 'dictation_difficulty_level';

  DictationItem? get _currentItem {
    if (_items.isEmpty || _currentIndex >= _items.length) return null;
    return _items[_currentIndex];
  }

  void _updateLetterTiles() {
    final item = _currentItem;
    if (item == null) {
      _currentLetterTiles = [];
    } else {
      _currentLetterTiles = _generateLetterBank(item.word, _difficulty);
    }
  }

  static List<String> _generateLetterBank(String targetWord, DictationDifficulty difficulty) {
    final clean = targetWord.toLowerCase().trim();
    final wordLetters = <String>[];
    for (int i = 0; i < clean.length; i++) {
      final ch = clean[i];
      if (RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(ch)) {
        wordLetters.add(ch);
      }
    }

    final rnd = Random(targetWord.hashCode);

    // В режиме «Очень легко» даём ТОЛЬКО буквы этого слова — как пазл/анаграмму без лишних ложных букв!
    if (difficulty == DictationDifficulty.veryEasy) {
      final shuffled = [...wordLetters]..shuffle(rnd);
      return shuffled;
    }

    // Добавляем орфографические ловушки/дистракторы
    final distractors = <String>{};
    if (clean.contains('ó')) distractors.add('u');
    if (clean.contains('u')) distractors.add('ó');
    if (clean.contains('rz')) distractors.add('ż');
    if (clean.contains('ż')) distractors.add('z');
    if (clean.contains('ch')) distractors.add('h');
    if (clean.contains('h')) distractors.add('c');
    if (clean.contains('ą')) { distractors.add('ę'); distractors.add('o'); }
    if (clean.contains('ę')) { distractors.add('ą'); distractors.add('e'); }
    if (clean.contains('ś')) { distractors.add('s'); distractors.add('sz'); }
    if (clean.contains('ć')) { distractors.add('c'); distractors.add('cz'); }
    if (clean.contains('ź')) { distractors.add('z'); distractors.add('ż'); }
    if (clean.contains('ł')) distractors.add('l');
    if (clean.contains('ń')) distractors.add('n');

    const pool = [
      'a', 'e', 'i', 'o', 'k', 'm', 'n', 'p', 'r', 's', 't', 'w', 'y', 'z',
      'ą', 'ę', 'ł', 'ń', 'ó', 'ś', 'ź', 'ż'
    ];

    final maxDistractors = difficulty == DictationDifficulty.easy ? 2 : 5;
    final shuffledPool = [...pool]..shuffle(rnd);
    for (final ch in shuffledPool) {
      if (distractors.length >= maxDistractors) break;
      if (!wordLetters.contains(ch)) {
        distractors.add(ch);
      }
    }

    final selectedDistractors = distractors.take(maxDistractors).toList();
    final combined = [...wordLetters, ...selectedDistractors]..shuffle(rnd);
    return combined;
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _loadDifficultyAndRound();
    AchievementService.instance.increment('drills_used');
  }

  Future<void> _loadDifficultyAndRound() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDiff = prefs.getString(_prefDifficultyKey);
      if (savedDiff == 'hard') {
        _difficulty = DictationDifficulty.hard;
      } else if (savedDiff == 'easy') {
        _difficulty = DictationDifficulty.easy;
      } else {
        _difficulty = DictationDifficulty.veryEasy;
      }
      if (_difficulty == DictationDifficulty.veryEasy) {
        _isSlowSpeed = true;
      }
    } catch (_) {}
    _loadRound();
  }

  Future<void> _changeDifficulty(DictationDifficulty newDiff) async {
    if (_difficulty == newDiff) return;
    setState(() {
      _difficulty = newDiff;
      if (newDiff == DictationDifficulty.veryEasy) {
        _isSlowSpeed = true;
      }
      _updateLetterTiles();
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = switch (newDiff) {
        DictationDifficulty.veryEasy => 'veryEasy',
        DictationDifficulty.easy => 'easy',
        DictationDifficulty.hard => 'hard',
      };
      await prefs.setString(_prefDifficultyKey, str);
    } catch (_) {}
  }

  @override
  void dispose() {
    _peekTimer?.cancel();
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
      _isPeeking = false;
      _textController.clear();
    });

    final service = ref.read(dictationServiceProvider);
    final items = await service.buildRound(mode: _mode, count: 8);

    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
        _updateLetterTiles();
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

  void _onLetterTileTap(String char) {
    if (_isAnswerChecked) return;
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
    setState(() {});
  }

  void _onBackspaceTap() {
    if (_isAnswerChecked) return;
    HapticFeedback.lightImpact();
    final text = _textController.text;
    if (text.isEmpty) return;
    final selection = _textController.selection;
    if (selection.start > 0 && selection.start == selection.end) {
      final newText = text.replaceRange(selection.start - 1, selection.start, '');
      final newPosition = selection.start - 1;
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newPosition),
      );
    } else if (selection.start >= 0 && selection.end > selection.start) {
      final newText = text.replaceRange(selection.start, selection.end, '');
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
    } else {
      _textController.text = text.substring(0, text.length - 1);
      _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
    }
    setState(() {});
  }

  void _onSlotTap(int index) {
    if (_isAnswerChecked) return;
    HapticFeedback.selectionClick();
    final text = _textController.text;
    if (index < text.length) {
      _textController.text = text.substring(0, index);
      _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
      setState(() {});
    }
  }

  void _triggerPeekWord() {
    if (_isPeeking || _isAnswerChecked) return;
    HapticFeedback.mediumImpact();
    setState(() => _isPeeking = true);
    _peekTimer?.cancel();
    _peekTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() => _isPeeking = false);
      }
    });
  }

  void _hintNextLetter() {
    final item = _currentItem;
    if (item == null || _isAnswerChecked) return;
    HapticFeedback.lightImpact();

    final target = item.word.toLowerCase();
    final current = _textController.text.toLowerCase();

    if (current.isEmpty) {
      _textController.text = target[0];
    } else if (target.startsWith(current) && current.length < target.length) {
      _textController.text = target.substring(0, current.length + 1);
    } else {
      // Найдена ошибка — сбрасываем до правильного префикса и добавляем следующую букву
      int matchLen = 0;
      for (int i = 0; i < current.length && i < target.length; i++) {
        if (current[i] == target[i]) {
          matchLen = i + 1;
        } else {
          break;
        }
      }
      _textController.text = target.substring(0, (matchLen + 1).clamp(1, target.length));
    }
    _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
    setState(() {});
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
    _peekTimer?.cancel();
    if (_currentIndex + 1 >= _items.length) {
      AchievementService.instance.increment('quiz_rounds_done');
      _showRoundCompletedDialog();
      return;
    }

    setState(() {
      _currentIndex++;
      _isAnswerChecked = false;
      _isLastAnswerCorrect = false;
      _isPeeking = false;
      _detectedMistakeTip = null;
      _userSubmittedText = '';
      _textController.clear();
      _updateLetterTiles();
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
          preferredSize: const Size.fromHeight(88),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ВЕРХНИЙ РЯД: ВЫБОР РЕЖИМА И ПРОГРЕСС
                Row(
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
                const SizedBox(height: 4),

                // НИЖНИЙ РЯД: 3 УРОВНЯ СЛОЖНОСТИ (ОЧЕНЬ ЛЕГКО / ЛЕГКО / ТРУДНО)
                Row(
                  children: [
                    for (final diff in DictationDifficulty.values)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            onTap: () => _changeDifficulty(diff),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _difficulty == diff
                                    ? (diff == DictationDifficulty.veryEasy
                                        ? Colors.green.shade100
                                        : (diff == DictationDifficulty.easy
                                            ? Colors.amber.shade100
                                            : Colors.red.shade100))
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _difficulty == diff
                                      ? (diff == DictationDifficulty.veryEasy
                                          ? Colors.green.shade600
                                          : (diff == DictationDifficulty.easy
                                              ? Colors.amber.shade700
                                              : Colors.red.shade600))
                                      : Colors.grey.shade300,
                                  width: _difficulty == diff ? 1.5 : 1.0,
                                ),
                              ),
                              child: Text(
                                diff == DictationDifficulty.veryEasy
                                    ? strings.dictationDiffVeryEasy
                                    : (diff == DictationDifficulty.easy
                                        ? strings.dictationDiffEasy
                                        : strings.dictationDiffHard),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: _difficulty == diff ? FontWeight.bold : FontWeight.w500,
                                  color: _difficulty == diff ? Colors.black87 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ВСПЛЫВАЮЩАЯ ПОДСКАЗКА ПОДГЛЯДЫВАНИЯ СЛОВА (ДЛЯ ОЧЕНЬ ЛЕГКОГО РЕЖИМА)
          if (_isPeeking)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.visibility_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    item.word,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          // КАРТОЧКА С ДИНАМИКОМ И СКОРОСТЬЮ
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                    width: 80,
                    height: 80,
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
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

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
                const SizedBox(height: 10),

                // Подсказка значения слова (перевод)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${strings.dictationMeaningLabel} ',
                      style: TextStyle(
                        fontSize: 13.5,
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
          const SizedBox(height: 14),

          // ПОЛЕ ВВОДА + ВИЗУАЛЬНЫЕ СЛОТЫ БУКВ (ДЛЯ СЛОЖНОСТИ VERY EASY И EASY)
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
                // Шапка поля ввода с индикатором длины слова
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _difficulty == DictationDifficulty.veryEasy
                          ? strings.dictationSlotsHint
                          : strings.dictationListenHint,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        strings.dictationWordLength(item.word.length),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ИНТЕРАКТИВНЫЕ СЛОТЫ БУКВ
                if (_difficulty != DictationDifficulty.hard) ...[
                  _buildLetterSlots(item.word, _textController.text),
                  const SizedBox(height: 12),
                ],

                // ТЕКСТОВОЕ ПОЛЕ ВВОДА
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
                            onPressed: () {
                              _textController.clear();
                              setState(() {});
                            },
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
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),

                // ПАНЕЛЬ ДЕЙСТВИЙ: ПОДГЛЯДЕТЬ / ПОДСКАЗКА / СТЕРЕТЬ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_difficulty == DictationDifficulty.veryEasy)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade800,
                          side: BorderSide(color: Colors.green.shade400),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: _isAnswerChecked ? null : _triggerPeekWord,
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: Text(strings.dictationPeekBtn, style: const TextStyle(fontSize: 12)),
                      )
                    else if (_difficulty == DictationDifficulty.easy)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber.shade900,
                          side: BorderSide(color: Colors.amber.shade500),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: _isAnswerChecked ? null : _hintNextLetter,
                        icon: const Icon(Icons.lightbulb_outline, size: 16),
                        label: Text(strings.dictationHintBtn, style: const TextStyle(fontSize: 12)),
                      )
                    else
                      Text(
                        strings.dictationLetterBankLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    if (!_isAnswerChecked && _textController.text.isNotEmpty)
                      InkWell(
                        onTap: _onBackspaceTap,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.backspace_outlined, size: 16, color: AppTheme.primaryCarmine),
                              const SizedBox(width: 4),
                              Text(
                                strings.dictationBackspace,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryCarmine,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // КАССЕТНИЦА БУКВ ДЛЯ СОСТАВЛЕНИЯ СЛОВА
                if (_currentLetterTiles.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        for (int i = 0; i < _currentLetterTiles.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: _isAnswerChecked
                                  ? null
                                  : () => _onLetterTileTap(_currentLetterTiles[i]),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppTheme.bgWarmMilk,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300, width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _currentLetterTiles[i],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          _userSubmittedText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],

                  Row(
                    children: [
                      Text(
                        '${strings.dictationCorrectWordLabel} ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        item.word,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCarmine,
                        ),
                      ),
                    ],
                  ),

                  // Подсказка правила орфографии
                  if (_detectedMistakeTip != null || item.rule(lang).isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb, size: 18, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _detectedMistakeTip ?? item.rule(lang),
                              style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Пример предложения
                  if (item.examplePl != null && item.examplePl!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${strings.dictationExampleLabel} ${item.examplePl}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryCarmine,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _nextWord,
              child: Text(
                strings.dictationNextBtn,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Визуальные слоты для сборки слова как пазла
  Widget _buildLetterSlots(String targetWord, String currentInput) {
    final clean = targetWord.trim();
    final inputLen = currentInput.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < clean.length; i++) ...[
            InkWell(
              onTap: () => _onSlotTap(i),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i < inputLen
                      ? AppTheme.primaryCarmine.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: i < inputLen
                        ? AppTheme.primaryCarmine
                        : (i == inputLen ? Colors.amber.shade700 : Colors.grey.shade300),
                    width: i == inputLen ? 2 : 1.2,
                  ),
                ),
                child: Text(
                  i < inputLen ? currentInput[i] : (i == inputLen ? '|' : '_'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: i < inputLen
                        ? AppTheme.primaryCarmine
                        : (i == inputLen ? Colors.amber.shade800 : Colors.grey.shade400),
                  ),
                ),
              ),
            ),
            if (i < clean.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}
