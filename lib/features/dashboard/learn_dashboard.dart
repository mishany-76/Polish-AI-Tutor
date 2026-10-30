import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/streak/streak_service.dart';
import '../../core/theme/app_theme.dart';
import '../passport/passport_screen.dart';
import '../review/quiz_builders.dart';
import '../review/quiz_screen.dart';
import '../review/review_screen.dart';
import '../scanner/scanner_providers.dart';
import '../tutor/roleplay_screen.dart';
import '../tutor/scenarios.dart';
import '../wrapped/monthly_wrapped_screen.dart';
import '../dictation/dictation_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../onboarding/user_profile.dart';
import '../professions/professions_data.dart';
import '../professions/professions_screen.dart';
import '../episodes/episodes_screen.dart';
import '../exam/exam_hub_screen.dart';
import '../guide/user_guide_screen.dart';
import '../primer/primer_screen.dart';

/// Главный экран: тренажёр обучения (повторение, игры, ролевые диалоги).
class LearnDashboard extends ConsumerStatefulWidget {
  const LearnDashboard({super.key});

  @override
  ConsumerState<LearnDashboard> createState() => _LearnDashboardState();
}

class _LearnDashboardState extends ConsumerState<LearnDashboard> {
  int _dialogCategoryIndex = 0; // 0 = Быт, 1 = Профессии

  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  Future<void> _deferDueQueue(BuildContext context, WidgetRef ref) async {
    final strings = ref.read(appStringsProvider);
    final count = await ref.read(databaseProvider).deferDueWordsToTomorrow();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.queueDeferredSnack(count)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildUserProfileHeader(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppStrings strings,
  ) {
    final profile = ref.watch(userProfileProvider);
    final goalStr = switch (profile.goal) {
      PolishGoal.daily => strings.onboardingGoalDailyTitle,
      PolishGoal.documents => strings.onboardingGoalDocsTitle,
      PolishGoal.work => strings.onboardingGoalWorkTitle,
      PolishGoal.exam => strings.onboardingGoalExamTitle,
    };
    final levelStr = switch (profile.level) {
      PolishLevel.starter => 'A0',
      PolishLevel.basic => 'A1–A2',
      PolishLevel.intermediate => 'B1+',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryCarmine.withValues(alpha: 0.12),
            child: const Text('👩‍🏫', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.isPl
                      ? 'Cześć, ${profile.displayName}!'
                      : (strings.isUk
                          ? 'Привіт, ${profile.displayName}!'
                          : 'Привет, ${profile.displayName}!'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '🎯 $goalStr · $levelStr',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: strings.profileRestartOnboarding,
            onPressed: () => _push(
              context,
              const OnboardingScreen(isRestart: true),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = ref.watch(dueCountProvider);
    final total = ref.watch(wordsProvider).value?.length ?? 0;
    final settings = ref.watch(settingsProvider);
    final streak = ref.watch(streakProvider).value ?? 1;
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🇵🇱 Polish AI Tutor'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$streak ${strings.streakDays(streak)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: strings.monthlyWrappedTooltip,
            icon: const Icon(Icons.insights_rounded),
            onPressed: () => MonthlyWrappedScreen.show(context),
          ),
          IconButton(
            tooltip: strings.passportTitle,
            icon: const Icon(Icons.badge_outlined),
            onPressed: () => _push(context, const PassportScreen()),
          ),
          IconButton(
            tooltip: strings.guideTooltip,
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showUserGuide(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Приветствие и цель пользователя ---
          _buildUserProfileHeader(context, ref, theme, strings),
          const SizedBox(height: 12),
          // --- Повторение ---
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.dueWordsToday,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('$due',
                      style: theme.textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(strings.totalInDeck(total),
                      style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: due > 0
                            ? () => _push(context, const ReviewScreen())
                            : () => ref.read(currentTabProvider.notifier).setTab(1),
                        icon: Icon(due > 0 ? Icons.play_arrow : Icons.document_scanner),
                        label: Text(
                          due == 0
                              ? (total == 0
                                  ? strings.scanWords
                                  : strings.allDoneToday)
                              : strings.startReview,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        onPressed: () => _showManualWordDialog(context, ref),
                        icon: const Icon(Icons.edit, size: 18),
                        label: Text(
                          strings.manualWordBtn,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (due > 0)
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            minimumSize: const Size(46, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          tooltip: strings.clearQueueBtn,
                          icon: const Icon(Icons.snooze, size: 20),
                          onPressed: () => _deferDueQueue(context, ref),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Баннер «Polski Elementarz (Букварь A0)» ---
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: InkWell(
              onTap: () => PrimerScreen.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                      theme.colorScheme.surface,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🔤', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                strings.primerTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  strings.primerBadge,
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            strings.primerSubtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- Баннер «Мой польский за месяц» ---
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: InkWell(
              onTap: () => MonthlyWrappedScreen.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                      Colors.white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.insights_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.monthlyWrappedTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.isPl
                                ? 'Podsumowanie słów, poziomu CEFR i osiągnięć'
                                : (strings.isUk
                                    ? 'Підсумок слів, рівня CEFR та досягнень'
                                    : 'Итоги слов, уровня CEFR и достижений'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Игры ---
          Text(strings.drillsTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          _DrillTile(
            icon: Icons.edit_note,
            title: strings.drillEndingsTitle,
            subtitle: strings.drillEndingsSub,
            onTap: () async {
              final lang = ref.read(settingsProvider).lang;
              final q = await buildAdaptiveEndingsQuiz(lang);
              if (!context.mounted) return;
              _push(
                context,
                QuizScreen(
                  title: strings.drillEndingsTitle,
                  category: 'endings',
                  questions: q,
                  onGenerateNextRound: () =>
                      buildAdaptiveEndingsQuiz(ref.read(settingsProvider).lang),
                ),
              );
            },
          ),
          _DrillTile(
            icon: Icons.headphones,
            title: strings.drillAudioTitle,
            subtitle: strings.drillAudioSub,
            onTap: () async {
              final deck = await ref.read(databaseProvider).allWords();
              final lang = ref.read(settingsProvider).lang;
              final q = await buildAdaptiveAudioQuiz(deck, lang);
              if (!context.mounted) return;
              _push(
                context,
                QuizScreen(
                  title: strings.drillAudioTitle,
                  category: 'audio',
                  questions: q,
                  onGenerateNextRound: () {
                    final d = ref.read(wordsProvider).value ?? deck;
                    return buildAdaptiveAudioQuiz(d, ref.read(settingsProvider).lang);
                  },
                ),
              );
            },
          ),
          _DrillTile(
            icon: Icons.warning_amber,
            title: strings.drillFalseFriendsTitle,
            subtitle: strings.drillFalseFriendsSub,
            onTap: () async {
              final lang = ref.read(settingsProvider).lang;
              final q = await buildAdaptiveFalseFriendsQuiz(lang);
              if (!context.mounted) return;
              _push(
                context,
                QuizScreen(
                  title: strings.drillFalseFriendsTitle,
                  category: 'false_friends',
                  questions: q,
                  onGenerateNextRound: () =>
                      buildAdaptiveFalseFriendsQuiz(ref.read(settingsProvider).lang),
                ),
              );
            },
          ),
          _DrillTile(
            icon: Icons.payments_outlined,
            title: strings.drillNumbersTitle,
            subtitle: strings.drillNumbersSub,
            onTap: () async {
              final lang = ref.read(settingsProvider).lang;
              final q = await buildAdaptiveNumbersPricesQuiz(lang);
              if (!context.mounted) return;
              _push(
                context,
                QuizScreen(
                  title: strings.drillNumbersTitle,
                  category: 'numbers_prices',
                  questions: q,
                  onGenerateNextRound: () =>
                      buildAdaptiveNumbersPricesQuiz(ref.read(settingsProvider).lang),
                ),
              );
            },
          ),
          _DrillTile(
            icon: Icons.spellcheck_rounded,
            title: strings.drillDictationTitle,
            subtitle: strings.drillDictationSub,
            onTap: () => DictationScreen.show(context),
          ),
          const SizedBox(height: 20),

          // --- Баннер «Польский для профессий» ---
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppTheme.primaryCarmine.withValues(alpha: 0.20),
              ),
            ),
            child: InkWell(
              onTap: () => ProfessionsScreen.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryCarmine.withValues(alpha: 0.08),
                      Colors.white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('💼', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                strings.professionsTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryCarmine.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'B2C / B2B',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryCarmine,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.professionsBannerSub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryCarmine),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- Баннер «Живые эпизоды: Жизнь в Польше» ---
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppTheme.primaryCarmine.withValues(alpha: 0.20),
              ),
            ),
            child: InkWell(
              onTap: () => EpisodesScreen.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryCarmine.withValues(alpha: 0.08),
                      Colors.white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🎬', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                strings.episodesTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryCarmine.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  strings.isPl ? 'SERIAL' : (strings.isUk ? 'СЕРІАЛ' : 'СЕРИАЛ'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryCarmine,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.episodesBannerSub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryCarmine),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- Баннер «Экзаменационный Boss Fight (CEFR)» ---
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppTheme.primaryCarmine.withValues(alpha: 0.20),
              ),
            ),
            child: InkWell(
              onTap: () => ExamHubScreen.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryCarmine.withValues(alpha: 0.08),
                      Colors.white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🎓', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                strings.examBossTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryCarmine.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  strings.examBossBadge,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryCarmine,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.examBossBannerSub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryCarmine),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Диалоги ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  strings.roleplayTitle,
                  style: theme.textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (settings.hasKey)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        strings.readyToChat,
                        style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            settings.hasKey
                ? (strings.isPl
                    ? 'AI odgrywa rolę mieszkańca Polski — odpowiadaj głosem lub tekstem'
                    : (strings.isUk
                        ? 'ШІ грає жителя Польщі — відповідайте голосом або текстом'
                        : 'ИИ играет поляка — отвечайте голосом или текстом'))
                : (strings.isPl
                    ? '⚠️ Podaj klucz API w «Ustawieniach», aby rozpocząć dialogi'
                    : (strings.isUk
                        ? '⚠️ Вкажіть API-ключ шлюзу в «Налаштуваннях», щоб почати діалоги'
                        : '⚠️ Укажите API-ключ шлюза в «Настройки», чтобы начать диалоги')),
            style: TextStyle(
              fontSize: 13,
              color: settings.hasKey ? theme.textTheme.bodySmall?.color : theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 56,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _dialogCategoryIndex = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _dialogCategoryIndex == 0
                            ? AppTheme.primaryCarmine
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _dialogCategoryIndex == 0
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryCarmine.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 19,
                              color: _dialogCategoryIndex == 0
                                  ? Colors.white
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                strings.professionsCategoryLife,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.15,
                                  fontWeight: _dialogCategoryIndex == 0
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: _dialogCategoryIndex == 0
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _dialogCategoryIndex = 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _dialogCategoryIndex == 1
                            ? AppTheme.primaryCarmine
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _dialogCategoryIndex == 1
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryCarmine.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 19,
                              color: _dialogCategoryIndex == 1
                                  ? Colors.white
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                strings.professionsCategoryWork,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.15,
                                  fontWeight: _dialogCategoryIndex == 1
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: _dialogCategoryIndex == 1
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
            children: [
              for (final s in (_dialogCategoryIndex == 0
                  ? scenarios
                  : kAllProfessions.map((p) => p.scenario).toList()))
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _showScenarioSheet(context, s, strings),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.emoji, style: const TextStyle(fontSize: 28)),
                          const Spacer(),
                          Text(
                            s.title(strings.lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(s.level, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                        ],
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

  void _showScenarioSheet(BuildContext context, Scenario s, AppStrings strings) {
    if (s.subScenarios.isEmpty) {
      _push(context, RoleplayScreen(scenario: s));
      return;
    }

    SubScenario selectedSub = s.subScenarios.first;
    DialogInitiator selectedInitiator = DialogInitiator.npcFirst;
    RoleplayDifficulty selectedDifficulty = RoleplayDifficulty.life;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) {
        final theme = Theme.of(sheetCtx);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, scrollCtrl) {
                return ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Row(
                      children: [
                        Text(s.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title(strings.lang),
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(s.level, style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.chooseSubSituation,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final sub in s.subScenarios)
                      InkWell(
                        onTap: () => setSheetState(() => selectedSub = sub),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedSub.id == sub.id
                                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedSub.id == sub.id
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    selectedSub.id == sub.id
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 18,
                                    color: selectedSub.id == sub.id
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      sub.title(strings.lang),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: selectedSub.id == sub.id
                                            ? theme.colorScheme.primary
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 26, top: 4),
                                child: Text(
                                  sub.description(strings.lang),
                                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      strings.whoSpeaksFirst,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setSheetState(() => selectedInitiator = DialogInitiator.npcFirst),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: selectedInitiator == DialogInitiator.npcFirst
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedInitiator == DialogInitiator.npcFirst
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                strings.initiatorNpcFirst,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selectedInitiator == DialogInitiator.npcFirst
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => setSheetState(() => selectedInitiator = DialogInitiator.userFirst),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: selectedInitiator == DialogInitiator.userFirst
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedInitiator == DialogInitiator.userFirst
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                strings.initiatorUserFirst,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selectedInitiator == DialogInitiator.userFirst
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.dialogueDifficulty,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.3,
                      children: [
                        _buildDifficultyCard(
                          title: strings.difficultyCalm,
                          sub: strings.difficultyCalmSub,
                          isSelected: selectedDifficulty == RoleplayDifficulty.calm,
                          theme: theme,
                          onTap: () => setSheetState(() => selectedDifficulty = RoleplayDifficulty.calm),
                        ),
                        _buildDifficultyCard(
                          title: strings.difficultyLife,
                          sub: strings.difficultyLifeSub,
                          isSelected: selectedDifficulty == RoleplayDifficulty.life,
                          theme: theme,
                          onTap: () => setSheetState(() => selectedDifficulty = RoleplayDifficulty.life),
                        ),
                        _buildDifficultyCard(
                          title: strings.difficultyChallenge,
                          sub: strings.difficultyChallengeSub,
                          isSelected: selectedDifficulty == RoleplayDifficulty.challenge,
                          theme: theme,
                          onTap: () => setSheetState(() => selectedDifficulty = RoleplayDifficulty.challenge),
                        ),
                        _buildDifficultyCard(
                          title: strings.difficultyRandom,
                          sub: strings.difficultyRandomSub,
                          isSelected: selectedDifficulty == RoleplayDifficulty.random,
                          theme: theme,
                          onTap: () => setSheetState(() => selectedDifficulty = RoleplayDifficulty.random),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        strings.startDialogBtn,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(sheetCtx).pop();
                        _push(
                          context,
                          RoleplayScreen(
                            scenario: s,
                            subScenario: selectedSub,
                            initiator: selectedInitiator,
                            difficulty: selectedDifficulty,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDifficultyCard({
    required String title,
    required String sub,
    required bool isSelected,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 10,
                color: theme.textTheme.bodySmall?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showManualWordDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => const _ManualWordDialog(),
    );
  }

  void _showUserGuide(BuildContext context, WidgetRef ref) {
    UserGuideScreen.show(context);
  }
}

class _ManualWordDialog extends ConsumerStatefulWidget {
  const _ManualWordDialog();

  @override
  ConsumerState<_ManualWordDialog> createState() => _ManualWordDialogState();
}

class _ManualWordDialogState extends ConsumerState<_ManualWordDialog> {
  final _wordController = TextEditingController();
  final _transController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isTranslating = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _wordController.dispose();
    _transController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<String?> _performTranslation(String pl) async {
    final note = _noteController.text.trim();
    return await ref.read(translationServiceProvider).translateWord(
      pl,
      sentence: note.isNotEmpty ? note : null,
    );
  }

  Future<void> _onAutoTranslatePressed() async {
    final pl = _wordController.text.trim();
    if (pl.isEmpty || _isTranslating) return;

    setState(() => _isTranslating = true);
    try {
      final res = await _performTranslation(pl);
      if (res != null && res.trim().isNotEmpty && mounted) {
        _transController.text = res.trim();
      }
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  Future<void> _onSave() async {
    final pl = _wordController.text.trim();
    if (pl.isEmpty || _isSaving) return;

    final strings = ref.read(appStringsProvider);
    var tr = _transController.text.trim();
    bool wasAuto = false;

    setState(() => _isSaving = true);
    try {
      if (tr.isEmpty) {
        final autoRes = await _performTranslation(pl);
        if (autoRes != null && autoRes.trim().isNotEmpty) {
          tr = autoRes.trim();
          wasAuto = true;
        } else {
          tr = pl;
        }
      }

      final uk = ref.read(settingsProvider).isUk;
      final note = _noteController.text.trim();
      final added = await ref.read(databaseProvider).addManualWord(
        lemma: pl,
        translation: tr,
        uk: uk,
        example: note.isNotEmpty ? note : null,
        note: note.isNotEmpty ? note : null,
      );

      if (added) {
        AchievementService.instance.increment('words_added');
      }

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            added
                ? (wasAuto
                    ? strings.wordAutoTranslated(pl, tr)
                    : strings.wordAdded(pl))
                : strings.wordAlreadyExists(pl),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);

    return AlertDialog(
      title: Text(strings.newWordTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _wordController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: strings.plWordLabel,
                hintText: strings.plWordHint,
                border: const OutlineInputBorder(),
                suffixIcon: _isTranslating
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.auto_awesome),
                        tooltip: strings.autoTranslateTooltip,
                        onPressed: _onAutoTranslatePressed,
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _transController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: strings.translationLabel,
                hintText: strings.translationHint,
                helperText: _isTranslating ? strings.translatingAi : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: strings.contextLabel,
                hintText: strings.contextHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _onSave,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(strings.save),
        ),
      ],
    );
  }
}

class _DrillTile extends StatelessWidget {
  const _DrillTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 26, color: theme.colorScheme.primary),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

