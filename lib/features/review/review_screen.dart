import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/db/app_database.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/srs/sm2.dart';

/// Повторение просроченных слов по SM-2: показать ответ → оценить 1–4.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ReviewScreen(),
      ),
    );
  }

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  List<Word>? _queue;
  int _i = 0;
  bool _revealed = false;
  int _done = 0;
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    ref.read(databaseProvider).dueWords(limit: 20).then((q) {
      if (mounted) setState(() => _queue = q);
    });
  }

  @override
  void dispose() {
    ref.read(ttsProvider).stop();
    super.dispose();
  }

  Future<void> _rate(Word w, int rating) async {
    final prevMastered = w.intervalDays >= 21;
    await ref.read(databaseProvider).applyReview(w, rating);
    final res = sm2(
      ease: w.easeFactor,
      intervalDays: w.intervalDays,
      reps: w.reps,
      lapses: w.lapses,
      rating: rating,
    );
    if (!prevMastered && res.intervalDays >= 21) {
      AchievementService.instance.increment('words_mastered');
    }
    if (!mounted) return;
    setState(() {
      _done++;
      _i++;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _queue;
    final strings = ref.watch(appStringsProvider);
    final isUk = strings.isUk;
    final isPl = strings.isPl;

    String appBarTitle;
    if (q == null || _i >= q.length) {
      appBarTitle = isPl ? 'Powtórka' : (isUk ? 'Повторення' : 'Повторение');
    } else {
      final left = q.length - _i;
      appBarTitle = isPl
          ? 'Powtórka · zostało $left'
          : (isUk ? 'Повторення · залишилось $left' : 'Повторение · осталось $left');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: SafeArea(
        child: q == null
            ? const Center(child: CircularProgressIndicator())
            : (_i >= q.length ? _buildDone(context, isUk, isPl) : _buildCard(context, q[_i], q, isUk, isPl)),
      ),
    );
  }

  Widget _buildDone(BuildContext context, bool isUk, bool isPl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              _done == 0
                  ? (isPl
                      ? 'Brak słów do powtórki na dziś'
                      : (isUk ? 'На сьогодні повторювати нічого' : 'На сегодня повторять нечего'))
                  : (isPl
                      ? 'Gotowe! Powtórzono słów: $_done'
                      : (isUk ? 'Готово! Повторено слів: $_done' : 'Готово! Повторено слов: $_done')),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: Text(isPl ? 'Wróć' : (isUk ? 'Назад' : 'Назад')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Word w, List<Word> q, bool isUk, bool isPl) {
    final theme = Theme.of(context);
    final uk = ref.watch(settingsProvider.select((s) => s.isUk));

    // Рассчитываем точные интервалы SM-2 для текущего слова
    final rHard = sm2(
      ease: w.easeFactor,
      intervalDays: w.intervalDays,
      reps: w.reps,
      lapses: w.lapses,
      rating: 2,
    );
    final rGood = sm2(
      ease: w.easeFactor,
      intervalDays: w.intervalDays,
      reps: w.reps,
      lapses: w.lapses,
      rating: 3,
    );
    final rEasy = sm2(
      ease: w.easeFactor,
      intervalDays: w.intervalDays,
      reps: w.reps,
      lapses: w.lapses,
      rating: 4,
    );

    String formatDays(int days) {
      if (isPl) return '$days d';
      if (isUk) return '$days дн';
      return '$days дн';
    }

    final currentNum = _i + 1;
    final totalCount = q.length;
    final progressValue = currentNum / totalCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Верхний счетчик карточек и прогресс-бар
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPl
                    ? 'Karta $currentNum z $totalCount'
                    : (isUk
                        ? 'Картка $currentNum з $totalCount'
                        : 'Карточка $currentNum из $totalCount'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '${(progressValue * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),

          // 2. Подсказка для новичка (скрываемая)
          if (_showHint) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isPl
                          ? 'Oceń, jak łatwo pamiętasz słowo — algorytm SM-2 wyznaczy optymalny dzień powtórki.'
                          : (isUk
                              ? 'Оцініть, як легко ви згадали слово — алгоритм SM-2 розрахує ідеальний день повторення.'
                              : 'Оцените, как легко вспомнили слово — алгоритм SM-2 рассчитает идеальный день повторения.'),
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade800),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _showHint = false),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // 3. Карточка со словом (с возможностью переворота тапом)
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _revealed ? null : () => setState(() => _revealed = true),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                w.lemma,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () => ref.read(ttsProvider).speak(w.lemma),
                              icon: const Icon(Icons.volume_up),
                            ),
                          ],
                        ),
                        if (!_revealed) ...[
                          const SizedBox(height: 16),
                          Text(
                            isPl
                                ? '(Dotknij karty lub przycisku poniżej, aby odkryć)'
                                : (isUk
                                    ? '(Торкніться картки або кнопки нижче, щоб відкрити)'
                                    : '(Нажмите на карточку или кнопку ниже, чтобы открыть)'),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ] else ...[
                          const SizedBox(height: 14),
                          const Divider(),
                          const SizedBox(height: 10),
                          Text(
                            w.translation(uk) ?? (isUk ? '— переклад не заданий —' : '— перевод не задан —'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (w.isFalseFriend)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isPl
                                      ? '⚠️ Fałszywy przyjaciel'
                                      : (isUk ? '⚠️ Фальшивий друг перекладача' : '⚠️ Ложный друг переводчика'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ),
                          if (w.examplePl != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              '«${w.examplePl}»',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                            ),
                            if (w.exampleTr != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  w.exampleTr!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                              ),
                          ],
                          if (w.note != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              w.note!,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4. Нижняя панель действий
          if (!_revealed)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.visibility),
                label: Text(
                  isPl ? 'Pokaż odpowiedź' : (isUk ? 'Показати відповідь' : 'Показать ответ'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => setState(() => _revealed = true),
              ),
            )
          else
            // 4 цветные плашки в два ряда (2x2) со сроками повторения
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // 1. Снова
                    Expanded(
                      child: _buildRatingButton(
                        title: isPl ? 'Znowu' : (isUk ? 'Знову' : 'Снова'),
                        subtitle: isPl ? '< 10 min' : (isUk ? '< 10 хв' : '< 10 мин'),
                        icon: Icons.replay_rounded,
                        color: Colors.red.shade700,
                        bgColor: Colors.red.withValues(alpha: 0.1),
                        borderColor: Colors.red.withValues(alpha: 0.4),
                        onTap: () => _rate(w, 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 2. Трудно
                    Expanded(
                      child: _buildRatingButton(
                        title: isPl ? 'Trudno' : (isUk ? 'Важко' : 'Трудно'),
                        subtitle: formatDays(rHard.intervalDays),
                        icon: Icons.sentiment_dissatisfied_outlined,
                        color: Colors.orange.shade800,
                        bgColor: Colors.orange.withValues(alpha: 0.1),
                        borderColor: Colors.orange.withValues(alpha: 0.4),
                        onTap: () => _rate(w, 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // 3. Хорошо
                    Expanded(
                      child: _buildRatingButton(
                        title: isPl ? 'Dobrze' : (isUk ? 'Добре' : 'Хорошо'),
                        subtitle: formatDays(rGood.intervalDays),
                        icon: Icons.sentiment_satisfied_outlined,
                        color: Colors.blue.shade700,
                        bgColor: Colors.blue.withValues(alpha: 0.1),
                        borderColor: Colors.blue.withValues(alpha: 0.4),
                        onTap: () => _rate(w, 3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 4. Легко
                    Expanded(
                      child: _buildRatingButton(
                        title: isPl ? 'Łatwo' : (isUk ? 'Легко' : 'Легко'),
                        subtitle: formatDays(rEasy.intervalDays),
                        icon: Icons.sentiment_very_satisfied_outlined,
                        color: Colors.green.shade700,
                        bgColor: Colors.green.withValues(alpha: 0.1),
                        borderColor: Colors.green.withValues(alpha: 0.4),
                        onTap: () => _rate(w, 4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRatingButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
