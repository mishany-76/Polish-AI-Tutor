import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/ai_client/ai_client.dart';
import '../../core/di/providers.dart';
import '../../core/settings/app_settings.dart';
import 'drill_progress_service.dart';
import 'quiz_builders.dart';

/// Универсальный экран викторины для всех трёх режимов тренажёра.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    super.key,
    required this.title,
    required this.questions,
    this.category,
    this.onGenerateNextRound,
    this.onResetCategory,
  });

  final String title;
  final List<QuizQuestion> questions;
  final String? category;
  final Future<List<QuizQuestion>> Function()? onGenerateNextRound;
  final VoidCallback? onResetCategory;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late List<QuizQuestion> _currentQuestions;
  int _round = 1;
  int _index = 0;
  int _score = 0;
  int? _picked;
  bool _ttsFailed = false;
  bool _showTranslation = false;
  bool _translating = false;
  String? _cachedTranslation;

  QuizQuestion get _q => _currentQuestions[_index];
  bool get _finished => _index >= _currentQuestions.length;

  @override
  void initState() {
    super.initState();
    _currentQuestions = widget.questions;
    WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
    AchievementService.instance.increment('quiz_rounds_done');
    if (widget.category != null) {
      AchievementService.instance.increment('drills_used');
    }
  }

  @override
  void dispose() {
    ref.read(ttsProvider).stop();
    super.dispose();
  }

  Future<void> _speak() async {
    if (_currentQuestions.isEmpty) return;
    final text = _finished ? null : _q.speakText;
    if (text == null) return;
    final ok = await ref.read(ttsProvider).speak(text);
    if (!ok && mounted && !_ttsFailed) {
      setState(() => _ttsFailed = true);
    }
  }

  static final Map<String, String> _aiTranslationCache = {};

  Future<void> _toggleTranslation() async {
    if (_showTranslation) {
      setState(() => _showTranslation = false);
      return;
    }

    final rawText = _q.speakText ??
        _q.prompt.replaceAll('___', _q.options[_q.correctIndex]);
    final cleanText = rawText.replaceAll(RegExp(r'^[🎧🔊\s]+'), '').trim();

    if (_cachedTranslation != null) {
      setState(() => _showTranslation = true);
      return;
    }

    final isUk = ref.read(settingsProvider).isUk;
    final targetLang = isUk ? 'Украинский (Українська)' : 'Русский';
    final cacheKey = '${isUk ? "uk" : "ru"}_$cleanText';

    if (_aiTranslationCache.containsKey(cacheKey)) {
      setState(() {
        _cachedTranslation = _aiTranslationCache[cacheKey];
        _showTranslation = true;
      });
      return;
    }

    if (_q.translation != null && _q.translation!.isNotEmpty) {
      setState(() {
        _cachedTranslation = _q.translation;
        _showTranslation = true;
      });
      return;
    }

    setState(() => _translating = true);
    try {
      final prompt =
          'Переведи эту польскую фразу на $targetLang язык максимально точно, естественно и контекстно для человека. Выведи ТОЛЬКО чистый перевод в 1 строку без кавычек и пояснений: $cleanText';
      final response = await ref.read(aiClientProvider).chat(
        [ChatMessage('user', prompt)],
        timeout: const Duration(seconds: 15),
      );
      final cleanTr = response.trim().replaceAll(RegExp(r'^["«]+|["»]+$'), '');
      _aiTranslationCache[cacheKey] = cleanTr;

      if (mounted) {
        setState(() {
          _cachedTranslation = cleanTr;
          _showTranslation = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cachedTranslation = isUk
              ? 'Помилка перекладу ШІ: перевірте підключення до Інтернету'
              : 'Ошибка перевода ИИ: проверьте подключение к Интернету';
          _showTranslation = true;
        });
      }
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  void _pick(int i) {
    if (_picked != null) return;
    final isCorrect = i == _q.correctIndex;
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      _picked = i;
      if (isCorrect) _score++;
    });

    if (widget.category != null && _q.id.isNotEmpty) {
      DrillProgressService.instance.recordAnswer(
        widget.category!,
        _q.id,
        isCorrect,
      );
    }
  }

  void _next() {
    setState(() {
      _index++;
      _picked = null;
      _showTranslation = false;
      _cachedTranslation = null;
      _translating = false;
    });
    _speak();
  }

  Future<void> _startNextRound() async {
    List<QuizQuestion> next;
    if (widget.onGenerateNextRound != null) {
      next = await widget.onGenerateNextRound!();
    } else {
      next = [..._currentQuestions]..shuffle();
    }

    if (!mounted) return;
    setState(() {
      _round++;
      _index = 0;
      _score = 0;
      _picked = null;
      _showTranslation = false;
      _cachedTranslation = null;
      _translating = false;
      _currentQuestions = next;
    });
    if (_currentQuestions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SafeArea(child: _buildTriumphScreen(context)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} (Раунд $_round)'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _finished ? _buildResult(context) : _buildQuestion(context),
        ),
      ),
    );
  }

  Widget _buildTriumphScreen(BuildContext context) {
    final theme = Theme.of(context);
    final isUk = ref.watch(settingsProvider).isUk;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              isUk ? '🎉 Ви опанували всі питання!' : '🎉 Вы освоили все вопросы!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              isUk
                  ? 'Усі питання цієї теми вивчено на відмінно! Ви можете скинути прогрес, щоб потренуватися ще раз.'
                  : 'Все вопросы этой темы выучены на отлично! Вы можете сбросить прогресс, чтобы потренироваться заново.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(260, 52),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () async {
                if (widget.category != null) {
                  await DrillProgressService.instance.resetCategory(widget.category!);
                }
                widget.onResetCategory?.call();
                await _startNextRound();
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                isUk ? 'Скинути прогрес та почати знову' : 'Сбросить прогресс и начать заново',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(isUk ? 'Повернутися на головну' : 'Вернуться на главную'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final total = _currentQuestions.length;
    final theme = Theme.of(context);
    final isUk = ref.watch(settingsProvider).isUk;
    final percent = (total > 0) ? (_score / total * 100).round() : 0;
    final perfect = _score == total;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(perfect ? '🎉' : (_score * 2 >= total ? '👏' : '💪'),
                style: const TextStyle(fontSize: 68)),
            const SizedBox(height: 16),
            Text(
              perfect
                  ? (isUk ? 'Чудово! Бездоганний результат!' : 'Превосходно! Безупречный результат!')
                  : (_score * 2 >= total
                      ? (isUk ? 'Гарна робота!' : 'Хорошая работа!')
                      : (isUk ? 'Продовжуйте тренування!' : 'Продолжайте тренироваться!')),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isUk
                  ? '$_score з $total правильних відповідей ($percent%)'
                  : '$_score из $total правильных ответов ($percent%)',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isUk ? 'Рівень / Раунд $_round завершено' : 'Уровень / Раунд $_round завершен',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(240, 52),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: _startNextRound,
              icon: const Icon(Icons.play_arrow),
              label: Text(
                isUk ? 'Наступний раунд / рівень ▶' : 'Следующий раунд / уровень ▶',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(isUk ? 'Завершити тренування' : 'Завершить тренировку'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final theme = Theme.of(context);
    final isUk = ref.watch(settingsProvider).isUk;
    final q = _q;
    final answered = _picked != null;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: _index / _currentQuestions.length),
        const SizedBox(height: 8),
        Text(
          isUk
              ? 'Питання ${_index + 1} з ${_currentQuestions.length}'
              : 'Вопрос ${_index + 1} из ${_currentQuestions.length}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                q.prompt,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            if (q.speakText != null) ...[
              const SizedBox(width: 4),
              IconButton(
                iconSize: 28,
                tooltip: 'Озвучити польською',
                onPressed: _speak,
                icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
              ),
            ],
            IconButton(
              iconSize: 26,
              tooltip: 'Переклад речення',
              onPressed: _translating ? null : _toggleTranslation,
              icon: _translating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.translate,
                      color: _showTranslation ? theme.colorScheme.primary : null,
                    ),
            ),
          ],
        ),
        if (_showTranslation && _cachedTranslation != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _cachedTranslation!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        if (q.promptSub != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              q.promptSub!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        if (_ttsFailed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Не удалось озвучить: установите польский голос в настройках '
              'Android (Синтез речи).',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        const SizedBox(height: 24),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionButton(
              label: q.options[i],
              state: !answered
                  ? _OptState.idle
                  : i == q.correctIndex
                      ? _OptState.correct
                      : (i == _picked ? _OptState.wrong : _OptState.idle),
              onTap: () => _pick(i),
            ),
          ),
        const SizedBox(height: 16),
        if (answered) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _picked == q.correctIndex
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _picked == q.correctIndex
                    ? Colors.green.withValues(alpha: 0.4)
                    : Colors.amber.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      _picked == q.correctIndex
                          ? (isUk ? '✅ Чудово! Правильна відповідь' : '✅ Отлично! Правильный ответ')
                          : (isUk ? '❌ Не зовсім так' : '❌ Не совсем так'),
                      softWrap: true,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _picked == q.correctIndex
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '➔ ${q.options[q.correctIndex]}',
                        softWrap: true,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 15)),
                    Expanded(
                      child: Text(
                        q.explanation,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _next,
            child: Text(_index + 1 == _currentQuestions.length
                ? (isUk ? 'Підсумок' : 'Результат')
                : (isUk ? 'Далі' : 'Дальше')),
          ),
          const SizedBox(height: 16),
        ],
      ],
    ),
    );
  }
}

enum _OptState { idle, correct, wrong }

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _OptState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _OptState.correct => Colors.green,
      _OptState.wrong => Colors.red,
      _OptState.idle => null,
    };
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: color,
        side: color == null ? null : BorderSide(color: color, width: 2),
        backgroundColor: color?.withValues(alpha: 0.12),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
