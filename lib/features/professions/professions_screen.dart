import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../scanner/translation_service.dart' show UiLang;
import '../tutor/roleplay_screen.dart';
import '../tutor/scenarios.dart';
import 'profession_model.dart';
import 'professions_data.dart';

/// Экран «Польский для профессий» (B2C / Экспаты).
class ProfessionsScreen extends ConsumerStatefulWidget {
  const ProfessionsScreen({super.key, this.initialProfessionId});

  final String? initialProfessionId;

  static Future<void> show(BuildContext context, {String? professionId}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfessionsScreen(initialProfessionId: professionId),
      ),
    );
  }

  @override
  ConsumerState<ProfessionsScreen> createState() => _ProfessionsScreenState();
}

class _ProfessionsScreenState extends ConsumerState<ProfessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProfessionItem _selectedProfession;
  final Set<String> _addedTerms = {};
  final ScrollController _chipsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedProfession = kAllProfessions.firstWhere(
      (p) => p.id == widget.initialProfessionId,
      orElse: () => kAllProfessions.first,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chipsScrollController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    try {
      await ref.read(ttsProvider).speak(text);
    } catch (_) {}
  }

  Future<void> _addTermToDeck(ProfessionVocab v) async {
    if (_addedTerms.contains(v.termPl)) return;

    final db = ref.read(databaseProvider);
    final lang = ref.read(settingsProvider).lang;
    final isUk = lang == UiLang.uk;

    final added = await db.addScanWord(
      form: v.termPl,
      translation: v.translation(lang),
      uk: isUk,
      examplePl: v.examplePl,
    );

    if (mounted) {
      setState(() => _addedTerms.add(v.termPl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added
                ? '✅ «${v.termPl}» dodano do słownika!'
                : 'ℹ️ «${v.termPl}» już jest w słowniku.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addAllTermsToDeck(ProfessionItem item) async {
    final db = ref.read(databaseProvider);
    final lang = ref.read(settingsProvider).lang;
    final isUk = lang == UiLang.uk;
    int count = 0;

    for (final v in item.vocabulary) {
      final added = await db.addScanWord(
        form: v.termPl,
        translation: v.translation(lang),
        uk: isUk,
        examplePl: v.examplePl,
      );
      if (added) count++;
      _addedTerms.add(v.termPl);
    }

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📥 Dodano $count nowych słów z kategorii «${item.title(lang)}» do Twojego słownika!',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _openRoleplay(SubScenario sub) {
    _showRoleplayLauncherSheet(context, sub);
  }

  void _showRoleplayLauncherSheet(BuildContext context, SubScenario initialSub) {
    final theme = Theme.of(context);
    final strings = ref.read(appStringsProvider);
    final lang = ref.read(settingsProvider.select((s) => s.lang));

    SubScenario selectedSub = initialSub;
    DialogInitiator selectedInitiator = DialogInitiator.npcFirst;
    RoleplayDifficulty selectedDifficulty = RoleplayDifficulty.life;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.82,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, scrollCtrl) {
                return ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Row(
                      children: [
                        Text(_selectedProfession.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedProfession.scenario.title(lang),
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(_selectedProfession.scenario.level, style: theme.textTheme.bodySmall),
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
                    for (final sub in _selectedProfession.scenario.subScenarios)
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
                                      sub.title(lang),
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
                                  sub.description(lang),
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
                        _buildDifficultyOption(
                          title: strings.difficultyCalm,
                          sub: strings.difficultyCalmSub,
                          isSelected: selectedDifficulty == RoleplayDifficulty.calm,
                          theme: theme,
                          onTap: () => setSheetState(() => selectedDifficulty = RoleplayDifficulty.calm),
                        ),
                        _buildDifficultyOption(
                          title: strings.difficultyLife,
                          sub: strings.difficultyLifeSub,
                          isSelected: selectedDifficulty == RoleplayDifficulty.life,
                          theme: theme,
                          onTap: () => setSheetState(() => selectedDifficulty = RoleplayDifficulty.life),
                        ),
                        _buildDifficultyOption(
                          title: strings.difficultyChallenge,
                          sub: strings.difficultyChallengeSub,
                          isSelected: selectedDifficulty == RoleplayDifficulty.challenge,
                          theme: theme,
                          onTap: () => setSheetState(() => selectedDifficulty = RoleplayDifficulty.challenge),
                        ),
                        _buildDifficultyOption(
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
                        backgroundColor: AppTheme.primaryCarmine,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(sheetCtx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => RoleplayScreen(
                              scenario: _selectedProfession.scenario,
                              subScenario: selectedSub,
                              initiator: selectedInitiator,
                              difficulty: selectedDifficulty,
                            ),
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

  Widget _buildDifficultyOption({
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const Text('💼', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                strings.professionsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Горизонтальный скролл чипов категорий профессий со стрелками назад и вперед
          SizedBox(
            height: 52,
            child: Row(
              children: [
                // Стрелочка влево (скролл назад)
                InkWell(
                  onTap: () {
                    if (_chipsScrollController.hasClients) {
                      final current = _chipsScrollController.offset;
                      final target = (current - 160).clamp(0.0, _chipsScrollController.position.maxScrollExtent);
                      _chipsScrollController.animateTo(
                        target,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryCarmine.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 13,
                      color: AppTheme.primaryCarmine,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: _chipsScrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    scrollDirection: Axis.horizontal,
                    itemCount: kAllProfessions.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = kAllProfessions[index];
                      final isSelected = item.id == _selectedProfession.id;

                      return FilterChip(
                        avatar: Text(item.emoji, style: const TextStyle(fontSize: 16)),
                        label: Text(item.title(lang)),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryCarmine.withValues(alpha: 0.15),
                        checkmarkColor: AppTheme.primaryCarmine,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryCarmine
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedProfession = item);
                          }
                        },
                      );
                    },
                  ),
                ),
                // Стрелочка вправо (скролл вперед)
                InkWell(
                  onTap: () {
                    if (_chipsScrollController.hasClients) {
                      final current = _chipsScrollController.offset;
                      final max = _chipsScrollController.position.maxScrollExtent;
                      final target = (current + 160).clamp(0.0, max);
                      _chipsScrollController.animateTo(
                        target,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryCarmine.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: AppTheme.primaryCarmine,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Карточка выбранной профессии
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryCarmine.withValues(alpha: 0.25),
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
                    child: Text(
                      _selectedProfession.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedProfession.title(lang),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedProfession.desc(lang),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: strings.professionsAddAllTooltip,
                    onPressed: () => _addAllTermsToDeck(_selectedProfession),
                    icon: const Icon(Icons.bookmark_add, size: 20),
                  ),
                ],
              ),
            ),
          ),
          // Вкладки: Словарь / Диалоги
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryCarmine,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: AppTheme.primaryCarmine,
            tabs: [
              Tab(
                icon: const Icon(Icons.menu_book_outlined, size: 20),
                text: strings.professionsTabVocab,
              ),
              Tab(
                icon: const Icon(Icons.forum_outlined, size: 20),
                text: strings.professionsTabDialogs,
              ),
            ],
          ),
          // Контент вкладок
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVocabTab(theme, lang, strings),
                _buildDialogsTab(theme, lang, strings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Вкладка словаря
  // ---------------------------------------------------------------------------
  Widget _buildVocabTab(ThemeData theme, UiLang lang, AppStrings strings) {
    final vocabList = _selectedProfession.vocabulary;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: vocabList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = vocabList[index];
        final isAdded = _addedTerms.contains(item.termPl);

        return Card(
          elevation: 0,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.termPl,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryCarmine,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.translation(lang),
                            style: TextStyle(
                              fontSize: 13.5,
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20),
                      tooltip: 'Odsłuchaj',
                      onPressed: () => _speak(item.termPl),
                    ),
                    IconButton(
                      icon: Icon(
                        isAdded ? Icons.check_circle : Icons.bookmark_add_outlined,
                        color: isAdded ? Colors.green : theme.colorScheme.primary,
                        size: 20,
                      ),
                      tooltip: strings.isPl
                          ? 'Dodaj do słownika'
                          : (strings.isUk
                              ? 'Додати до словника'
                              : 'Добавить в словарь'),
                      onPressed: () => _addTermToDeck(item),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '„${item.examplePl}”',
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _speak(item.examplePl),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.volume_up_outlined, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.example(lang),
                        style: TextStyle(
                          fontSize: 12,
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
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Вкладка ролевых диалогов
  // ---------------------------------------------------------------------------
  Widget _buildDialogsTab(ThemeData theme, UiLang lang, AppStrings strings) {
    final subList = _selectedProfession.scenario.subScenarios;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: subList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sub = subList[index];

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppTheme.primaryCarmine.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedProfession.scenario.level,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCarmine,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sub.title(lang),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  sub.description(lang),
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (sub.vocab.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final v in sub.vocab)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            v,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryCarmine,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _openRoleplay(sub),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: Text(
                      strings.professionsStartRoleplayBtn,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
