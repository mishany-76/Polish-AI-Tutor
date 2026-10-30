import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../scanner/translation_service.dart' show UiLang;
import 'exam_model.dart';
import 'exam_result_screen.dart';
import 'exam_screen.dart';
import 'exam_service.dart';

/// Хаб экзаменационного испытания (Брифинг, выбор экзаменатора, история сертификатов)
class ExamHubScreen extends ConsumerStatefulWidget {
  const ExamHubScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ExamHubScreen(),
      ),
    );
  }

  @override
  ConsumerState<ExamHubScreen> createState() => _ExamHubScreenState();
}

class _ExamHubScreenState extends ConsumerState<ExamHubScreen> {
  int _selectedExaminerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));
    final examService = ref.watch(examServiceProvider);

    final bestResult = examService.getBestResult();
    final history = examService.getHistory();
    final selectedExaminer = kDefaultExaminers[_selectedExaminerIndex];

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
                strings.examBossTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Баннер экзаменационной комиссии
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryCarmine.withValues(alpha: 0.12),
                  theme.colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryCarmine.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PAŃSTWOWY EGZAMIN CEFR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCarmine,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        strings.examBossBadge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  strings.examBossSubtitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.examBossBannerSub,
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),

                // Если уже сдавал: отображаем лучший сертификат
                if (bestResult != null)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => ExamResultScreen.show(context, bestResult),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('📜', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Twój poziom: ${bestResult.overallLevel} (${bestResult.score}/100 pkt)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                ),
                                Text(
                                  'Certyfikat zdany • Zobacz szczegóły',
                                  style: TextStyle(fontSize: 11.5, color: Colors.green.shade800),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3 Этапа экзамена
          Text(
            lang == UiLang.pl ? 'Struktura egzaminu (3 etapy)' : (lang == UiLang.uk ? 'Структура іспиту (3 етапи)' : 'Структура экзамена (3 этапа)'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _buildStageCard(
            context,
            num: '1',
            emoji: '👋',
            title: strings.examStage1,
            desc: lang == UiLang.pl
                ? 'Przedstawienie się, pochodzenie, plany zawodowe i powód nauki polskiego.'
                : (lang == UiLang.uk
                    ? 'Знайомство, звідки ви, професія та мета вивчення польської мови.'
                    : 'Знакомство, откуда вы, профессия и цель изучения польского языка.'),
          ),
          const SizedBox(height: 8),
          _buildStageCard(
            context,
            num: '2',
            emoji: '🏢',
            title: strings.examStage2,
            desc: lang == UiLang.pl
                ? 'Rozwiązanie problemu w urzędzie, banku, u lekarza lub z właścicielem lokalu.'
                : (lang == UiLang.uk
                    ? 'Вирішення ситуації в уженді, банку, поліклініці або при оренді.'
                    : 'Решение ситуации в уженде, банке, поликлинике или при аренде жилья.'),
          ),
          const SizedBox(height: 8),
          _buildStageCard(
            context,
            num: '3',
            emoji: '💡',
            title: strings.examStage3,
            desc: lang == UiLang.pl
                ? 'Wyrażenie własnej opinii i argumentacja na temat adaptacji w Polsce.'
                : (lang == UiLang.uk
                    ? 'Висловлення власної думки та аргументація щодо життя в Польщі.'
                    : 'Выражение собственного мнения и аргументация о жизни в Польше.'),
          ),
          const SizedBox(height: 20),

          // Выбор экзаменатора
          Text(
            lang == UiLang.pl ? 'Wybierz egzaminatora' : (lang == UiLang.uk ? 'Оберіть екзаменатора' : 'Выберите экзаменатора'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              for (int i = 0; i < kDefaultExaminers.length; i++) ...[
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _selectedExaminerIndex = i),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedExaminerIndex == i
                            ? AppTheme.primaryCarmine.withValues(alpha: 0.1)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedExaminerIndex == i
                              ? AppTheme.primaryCarmine
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          width: _selectedExaminerIndex == i ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(kDefaultExaminers[i].emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Text(
                            kDefaultExaminers[i].name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _selectedExaminerIndex == i ? AppTheme.primaryCarmine : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            kDefaultExaminers[i].role(lang),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (i == 0) const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Кнопка запуска экзамена
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryCarmine,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ExamScreen(examiner: selectedExaminer),
                  ),
                );
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(
                lang == UiLang.pl
                    ? 'Rozpocznij egzamin ustny (5 min)'
                    : (lang == UiLang.uk ? 'Розпочати усний іспит (5 хв)' : 'Начать устный экзамен (5 мин)'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // История предыдущих сертификатов (если есть)
          if (history.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.examHistoryTitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${history.length} ${lang == UiLang.pl ? 'prób' : (lang == UiLang.uk ? 'спроб' : 'попыток')}',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final h in history.take(3)) ...[
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: h.passed ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                    child: Text(
                      h.overallLevel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: h.passed ? Colors.green.shade800 : Colors.deepOrange,
                      ),
                    ),
                  ),
                  title: Text('${h.overallLevel} • ${h.score}/100 pkt'),
                  subtitle: Text('${h.examinerName} • ${h.date.day}.${h.date.month}.${h.date.year}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 13),
                  onTap: () => ExamResultScreen.show(context, h),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStageCard(BuildContext context, {
    required String num,
    required String emoji,
    required String title,
    required String desc,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primaryCarmine.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              num,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryCarmine),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

