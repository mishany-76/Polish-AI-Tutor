import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_shell.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import 'user_profile.dart';

/// Интерактивный онбординг-знакомство с тьютором Kasia на 60 секунд.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.isRestart = false});

  final bool isRestart;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _currentPage = 0;
  PolishLevel _selectedLevel = PolishLevel.starter;
  PolishGoal _selectedGoal = PolishGoal.daily;
  bool _firstPhraseCompleted = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    if (profile.name.isNotEmpty) {
      _nameController.text = profile.name;
    }
    _selectedLevel = profile.level;
    _selectedGoal = profile.goal;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    try {
      await ref.read(ttsProvider).speak(text);
    } catch (_) {}
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final name = _nameController.text.trim();
    await ref.read(userProfileProvider.notifier).completeOnboarding(
          name: name.isNotEmpty ? name : 'Przyjaciel',
          level: _selectedLevel,
          goal: _selectedGoal,
        );

    // Добавляем стартовую фразу в словарь
    try {
      final db = ref.read(databaseProvider);
      final isUk = ref.read(settingsProvider).isUk;
      await db.addScanWord(
        form: 'miło mi',
        translation: isUk ? 'приємно познайомитися' : 'приятно познакомиться',
        uk: isUk,
        examplePl: 'Miło mi Cię poznać!',
      );
    } catch (_) {}

    if (!mounted) return;

    if (widget.isRestart) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AppShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇵🇱', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              strings.isPl
                  ? 'Poznaj Kasię'
                  : (strings.isUk ? 'Знайомство з Kasią' : 'Знакомство с Kasią'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              strings.onboardingSkip,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Прогресс-индикатор (4 шага)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(4, (index) {
                  final active = index <= _currentPage;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.primaryCarmine
                            : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildStep1Name(theme, strings),
                  _buildStep2Level(theme, strings),
                  _buildStep3Goal(theme, strings),
                  _buildStep4FirstPhrase(theme, strings),
                ],
              ),
            ),
            // Нижняя кнопка «Далее» / «Завершить»
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _nextPage,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryCarmine,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == 3
                        ? strings.onboardingFinish
                        : strings.onboardingNext,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Шаг 1: Приветствие и имя
  // ---------------------------------------------------------------------------
  Widget _buildStep1Name(ThemeData theme, AppStrings strings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildKasiaSpeechBubble(
            polishText:
                'Cześć! Jestem Kasia — Twój osobisty nauczyciel języka polskiego 🇵🇱. Jak masz na imię?',
            translation: strings.onboardingStep1Prompt,
          ),
          const SizedBox(height: 28),
          Text(
            strings.onboardingStep1Title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
            decoration: InputDecoration(
              hintText: strings.onboardingStep1Hint,
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _nameController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.favorite, size: 16),
                label: Text(strings.onboardingStep1QuickName),
                onPressed: () {
                  _nameController.text = strings.onboardingStep1QuickName;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Шаг 2: Уровень
  // ---------------------------------------------------------------------------
  Widget _buildStep2Level(ThemeData theme, AppStrings strings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildKasiaSpeechBubble(
            polishText: 'Na jakim poziomie jest teraz Twój język polski?',
            translation: strings.onboardingStep2Prompt,
          ),
          const SizedBox(height: 24),
          _buildOptionCard(
            title: strings.onboardingLevelStarterTitle,
            subtitle: strings.onboardingLevelStarterDesc,
            icon: Icons.eco_outlined,
            selected: _selectedLevel == PolishLevel.starter,
            badge: '🟢 A0',
            onTap: () => setState(() => _selectedLevel = PolishLevel.starter),
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            title: strings.onboardingLevelBasicTitle,
            subtitle: strings.onboardingLevelBasicDesc,
            icon: Icons.chat_bubble_outline,
            selected: _selectedLevel == PolishLevel.basic,
            badge: '🟡 A1–A2',
            onTap: () => setState(() => _selectedLevel = PolishLevel.basic),
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            title: strings.onboardingLevelInterTitle,
            subtitle: strings.onboardingLevelInterDesc,
            icon: Icons.military_tech_outlined,
            selected: _selectedLevel == PolishLevel.intermediate,
            badge: '🔴 B1+',
            onTap: () =>
                setState(() => _selectedLevel = PolishLevel.intermediate),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Шаг 3: Цель
  // ---------------------------------------------------------------------------
  Widget _buildStep3Goal(ThemeData theme, AppStrings strings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildKasiaSpeechBubble(
            polishText: 'Jaki jest Twój główny cel nauki w Polsce?',
            translation: strings.onboardingStep3Prompt,
          ),
          const SizedBox(height: 24),
          _buildOptionCard(
            title: strings.onboardingGoalDailyTitle,
            subtitle: strings.onboardingGoalDailyDesc,
            icon: Icons.shopping_bag_outlined,
            selected: _selectedGoal == PolishGoal.daily,
            badge: '🛒 Byt',
            onTap: () => setState(() => _selectedGoal = PolishGoal.daily),
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            title: strings.onboardingGoalDocsTitle,
            subtitle: strings.onboardingGoalDocsDesc,
            icon: Icons.description_outlined,
            selected: _selectedGoal == PolishGoal.documents,
            badge: '📄 Urząd',
            onTap: () => setState(() => _selectedGoal = PolishGoal.documents),
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            title: strings.onboardingGoalWorkTitle,
            subtitle: strings.onboardingGoalWorkDesc,
            icon: Icons.work_outline,
            selected: _selectedGoal == PolishGoal.work,
            badge: '💼 Praca',
            onTap: () => setState(() => _selectedGoal = PolishGoal.work),
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            title: strings.onboardingGoalExamTitle,
            subtitle: strings.onboardingGoalExamDesc,
            icon: Icons.verified_outlined,
            selected: _selectedGoal == PolishGoal.exam,
            badge: '🏆 B1',
            onTap: () => setState(() => _selectedGoal = PolishGoal.exam),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Шаг 4: Первая победа (Первая фраза & Открытие паспорта)
  // ---------------------------------------------------------------------------
  Widget _buildStep4FirstPhrase(ThemeData theme, AppStrings strings) {
    const phrasePl = 'Miło mi Cię poznać!';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildKasiaSpeechBubble(
            polishText:
                'Wspaniale! Nauczmy się Twojej pierwszej frazy z poprawnym akcentem:',
            translation: strings.onboardingStep4Prompt,
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppTheme.primaryCarmine.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('🇵🇱', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    phrasePl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCarmine,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.isUk
                        ? 'Приємно познайомитися!'
                        : (strings.isPl
                            ? 'Bardzo mi miło!'
                            : 'Приятно познакомиться!'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () => _speak(phrasePl),
                    icon: const Icon(Icons.volume_up, size: 20),
                    label: Text(
                      strings.isPl
                          ? 'Posłuchaj wymowy 🔊'
                          : (strings.isUk
                              ? 'Послухати вимову 🔊'
                              : 'Послушать произношение 🔊'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _firstPhraseCompleted
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppTheme.primaryCarmine,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  _speak(phrasePl);
                  setState(() => _firstPhraseCompleted = true);
                },
                icon: const Icon(Icons.handshake_outlined,
                    color: AppTheme.primaryCarmine),
                label: Text(
                  strings.onboardingStep4Action,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCarmine,
                  ),
                ),
              ),
            ),
            secondChild: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.onboardingStep4Success,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Виджет реплики Kasia
  // ---------------------------------------------------------------------------
  Widget _buildKasiaSpeechBubble({
    required String polishText,
    required String translation,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryCarmine.withValues(alpha: 0.12),
            child: const Text('👩‍🏫', style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Kasia',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.primaryCarmine,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.volume_up, size: 20),
                      tooltip: 'Odsłuchaj',
                      onPressed: () => _speak(polishText),
                    ),
                  ],
                ),
                Text(
                  polishText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  translation,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Карточка выбора опции
  // ---------------------------------------------------------------------------
  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required String badge,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryCarmine.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppTheme.primaryCarmine
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primaryCarmine
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? AppTheme.primaryCarmine
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryCarmine.withValues(alpha: 0.15)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? AppTheme.primaryCarmine
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
