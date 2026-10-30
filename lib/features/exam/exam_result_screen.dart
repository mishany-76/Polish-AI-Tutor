import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../scanner/translation_service.dart' show UiLang;
import 'exam_model.dart';

/// Экран официального сертификата и подробного отчета CEFR
class ExamResultScreen extends ConsumerWidget {
  const ExamResultScreen({super.key, required this.result});

  final ExamAssessmentResult result;

  static Future<void> show(BuildContext context, ExamAssessmentResult result) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExamResultScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));

    final isPassed = result.passed;
    final primaryColor = isPassed ? Colors.green.shade700 : Colors.deepOrange;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                strings.examCertificateTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Официальный бланк сертификата
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('🇵🇱', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 6),
                const Text(
                  'PAŃSTWOWA KOMISJA EGZAMINACYJNA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.examCertificateTitle.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Круглый штамп с уровнем CEFR
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withValues(alpha: 0.12),
                    border: Border.all(color: primaryColor, width: 2.5),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        result.overallLevel,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        'CEFR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Статус: ЗДАН / СДАН
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPassed ? strings.examPassed : strings.examNotPassed,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${result.score} / 100 punktów',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Egzaminator: ${result.examinerName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // 4 критерия оценки
                _buildCriterionBar(
                  label: strings.examCriteriaVocab,
                  score: result.vocabScore,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(height: 10),
                _buildCriterionBar(
                  label: strings.examCriteriaGrammar,
                  score: result.grammarScore,
                  color: Colors.purple.shade700,
                ),
                const SizedBox(height: 10),
                _buildCriterionBar(
                  label: strings.examCriteriaFluency,
                  score: result.fluencyScore,
                  color: Colors.teal.shade700,
                ),
                const SizedBox(height: 10),
                _buildCriterionBar(
                  label: strings.examCriteriaInteraction,
                  score: result.interactionScore,
                  color: Colors.indigo.shade700,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Заключение экзаменатора
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.rate_review_outlined, size: 20, color: AppTheme.primaryCarmine),
                    const SizedBox(width: 8),
                    Text(
                      lang == UiLang.pl ? 'Opinia egzaminatora' : (lang == UiLang.uk ? 'Висновок екзаменатора' : 'Заключение экзаменатора'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  result.feedbackPl,
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, height: 1.35),
                ),
                if (result.feedbackTr.isNotEmpty && lang != UiLang.pl) ...[
                  const SizedBox(height: 6),
                  Text(
                    result.feedbackTr,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Сильные стороны
          if (result.strongPoints.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        lang == UiLang.pl ? 'Mocne strony' : (lang == UiLang.uk ? 'Сильні сторони' : 'Сильные стороны'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final sp in result.strongPoints)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(sp, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Зоны роста
          if (result.weakPoints.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tips_and_updates, size: 18, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        lang == UiLang.pl ? 'Do poprawy' : (lang == UiLang.uk ? 'Зони для покращення' : 'Зоны для улучшения'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final wp in result.weakPoints)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(wp, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Кнопки управления
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final text = '🏆 Certyfikat CEFR Polish AI Tutor:\n'
                          'Poziom: ${result.overallLevel} (${result.score}/100 pkt)\n'
                          'Egzaminator: ${result.examinerName}\n'
                          'Status: ${isPassed ? "Zdany" : "Wymaga poprawy"}\n'
                          'Podsumowanie: ${result.feedbackPl}';
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            lang == UiLang.pl
                                ? '📋 Skopiowano podsumowanie certyfikatu!'
                                : (lang == UiLang.uk
                                    ? '📋 Скопійовано сертифікат у буфер обміну!'
                                    : '📋 Сертификат скопирован в буфер обмена!'),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: Text(
                      lang == UiLang.pl ? 'Kopiuj certyfikat' : (lang == UiLang.uk ? 'Поділитися' : 'Поделиться'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryCarmine,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home, size: 18),
                    label: Text(
                      lang == UiLang.pl ? 'Do menu' : (lang == UiLang.uk ? 'На головну' : 'На главную'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCriterionBar({
    required String label,
    required int score,
    required Color color,
  }) {
    final progress = (score / 25).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('$score / 25', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

