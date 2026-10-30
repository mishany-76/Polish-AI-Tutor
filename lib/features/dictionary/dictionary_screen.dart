import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../scanner/translation_service.dart' show UiLang;
import '../dictation/dictation_screen.dart';
import '../dictation/dictation_service.dart';
import '../review/review_screen.dart';

import 'export_deck_service.dart';

class _CefrMilestone {
  final String code;
  final String titlePl;
  final String titleUk;
  final String titleRu;
  final int minWords;
  final int maxWords;
  final Color color;

  const _CefrMilestone({
    required this.code,
    required this.titlePl,
    required this.titleUk,
    required this.titleRu,
    required this.minWords,
    required this.maxWords,
    required this.color,
  });

  String title(UiLang lang) {
    switch (lang) {
      case UiLang.pl:
        return titlePl;
      case UiLang.uk:
        return titleUk;
      case UiLang.ru:
        return titleRu;
    }
  }
}

const _kCefrMilestones = [
  _CefrMilestone(
    code: 'A0',
    titlePl: 'Absolutny początkujący',
    titleUk: 'Початківець (Буквар)',
    titleRu: 'Абсолютный новичок (Букварь)',
    minWords: 0,
    maxWords: 500,
    color: Color(0xFF78909C),
  ),
  _CefrMilestone(
    code: 'A1',
    titlePl: 'Poziom podstawowy (przetrwanie)',
    titleUk: 'Базовий (побут і виживання)',
    titleRu: 'Базовый (быт и выживание)',
    minWords: 500,
    maxWords: 1500,
    color: Color(0xFF43A047),
  ),
  _CefrMilestone(
    code: 'A2',
    titlePl: 'Podstawowy komunikatywny',
    titleUk: 'Комунікативний (щоденне спілкування)',
    titleRu: 'Коммуникативный (повседневное общение)',
    minWords: 1500,
    maxWords: 3000,
    color: Color(0xFF1E88E5),
  ),
  _CefrMilestone(
    code: 'B1',
    titlePl: 'Średniozaawansowany (samodzielność)',
    titleUk: 'Самостійний (робота і соціум)',
    titleRu: 'Самостоятельный (работа и социум)',
    minWords: 3000,
    maxWords: 4500,
    color: Color(0xFFFB8C00),
  ),
  _CefrMilestone(
    code: 'B2',
    titlePl: 'Średni wyższy (biegłość zawodowa)',
    titleUk: 'Вільний робочий (професійне володіння)',
    titleRu: 'Свободный рабочий (профессиональное владение)',
    minWords: 4500,
    maxWords: 6000,
    color: Color(0xFF8E24AA),
  ),
  _CefrMilestone(
    code: 'C1',
    titlePl: 'Zaawansowany (biegłość akademicka)',
    titleUk: 'Просунутий (повна вільність)',
    titleRu: 'Продвинутый (полная беглость)',
    minWords: 6000,
    maxWords: -1,
    color: Color(0xFFB81428),
  ),
];

/// «Мой словарь»: все сохранённые слова, поиск и фильтр по статусу изучения.
class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  String _query = '';
  WordStatus? _filter; // null — все
  final _exportService = const ExportDeckService();

  Future<void> _showExportDialog(List<Word> allWords) async {
    final strings = ref.read(appStringsProvider);
    final uk = ref.read(settingsProvider.select((s) => s.isUk));

    if (allWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.exportEmptyDictAlert),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB81428).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.file_upload_outlined,
                        color: Color(0xFFB81428), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.exportDialogTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${allWords.length} ${strings.isPl ? "słów" : (strings.isUk ? "слів" : "слов")}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                strings.exportDialogSub,
                style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),

              // 1. ANKI
              _buildExportOption(
                icon: Icons.style_outlined,
                iconColor: Colors.deepPurple,
                title: strings.exportAnkiTitle,
                description: strings.exportAnkiDesc,
                onTap: () => _handleExport(
                  allWords,
                  ExportFormat.ankiTsv,
                  strings.exportAnkiTitle,
                  uk,
                  sheetCtx,
                ),
              ),
              const SizedBox(height: 10),

              // 2. QUIZLET
              _buildExportOption(
                icon: Icons.view_carousel_outlined,
                iconColor: Colors.blue.shade700,
                title: strings.exportQuizletTitle,
                description: strings.exportQuizletDesc,
                onTap: () => _handleExport(
                  allWords,
                  ExportFormat.quizletCsv,
                  strings.exportQuizletTitle,
                  uk,
                  sheetCtx,
                ),
              ),
              const SizedBox(height: 10),

              // 3. EXCEL / CSV
              _buildExportOption(
                icon: Icons.table_chart_outlined,
                iconColor: Colors.teal.shade700,
                title: strings.exportCsvTitle,
                description: strings.exportCsvDesc,
                onTap: () => _handleExport(
                  allWords,
                  ExportFormat.standardCsv,
                  strings.exportCsvTitle,
                  uk,
                  sheetCtx,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport(
    List<Word> words,
    ExportFormat format,
    String formatName,
    bool isUk,
    BuildContext sheetCtx,
  ) async {
    Navigator.of(sheetCtx).pop();
    final strings = ref.read(appStringsProvider);

    try {
      final res = await _exportService.exportToFile(
        words: words,
        format: format,
        isUk: isUk,
      );

      if (mounted) {
        await _exportService.shareExportedFile(
          result: res,
          strings: strings,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.exportSuccessSnack(words.length, formatName)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка экспорта: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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

  void _showCefrScaleModal(BuildContext context, UiLang lang, int totalWords) {
    final theme = Theme.of(context);
    String title;
    String sub;
    switch (lang) {
      case UiLang.pl:
        title = '📊 Skala słownictwa (CEFR)';
        sub = 'Zasób 5 000–6 000 słów pokrywa ponad 95% codziennej, zawodowej i oficjalnej komunikacji w Polsce. Każde dodane słowo przybliża Cię do pełnej swobody!';
        break;
      case UiLang.uk:
        title = '📊 Шкала словникового запасу (CEFR)';
        sub = 'Запас 5 000–6 000 слів покриває понад 95% щоденного, професійного та офіційного спілкування в Польщі. Кожне нове слово наближає вас до вільного володіння!';
        break;
      case UiLang.ru:
        title = '📊 Шкала словарного запаса (CEFR)';
        sub = 'Запас 5 000–6 000 слов покрывает более 95% повседневного, профессионального и официального общения в Польше. Каждое новое слово приближает вас к свободной речи!';
        break;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                sub,
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              for (final m in _kCefrMilestones) ...[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: totalWords >= m.minWords && (m.maxWords == -1 || totalWords < m.maxWords)
                        ? m.color.withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: totalWords >= m.minWords && (m.maxWords == -1 || totalWords < m.maxWords)
                          ? m.color
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: m.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          m.code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.title(lang),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: totalWords >= m.minWords && (m.maxWords == -1 || totalWords < m.maxWords)
                                    ? m.color
                                    : null,
                              ),
                            ),
                            Text(
                              m.maxWords == -1
                                  ? '≥ ${m.minWords} słów'
                                  : '${m.minWords} – ${m.maxWords} słów',
                              style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      if (totalWords >= m.minWords && (m.maxWords == -1 || totalWords < m.maxWords))
                        Icon(Icons.check_circle, color: m.color, size: 20),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCefrProgressCard(
    BuildContext context,
    int totalWords,
    int dueCount,
    UiLang lang,
    AppStrings strings,
    ThemeData theme,
  ) {
    _CefrMilestone current = _kCefrMilestones.first;
    _CefrMilestone? next;
    for (int i = 0; i < _kCefrMilestones.length; i++) {
      final m = _kCefrMilestones[i];
      if (totalWords >= m.minWords) {
        current = m;
        if (i + 1 < _kCefrMilestones.length) {
          next = _kCefrMilestones[i + 1];
        } else {
          next = null;
        }
      }
    }

    final double progress;
    final int wordsRemaining;
    if (next != null) {
      final span = next.minWords - current.minWords;
      final gained = (totalWords - current.minWords).clamp(0, span);
      progress = span > 0 ? (gained / span).clamp(0.0, 1.0) : 1.0;
      wordsRemaining = (next.minWords - totalWords).clamp(0, next.minWords);
    } else {
      progress = 1.0;
      wordsRemaining = 0;
    }

    String remainingText;
    switch (lang) {
      case UiLang.pl:
        remainingText = next != null
            ? 'Do poziomu ${next.code} brakuje $wordsRemaining słów'
            : 'Osiągnięto poziom mistrzowski C1!';
        break;
      case UiLang.uk:
        remainingText = next != null
            ? 'До рівня ${next.code} залишилося $wordsRemaining слів'
            : 'Досягнуто рівня вільного володіння C1!';
        break;
      case UiLang.ru:
        remainingText = next != null
            ? 'До уровня ${next.code} осталось $wordsRemaining слов'
            : 'Достигнут уровень свободного владения C1!';
        break;
    }

    String countLabel;
    switch (lang) {
      case UiLang.pl:
        countLabel = '$totalWords słów';
        break;
      case UiLang.uk:
        countLabel = '$totalWords слів';
        break;
      case UiLang.ru:
        countLabel = '$totalWords слов';
        break;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: current.color.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        color: current.color.withValues(alpha: 0.06),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showCefrScaleModal(context, lang, totalWords),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: current.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        current.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        current.title(lang),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      countLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: current.color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(current.color),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        remainingText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (next != null)
                      Text(
                        'Cel: ${next.minWords}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: next.color,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => ReviewScreen.show(context),
                        icon: const Icon(Icons.psychology_outlined, size: 16),
                        label: Text(
                          strings.startSm2Session,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => DictationScreen.show(context, mode: DictationMode.myDeck),
                        icon: const Icon(Icons.spellcheck, size: 16),
                        label: Text(
                          strings.trainInDictation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(wordsProvider);
    final strings = ref.watch(appStringsProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));
    final uk = ref.watch(settingsProvider.select((s) => s.isUk));
    final theme = Theme.of(context);

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
            tooltip: strings.exportDeckTooltip,
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () {
              words.whenData((all) => _showExportDialog(all));
            },
          ),
          IconButton(
            tooltip: strings.clearDictTooltip,
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _confirmClearDictionary,
          ),
        ],
      ),
      body: Column(
        children: [
          words.when(
            data: (all) => _buildCefrProgressCard(context, all.length, ref.watch(dueCountProvider), lang, strings, theme),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
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
