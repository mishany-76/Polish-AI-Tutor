import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/db/app_database.dart';
import '../../core/di/providers.dart';
import '../../core/settings/app_settings.dart';
import '../../core/srs/sm2.dart';

/// Повторение просроченных слов по SM-2: показать ответ → оценить 1–4.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  List<Word>? _queue;
  int _i = 0;
  bool _revealed = false;
  int _done = 0;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(q == null || _i >= q.length
            ? 'Повторение'
            : 'Повторение · осталось ${q.length - _i}'),
      ),
      body: SafeArea(
        child: q == null
            ? const Center(child: CircularProgressIndicator())
            : (_i >= q.length ? _buildDone(context) : _buildCard(context, q[_i])),
      ),
    );
  }

  Widget _buildDone(BuildContext context) {
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
                  ? 'На сегодня повторять нечего'
                  : 'Готово! Повторено слов: $_done',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Word w) {
    final theme = Theme.of(context);
    final uk = ref.watch(settingsProvider.select((s) => s.isUk));
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Card(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(w.lemma,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.displaySmall),
                          ),
                          IconButton(
                            onPressed: () =>
                                ref.read(ttsProvider).speak(w.lemma),
                            icon: const Icon(Icons.volume_up),
                          ),
                        ],
                      ),
                      if (_revealed) ...[
                        const SizedBox(height: 16),
                        Text(w.translation(uk) ?? '— перевод не задан —',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall),
                        if (w.isFalseFriend)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('⚠️ Ложный друг'),
                          ),
                        if (w.examplePl != null) ...[
                          const SizedBox(height: 16),
                          Text('«${w.examplePl}»', textAlign: TextAlign.center),
                          if (w.exampleTr != null)
                            Text(w.exampleTr!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall),
                        ],
                        if (w.note != null) ...[
                          const SizedBox(height: 12),
                          Text(w.note!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!_revealed)
            FilledButton(
              onPressed: () => setState(() => _revealed = true),
              child: const Text('Показать ответ'),
            )
          else
            Row(children: [
              for (final (r, label) in const [
                (1, 'Снова'),
                (2, 'Трудно'),
                (3, 'Хорошо'),
                (4, 'Легко'),
              ])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: FilledButton.tonal(
                      onPressed: () => _rate(w, r),
                      child: Text(label, maxLines: 1),
                    ),
                  ),
                ),
            ]),
        ],
      ),
    );
  }
}

