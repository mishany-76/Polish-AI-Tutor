import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';

/// «Мой словарь»: все сохранённые слова, поиск и фильтр по статусу изучения.
class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  String _query = '';
  WordStatus? _filter; // null — все

  Future<void> _confirmClearDictionary() async {
    final strings = ref.read(appStringsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                strings.clearDictConfirmTitle,
                softWrap: true,
              ),
            ),
          ],
        ),
        content: Text(strings.clearDictConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(strings.clearBtn),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final count = await ref.read(databaseProvider).deleteAllWords();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.dictClearedSnack(count)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(wordsProvider);
    final strings = ref.watch(appStringsProvider);
    final uk = ref.watch(settingsProvider.select((s) => s.isUk));

    final filterLabels = {
      WordStatus.fresh: strings.filterFresh,
      WordStatus.learning: strings.filterLearning,
      WordStatus.mastered: strings.filterMastered,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.dictTitle),
        actions: [
          IconButton(
            tooltip: strings.clearDictTooltip,
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _confirmClearDictionary,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: strings.searchWordHint,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: ChoiceChip(
                  label: Text(strings.filterAll),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
              ),
              for (final e in filterLabels.entries)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: _filter == e.key,
                    onSelected: (_) => setState(() => _filter = e.key),
                  ),
                ),
            ]),
          ),
          Expanded(
            child: words.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (all) {
                final list = all.where((w) {
                  if (_filter != null && w.status != _filter) return false;
                  if (_query.isEmpty) return true;
                  return w.lemma.contains(_query) ||
                      (w.translationUk ?? '').toLowerCase().contains(_query) ||
                      (w.translationRu ?? '').toLowerCase().contains(_query);
                }).toList();

                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        all.isEmpty
                            ? 'Словарь пуст. Отсканируйте надпись и добавьте слова в колоду.'
                            : 'Ничего не найдено.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => _tile(list[i], uk),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(Word w, bool uk) {
    final icon = switch (w.status) {
      WordStatus.fresh => const Icon(Icons.fiber_new, color: Colors.blue),
      WordStatus.learning => const Icon(Icons.school, color: Colors.orange),
      WordStatus.mastered => const Icon(Icons.check_circle, color: Colors.green),
    };
    return ListTile(
      leading: icon,
      title: Row(children: [
        Flexible(child: Text(w.lemma)),
        if (w.isFalseFriend)
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text('⚠️'),
          ),
      ]),
      subtitle: Text(w.translation(uk) ?? '—'),
      trailing: IconButton(
        icon: const Icon(Icons.volume_up),
        onPressed: () => ref.read(ttsProvider).speak(w.lemma),
      ),
      onTap: () => _showDetail(w, uk),
    );
  }

  void _showDetail(Word w, bool uk) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(w.lemma, style: Theme.of(ctx).textTheme.headlineMedium),
              Text(w.translation(uk) ?? '—',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text([
                if (w.pos != null) w.pos!,
                if (w.gender != null) 'род: ${w.gender}',
                'интервал: ${w.intervalDays} дн.',
                'повторов: ${w.reps}',
              ].join(' · ')),
              if (w.isFalseFriend)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('⚠️ Ложный друг'),
                ),
              if (w.examplePl != null) ...[
                const SizedBox(height: 12),
                Text('«${w.examplePl}»'),
                if (w.exampleTr != null) Text(w.exampleTr!),
              ],
              if (w.note != null) ...[
                const SizedBox(height: 12),
                Text(w.note!),
              ],
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  await ref.read(databaseProvider).deleteWord(w.id);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Удалить из словаря'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
