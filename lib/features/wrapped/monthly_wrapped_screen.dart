import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import 'monthly_stats_service.dart';

/// Экран «Мой польский за месяц» (Monthly Progress Wrapped).
/// Визуальное подведение итогов прогресса за текущий календарный месяц.
class MonthlyWrappedScreen extends ConsumerWidget {
  const MonthlyWrappedScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MonthlyWrappedScreen(),
      ),
    );
  }

  void _shareStats(BuildContext context, MonthlyStats stats, AppStrings strings) {
    final lang = strings.lang;
    final monthName = stats.monthName(lang);

    final buffer = StringBuffer();
    buffer.writeln('🇵🇱 MÓJ POLSKI • $monthName ${stats.year}');
    final statusLabel = strings.isPl
        ? 'Mój status:'
        : (strings.isUk ? 'Мій статус:' : 'Мой статус:');
    buffer.writeln('${stats.titleEmoji} $statusLabel ${stats.title(lang)}');
    buffer.writeln();
    if (strings.isPl) {
      buffer.writeln('📚 Słowa w słowniku: ${stats.totalWords} (+${stats.wordsAddedThisMonth} w tym m-cu)');
      buffer.writeln('🧠 Opanowane na pamięć: ${stats.wordsMastered}');
      buffer.writeln('🎯 Poziom CEFR: ${stats.cefrLevel} (${stats.cefrProgressPercent}%)');
      buffer.writeln('💬 Dialogi na żywo: ${stats.dialogsDone}');
      buffer.writeln('🔍 Skany i dokumenty: ${stats.scansDone}');
      buffer.writeln('🔥 Seria nauki: ${stats.streakDays} ${strings.streakDays(stats.streakDays)}');
      buffer.writeln();
      buffer.writeln('Uczę się żywego języka polskiego w Polish AI Tutor! 🚀');
    } else if (strings.isUk) {
      buffer.writeln('📚 Слів у словнику: ${stats.totalWords} (+${stats.wordsAddedThisMonth} за місяць)');
      buffer.writeln('🧠 Вивчено назубок: ${stats.wordsMastered}');
      buffer.writeln('🎯 Рівень CEFR: ${stats.cefrLevel} (${stats.cefrProgressPercent}%)');
      buffer.writeln('💬 Живих діалогів: ${stats.dialogsDone}');
      buffer.writeln('🔍 Сканів та документів: ${stats.scansDone}');
      buffer.writeln('🔥 Ударний режим: ${stats.streakDays} ${strings.streakDays(stats.streakDays)}');
      buffer.writeln();
      buffer.writeln('Вчу живу польську мову в Polish AI Tutor! 🚀');
    } else {
      buffer.writeln('📚 Слов в словаре: ${stats.totalWords} (+${stats.wordsAddedThisMonth} за месяц)');
      buffer.writeln('🧠 Выучено назубок: ${stats.wordsMastered}');
      buffer.writeln('🎯 Уровень CEFR: ${stats.cefrLevel} (${stats.cefrProgressPercent}%)');
      buffer.writeln('💬 Живых диалогов: ${stats.dialogsDone}');
      buffer.writeln('🔍 Сканирований и документов: ${stats.scansDone}');
      buffer.writeln('🔥 Ударный режим: ${stats.streakDays} ${strings.streakDays(stats.streakDays)}');
      buffer.writeln();
      buffer.writeln('Учу живой польский язык в Polish AI Tutor! 🚀');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          strings.isPl
              ? '📋 Skopiowano podsumowanie do schowka! Udostępnij znajomym.'
              : (strings.isUk
                  ? '📋 Підсумок скопійовано в буфер обміну! Поділіться з друзями.'
                  : '📋 Итоги скопированы в буфер обмена! Поделитесь с друзьями.'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(monthlyStatsFutureProvider);
    final strings = ref.watch(appStringsProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));

    return Scaffold(
      backgroundColor: AppTheme.bgWarmMilk,
      appBar: AppBar(
        title: Text(
          strings.isPl
              ? 'Mój polski w tym miesiącu'
              : (strings.isUk ? 'Мій польський за місяць' : 'Мой польский за месяц'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryCarmine,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: strings.passportShareTooltip,
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              statsAsync.whenData((s) => _shareStats(context, s, strings));
            },
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryCarmine),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Ошибка загрузки статистики: $err'),
          ),
        ),
        data: (stats) => _buildContent(context, stats, strings, lang),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MonthlyStats stats,
    AppStrings strings,
    dynamic lang,
  ) {
    final monthName = stats.monthName(lang);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ГЛАВНАЯ ГЕРОЙ-КАРТОЧКА WRAPPED
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryCarmine, Color(0xFF6B0B17)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33B81428),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Плашка месяца
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🇵🇱 ', style: TextStyle(fontSize: 14)),
                      Text(
                        'MÓJ POLSKI • ${monthName.toUpperCase()} ${stats.year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Эмодзи титула
                Text(
                  stats.titleEmoji,
                  style: const TextStyle(fontSize: 54),
                ),
                const SizedBox(height: 8),

                // Персональный титул
                Text(
                  stats.title(lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  strings.isPl
                      ? 'Oto Twoje oficjalne podsumowanie językowe'
                      : (strings.isUk
                          ? 'Ось ваше офіційне мовне підбиття підсумків'
                          : 'Вот ваши официальные языковые итоги'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // СЕТКА СТАТИСТИКИ 2x2
          Row(
            children: [
              // Карточка: Слова
              Expanded(
                child: _buildStatTile(
                  icon: Icons.auto_stories_rounded,
                  iconColor: Colors.deepPurple,
                  title: strings.isPl
                      ? 'Słowa w talii'
                      : (strings.isUk ? 'Слів у колоді' : 'Слов в колоде'),
                  value: '${stats.totalWords}',
                  subtitle: '+${stats.wordsAddedThisMonth} ${strings.isPl ? "w tym m-cu" : (strings.isUk ? "за місяць" : "за месяц")}',
                  badgeText: '${stats.wordsMastered} ${strings.isPl ? "opanowane" : (strings.isUk ? "вивчено" : "выучено")}',
                  badgeColor: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 12),

              // Карточка: CEFR
              Expanded(
                child: _buildStatTile(
                  icon: Icons.track_changes_rounded,
                  iconColor: Colors.blue.shade700,
                  title: strings.isPl
                      ? 'Poziom CEFR'
                      : (strings.isUk ? 'Рівень CEFR' : 'Уровень CEFR'),
                  value: stats.cefrLevel.split(' ').first,
                  subtitle: '${stats.cefrProgressPercent}% ${strings.isPl ? "celu" : (strings.isUk ? "цілі" : "цели")}',
                  badgeText: '${stats.totalWords}/${stats.cefrTarget}',
                  badgeColor: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Карточка: Диалоги
              Expanded(
                child: _buildStatTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: Colors.teal.shade700,
                  title: strings.isPl
                      ? 'Dialogi z AI'
                      : (strings.isUk ? 'Діалоги з ШІ' : 'Диалоги с ИИ'),
                  value: '${stats.dialogsDone}',
                  subtitle: strings.isPl
                      ? 'żywe sytuacje'
                      : (strings.isUk ? 'життєві бесіди' : 'живые беседы'),
                ),
              ),
              const SizedBox(width: 12),

              // Карточка: Сканер
              Expanded(
                child: _buildStatTile(
                  icon: Icons.document_scanner_outlined,
                  iconColor: AppTheme.primaryCarmine,
                  title: strings.isPl
                      ? 'Skany i pisma'
                      : (strings.isUk ? 'Скани і папери' : 'Сканы и бумаги'),
                  value: '${stats.scansDone}',
                  subtitle: strings.isPl
                      ? 'umowy i czeki'
                      : (strings.isUk ? 'договори та чеки' : 'договоры и чеки'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ПОЛОСА CEFR ПРОГРЕССА
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strings.isPl
                          ? 'Postęp do poziomu ${stats.cefrLevel}'
                          : (strings.isUk
                              ? 'Прогрес до рівня ${stats.cefrLevel}'
                              : 'Прогресс к уровню ${stats.cefrLevel}'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${stats.cefrProgressPercent}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: AppTheme.primaryCarmine,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: stats.cefrProgressPercent / 100.0,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryCarmine,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.isPl
                      ? 'Znasz już ${stats.totalWords} słów z docelowych ${stats.cefrTarget} dla tego etapu.'
                      : (strings.isUk
                          ? 'Ви вже знаєте ${stats.totalWords} слів із цільових ${stats.cefrTarget} для цього етапу.'
                          : 'Вы уже знаете ${stats.totalWords} слов из целевых ${stats.cefrTarget} для этого этапа.'),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // СТРИК И ПОСТОЯНСТВО
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🔥', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.isPl
                            ? 'Seria nauki: ${stats.streakDays} ${strings.streakDays(stats.streakDays)}'
                            : (strings.isUk
                                ? 'Ударний режим: ${stats.streakDays} ${strings.streakDays(stats.streakDays)}'
                                : 'Ударный режим: ${stats.streakDays} ${strings.streakDays(stats.streakDays)}'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.brown.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings.isPl
                            ? 'Regularność przynosi najlepsze rezultaty językowe!'
                            : (strings.isUk
                                ? 'Регулярність приносить найкращі мовні результати!'
                                : 'Регулярность приносит наилучшие языковые результаты!'),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.brown.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // КНОПКА ШЕРИНГА
          FilledButton.icon(
            onPressed: () => _shareStats(context, stats, strings),
            icon: const Icon(Icons.share_rounded, size: 20),
            label: Text(
              strings.isPl
                  ? 'Udostępnij mój wynik za miesiąc'
                  : (strings.isUk
                      ? 'Поділитися моїм результатом'
                      : 'Поделиться моим результатом'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryCarmine,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 8),

          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              strings.isPl
                  ? 'Kontynuuj naukę 🚀'
                  : (strings.isUk
                      ? 'Продовжити навчання 🚀'
                      : 'Продолжить обучение 🚀'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 22),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? iconColor).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: badgeColor ?? iconColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
