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
import '../scanner/translation_service.dart';
import '../tutor/roleplay_screen.dart';
import '../tutor/scenarios.dart';
import '../wrapped/monthly_wrapped_screen.dart';

/// Главный экран: тренажёр обучения (повторение, игры, ролевые диалоги).
class LearnDashboard extends ConsumerWidget {
  const LearnDashboard({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
            children: [
              for (final s in scenarios)
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

  void _showManualWordDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => const _ManualWordDialog(),
    );
  }

  void _showUserGuide(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) {
        return Consumer(
          builder: (context, ref, _) {
            final lang = ref.watch(settingsProvider.select((s) => s.lang));
            final isUk = lang == UiLang.uk;
            final isPl = lang == UiLang.pl;
            final theme = Theme.of(context);

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, scrollCtrl) {
                return ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                isPl
                                    ? '📖 Instrukcja użytkownika'
                                    : (isUk ? '📖 Керівництво користувача' : '📖 Руководство пользователя'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(sheetCtx).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<UiLang>(
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            segments: const [
                              ButtonSegment(
                                value: UiLang.uk,
                                label: Text('🇺🇦 Українська', style: TextStyle(fontSize: 12)),
                              ),
                              ButtonSegment(
                                value: UiLang.ru,
                                label: Text('🇷🇺 Русский', style: TextStyle(fontSize: 12)),
                              ),
                              ButtonSegment(
                                value: UiLang.pl,
                                label: Text('🇵🇱 Polski', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                            selected: {lang},
                            onSelectionChanged: (s) =>
                                ref.read(settingsProvider.notifier).setLang(s.first),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Карточка 1: Навчання & SRS
                    _GuideCard(
                      icon: Icons.psychology,
                      color: Colors.blue,
                      title: isPl
                          ? '1. 🧠 Nauka i algorytm SRS'
                          : (isUk ? '1. 🧠 Навчання та алгоритм SRS' : '1. 🧠 Обучение и алгоритм SRS'),
                      body: isPl
                          ? '• Blok dnia działa według algorytmu SM-2: słowa są powtarzane w odstępach 1, 6, 14 dni.\n'
                            '• Przycisk «✍️ Dodaj słowo ręcznie» umożliwia natychmiastowe tłumaczenie i dodawanie słów.\n'
                            '• Treningi «Końcówki», «Słuch», «Liczby» i «Fałszywi przyjaciele» doskonalą odmianę i słuch.'
                          : (isUk
                              ? '• Картка дня працює за алгоритмом SM-2: слова пропонуються для повторення через 1, 6, 14 днів, запобігаючи забуванню.\n'
                                '• Кнопка «✍️ Ввести слово вручну» дозволяє зберегти будь-яке почуте слово з контекстом та автоперекладом.\n'
                                '• Тренажери «Закінчення», «Аудіо», «Числа» та «Хибні друзі» тренують відмінки, слух та слова-обманки.'
                              : '• Блок дня работает по алгоритму SM-2: слова повторяются с интервалами 1, 6, 14 дней для надежного закрепления.\n'
                                '• Кнопка «✍️ Ввести слово вручную» позволяет сохранить любое незнакомое слово с автопереводом.\n'
                                '• Тренажеры «Окончания», «Аудио», «Числа» и «Ложные друзья» тренируют падежи, слух и слова-ловушки.'),
                    ),
                    const SizedBox(height: 12),

                    // Карточка 2: Рольові діалоги
                    _GuideCard(
                      icon: Icons.forum,
                      color: const Color(0xFF8C1D2F),
                      title: isPl
                          ? '2. 💬 Dialogi sytuacyjne AI'
                          : (isUk ? '2. 💬 Рольові діалоги з ШІ' : '2. 💬 Ролевые диалоги с ИИ'),
                      body: isPl
                          ? '• Kasia odgrywa role w 6 realnych sytuacjach (sklep, urząd, kawiarnia, przychodnia, dworzec, wynajem).\n'
                            '• Ikona 🌐 otwiera tłumaczenie wypowiedzi.\n'
                            '• Podpowiedź zawiera gotową odpowiedź, wymowę 🔊 oraz tłumaczenie.'
                          : (isUk
                              ? '• Тьютор Kasia грає жителя Польщі в 6 життєвих сценаріях (магазин, ужонд, кафе, лікар, вокзал, оренда житла).\n'
                                '• Значок 🌐 біля кожної репліки відкриває синхронний переклад.\n'
                                '• Підказка (Podpowiedź) містить польську фразу, озвучку 🔊 та переклад. Клік вставляє її в рядок введення.\n'
                                '• Підтримується відповідь голосом через мікрофон.'
                              : '• Тьютор Kasia играет жителя Польши в 6 реальных ситуациях (магазин, ужонд, кафе, поликлиника, вокзал, аренда жилья).\n'
                                '• Кнопка 🌐 возле каждой фразы открывает перевод.\n'
                                '• Плашка «Подсказка» содержит польский ответ, озвучку 🔊 и перевод. Клик вставляет её в строку ввода.\n'
                                '• Поддерживается ответ голосом через микрофон.'),
                    ),
                    const SizedBox(height: 12),

                    // Карточка 3: Перекладач
                    _GuideCard(
                      icon: Icons.document_scanner,
                      color: Colors.teal,
                      title: isPl
                          ? '3. 📷 Tłumacz i skaner'
                          : (isUk ? '3. 📷 Багатофункціональний Перекладач' : '3. 📷 Многофункциональный Переводчик'),
                      body: isPl
                          ? '• Aparat: natychmiastowe rozpoznawanie tekstu z tablic, paragonów i pism.\n'
                            '• Pliki/PDF: import zdjęć oraz dokumentów PDF z podglądem stron.\n'
                            '• Inteligentne tłumaczenie AI oraz dodawanie słów kluczowych.'
                          : (isUk
                              ? '• Режим 📷 Камера: миттєвий захват польського тексту з вивісок, чеків, документів через ML Kit.\n'
                                '• Режим 📁 Файл/PDF: імпорт фото та багатосторінкових PDF-документів із гортанням сторінок.\n'
                                '• Режим ✍️ Текст: швидкий переклад будь-яких введених фраз через сучасний ШІ.\n'
                                '• Кнопка 📥 «Додати всі слова в словник» зберігає всі незнайомі слова з документа в колоду.'
                              : '• Режим 📷 Камера: мгновенный захват польского текста с вывесок, чеков и писем через ML Kit.\n'
                                '• Режим 📁 Файл/PDF: импорт фото и многостраничных PDF-документов с перелистыванием страниц.\n'
                                '• Режим ✍️ Текст: быстрый перевод любых введенных фраз через современный ИИ.\n'
                                '• Кнопка 📥 «Добавить все слова в словарь» сохраняет все слова документа в колоду повторения.'),
                    ),
                    const SizedBox(height: 12),

                    // Карточка 4: Разбор польских документов
                    _GuideCard(
                      icon: Icons.gavel_rounded,
                      color: AppTheme.primaryCarmine,
                      title: isPl
                          ? '4. ⚖️ Inteligentna analiza dokumentów'
                          : (isUk ? '4. ⚖️ Розумний аналіз польських документів' : '4. ⚖️ Умный разбор польских документов'),
                      body: isPl
                          ? '• Skieruj aparat lub zaimportuj umowę (o pracę, najmu), pismo z urzędu lub ZUS.\n'
                            '• Naciśnij «⚖️ Analiza dokumentu (AI)» — asystent prawny wyjaśni sedno prostym językiem.\n'
                            '• Wykrywanie ukrytych ryzyk, kar umownych, terminów wypowiedzenia oraz kwot brutto/netto.\n'
                            '• Lista wymaganych działań z terminami oraz dodawanie oficjalnych terminów do słownika.'
                          : (isUk
                              ? '• Сфотографуйте або завантажте договір (найму, umowa o pracę/zlecenie), лист із ZUS чи податкової.\n'
                                '• Натисніть «⚖️ Аналіз документа (ШІ)» — юридичний асистент розкладе суть простою мовою.\n'
                                '• Виявлення прихованих ризиків, штрафів, строків розірвання та фінансових зобов\'язань.\n'
                                '• Покроковий план дій із дедлайнами та пакетне додавання офіційних термінів у словник.'
                              : '• Сфотографируйте или загрузите договор (аренды, трудовой), письмо из ZUS или налоговой (Urząd).\n'
                                '• Нажмите «⚖️ Анализ документа (ИИ)» — юридический ассистент разложит суть простыми словами.\n'
                                '• Выявление скрытых рисков, штрафов, сроков расторжения и финансовых обязательств.\n'
                                '• Пошаговый план действий с дедлайнами и пакетное добавление официальных терминов в словарь.'),
                    ),
                    const SizedBox(height: 12),

                    // Карточка 5: Словник
                    _GuideCard(
                      icon: Icons.menu_book,
                      color: Colors.orange,
                      title: isPl
                          ? '5. 📚 Słownik i ustawienia'
                          : (isUk ? '5. 📚 Словник та Налаштування' : '5. 📚 Словарь и Настройки'),
                      body: isPl
                          ? '• Przeglądaj karty słów, statusy nauki i przykłady.\n'
                            '• Wymowa słów jednym dotknięciem syntezatorem Google TTS.\n'
                            '• W Ustawieniach skonfigurujesz bramkę AI i język aplikacji.'
                          : (isUk
                              ? '• Переглядайте картки слів, статус вивчення, транскрипцію та приклади.\n'
                                '• Озвучування слів в один дотик рідним синтезатором Google TTS.\n'
                                '• У Налаштуваннях підключається власний шлюз штучного інтелекту.'
                              : '• Просматривайте карточки слов, интервалы повторения, транскрипцию и примеры.\n'
                                '• Озвучивание слов в одно касание синтезатором Google TTS.\n'
                                '• В Настройках настраивается ИИ-шлюз и язык интерфейса.'),
                    ),
                    const SizedBox(height: 12),

                    // Карточка 6: Польский паспорт
                    _GuideCard(
                      icon: Icons.badge_outlined,
                      color: Colors.redAccent,
                      title: isPl
                          ? '6. 🇵🇱 Polski Paszport'
                          : (isUk ? '6. 🇵🇱 Польський паспорт' : '6. 🇵🇱 Польский паспорт'),
                      body: isPl
                          ? '• Kliknij ikonę paszportu na górnym pasku, aby zobaczyć swoje pieczęcie.\n'
                            '• Zdobywaj osiągnięcia za słowa, skany, dialogi i serie dni (streak).\n'
                            '• Odblokuj wszystkie 15 pieczęci i zdobądź oficjalny Polski Paszport!'
                          : (isUk
                              ? '• Натисніть іконку паспорта у верхній панелі, щоб переглянути свої печатки.\n'
                                '• Отримуйте досягнення за вивчені слова, скани, діалоги та дні поспіль (streak).\n'
                                '• Розблокуйте всі 15 печаток та отримайте почесний Польський Паспорт!'
                              : '• Нажмите иконку паспорта в верхней панели, чтобы увидеть свои печати.\n'
                                '• Получайте достижения за слова, сканы, диалоги и серии дней (streak).\n'
                                '• Разблокируйте все 15 печатей и получите почётный Польский Паспорт!'),
                    ),
                    const SizedBox(height: 12),

                    // Карточка 7: Мой польский за месяц
                    _GuideCard(
                      icon: Icons.insights_rounded,
                      color: AppTheme.primaryCarmine,
                      title: isPl
                          ? '7. 📊 Mój polski w tym miesiącu'
                          : (isUk ? '7. 📊 Мій польський за місяць' : '7. 📊 Мой польский за месяц'),
                      body: isPl
                          ? '• Kliknij ikonę 📊 na górnym pasku lub baner na ekranie głównym.\n'
                            '• Sprawdź liczbę opanowanych słów, poziom CEFR, dialogi oraz analizy pism.\n'
                            '• Otrzymaj swój comiesięczny tytuł językowy (np. „Warszawski Negocjator”, „Leksykalny Snajper”).\n'
                            '• Skopiuj oficjalne podsumowanie i udostępnij znajomym jednym kliknięciem!'
                          : (isUk
                              ? '• Натисніть іконку 📊 на верхній панелі або банер на головному екрані.\n'
                                '• Переглядайте кількість вивчених слів, рівень CEFR, діалоги та аналізи документів.\n'
                                '• Отримуйте персональний щомісячний мовний титул (наприклад, «Варшавський Переговорник»).\n'
                                '• Скопіюйте офіційні підсумки та поділіться з друзями в один дотик!'
                              : '• Нажмите иконку 📊 в верхней панели или баннер на главном экране.\n'
                                '• Просматривайте число выученных слов, уровень CEFR, диалоги и анализы документов.\n'
                                '• Получайте персональный ежемесячный языковой титул (например, «Варшавский Переговорщик»).\n'
                                '• Скопируйте официальные итоги и делитесь с друзьями в одно касание!'),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      child: Text(
                        isPl
                            ? 'Rozumiem, do nauki! 🚀'
                            : (isUk ? 'Зрозуміло, до навчання! 🚀' : 'Понятно, к обучению! 🚀'),
                      ),
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

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(fontSize: 13, height: 1.45),
            ),
          ],
        ),
      ),
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

