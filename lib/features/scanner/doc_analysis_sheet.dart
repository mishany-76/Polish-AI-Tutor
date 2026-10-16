import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import 'doc_analysis_service.dart';

/// Визуальная модальная панель глубокого анализа польского документа.
class DocAnalysisSheet extends ConsumerStatefulWidget {
  const DocAnalysisSheet({
    super.key,
    required this.analysis,
  });

  final DocAnalysis analysis;

  static Future<void> show(BuildContext context, DocAnalysis analysis) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DocAnalysisSheet(analysis: analysis),
    );
  }

  @override
  ConsumerState<DocAnalysisSheet> createState() => _DocAnalysisSheetState();
}

class _DocAnalysisSheetState extends ConsumerState<DocAnalysisSheet> {
  bool _vocabAdded = false;
  bool _showRawText = false;

  Future<void> _addVocabToDeck() async {
    final vocab = widget.analysis.vocabulary;
    if (vocab.isEmpty) return;

    final db = ref.read(databaseProvider);
    final isUk = ref.read(settingsProvider).isUk;

    final items = [
      for (final v in vocab)
        (
          lemma: v.polishTerm,
          translation: v.translation,
          pos: 'юридический термин',
        )
    ];

    final added = await db.batchAddAiWords(items, uk: isUk);
    if (added > 0) {
      AchievementService.instance.increment('words_added', by: added);
    }

    if (mounted) {
      setState(() => _vocabAdded = true);
      final strings = ref.read(appStringsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added > 0
                ? (strings.isPl
                    ? '✅ Dodano $added terminów urzędowych do słownika'
                    : (strings.isUk
                        ? '✅ Додано $added офіційних термінів до словника'
                        : '✅ Добавлено $added официальных терминов в словарь'))
                : (strings.isPl
                    ? 'Wszystkie te terminy już znajdują się w słowniku'
                    : (strings.isUk
                        ? 'Всі ці терміни вже є у словнику'
                        : 'Все эти термины уже есть в словаре')),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _copySummary() {
    final a = widget.analysis;
    final buffer = StringBuffer();
    buffer.writeln('📄 ${a.docType}');
    if (a.originalTitle != null && a.originalTitle!.isNotEmpty) {
      buffer.writeln('«${a.originalTitle}»');
    }
    buffer.writeln();
    buffer.writeln('💡 СУТЬ ДОКУМЕНТА:');
    buffer.writeln(a.summary);
    buffer.writeln();

    if (a.financials.isNotEmpty) {
      buffer.writeln('💰 ФИНАНСОВЫЕ УСЛОВИЯ:');
      for (final f in a.financials) {
        buffer.writeln('• ${f.label}: ${f.value}');
      }
      buffer.writeln();
    }

    if (a.risks.isNotEmpty) {
      buffer.writeln('⚠️ РИСКИ И ПОДВОДНЫЕ КАМНИ:');
      for (final r in a.risks) {
        buffer.writeln('• ${r.title} — ${r.description}');
      }
      buffer.writeln();
    }

    if (a.actions.isNotEmpty) {
      buffer.writeln('📋 ЧТО СДЕЛАТЬ:');
      for (final act in a.actions) {
        final d = act.deadline != null ? ' (срок: ${act.deadline})' : '';
        buffer.writeln('• ${act.text}$d');
      }
      buffer.writeln();
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    final strings = ref.read(appStringsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.docCopiedSnack),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    final strings = ref.read(appStringsProvider);
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.92;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppTheme.bgWarmMilk,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Верхняя плашка Drag Handle + Шапка
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.gavel_rounded,
                          color: AppTheme.primaryCarmine,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.docAnalysisTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryCarmine,
                              ),
                            ),
                            Text(
                              a.docType,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: strings.docCopySummary,
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        onPressed: _copySummary,
                      ),
                      IconButton(
                        tooltip: strings.cancel,
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Контент разбора документа
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Заголовок оригинала (если найден)
                    if (a.originalTitle != null && a.originalTitle!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.description_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                a.originalTitle!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // СЕКЦИЯ 1: СУТЬ ДОКУМЕНТА (РЕЗЮМЕ)
                    _buildSectionCard(
                      icon: Icons.lightbulb_outline_rounded,
                      iconColor: Colors.amber.shade800,
                      title: strings.docSectionSummary,
                      child: Text(
                        a.summary,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.45,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // СЕКЦИЯ 2: ФИНАНСОВЫЕ УСЛОВИЯ И ПЛАТЕЖИ
                    _buildSectionCard(
                      icon: Icons.payments_outlined,
                      iconColor: Colors.teal.shade700,
                      title: strings.docSectionFinancials,
                      child: a.financials.isEmpty
                          ? Text(
                              strings.docNoFinancials,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Column(
                              children: [
                                for (final fin in a.financials)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade50.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.teal.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            fin.label,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.5,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            fin.value,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.teal.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 14),

                    // СЕКЦИЯ 3: РИСКИ И ПОДВОДНЫЕ КАМНИ
                    _buildSectionCard(
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.red.shade700,
                      title: strings.docSectionRisks,
                      child: a.risks.isEmpty
                          ? Text(
                              strings.docNoRisks,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Column(
                              children: [
                                for (final risk in a.risks)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: risk.isHighPriority
                                          ? const Color(0xFFFFECEE)
                                          : const Color(0xFFFFF7E6),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: risk.isHighPriority
                                            ? Colors.red.shade300
                                            : Colors.amber.shade400,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              risk.isHighPriority
                                                  ? Icons.error_outline_rounded
                                                  : Icons.info_outline_rounded,
                                              size: 18,
                                              color: risk.isHighPriority
                                                  ? Colors.red.shade800
                                                  : Colors.amber.shade900,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                risk.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: risk.isHighPriority
                                                      ? Colors.red.shade900
                                                      : Colors.brown.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          risk.description,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            height: 1.35,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 14),

                    // СЕКЦИЯ 4: ЧТО НУЖНО СДЕЛАТЬ (ДЕЙСТВИЯ & ДЕДЛАЙНЫ)
                    if (a.actions.isNotEmpty) ...[
                      _buildSectionCard(
                        icon: Icons.checklist_rounded,
                        iconColor: Colors.blue.shade700,
                        title: strings.docSectionActions,
                        child: Column(
                          children: [
                            for (var i = 0; i < a.actions.length; i++)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            a.actions[i].text,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (a.actions[i].deadline != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.schedule_rounded,
                                                  size: 14,
                                                  color: Colors.deepOrange,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  a.actions[i].deadline!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepOrange,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // СЕКЦИЯ 5: ОФИЦИАЛЬНЫЙ СЛОВАРЬ ИЗ ДОКУМЕНТА
                    if (a.vocabulary.isNotEmpty) ...[
                      _buildSectionCard(
                        icon: Icons.menu_book_rounded,
                        iconColor: AppTheme.primaryCarmine,
                        title: strings.docSectionVocab,
                        child: Column(
                          children: [
                            for (final term in a.vocabulary)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          term.polishTerm,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.5,
                                            color: AppTheme.primaryCarmine,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '—',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            term.translation,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.5,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (term.explanation.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        term.explanation,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.grey.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonalIcon(
                                onPressed: _vocabAdded ? null : _addVocabToDeck,
                                icon: Icon(
                                  _vocabAdded
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.bookmark_add_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  _vocabAdded
                                      ? (strings.isPl
                                          ? '✅ Dodano do słownika'
                                          : (strings.isUk
                                              ? '✅ Додано до словника'
                                              : '✅ Добавлено в словарь'))
                                      : strings.docAddVocabBtn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ОРИГИНАЛЬНЫЙ OCR-ТЕКСТ (СВЕРНУТЫЙ)
                    OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _showRawText = !_showRawText),
                      icon: Icon(
                        _showRawText
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                      ),
                      label: Text(
                        _showRawText
                            ? (strings.isPl
                                ? 'Ukryj tekst OCR'
                                : (strings.isUk
                                    ? 'Сховати OCR-текст'
                                    : 'Скрыть OCR-текст'))
                            : (strings.isPl
                                ? 'Pokaż rozpoznany tekst OCR'
                                : (strings.isUk
                                    ? 'Показати розпізнаний OCR-текст'
                                    : 'Показать распознанный OCR-текст')),
                      ),
                    ),
                    if (_showRawText) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SelectableText(
                          a.rawText,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppTheme.cardShadow],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
