import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../dictation/dictation_screen.dart';
import '../episodes/episodes_screen.dart';
import '../exam/exam_hub_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../passport/passport_screen.dart';
import '../primer/primer_screen.dart';
import '../professions/professions_screen.dart';
import '../scanner/translation_service.dart' show UiLang;
import '../wrapped/monthly_wrapped_screen.dart';
import 'user_guide_data.dart';

/// Экран подробного руководства пользователя на 3 языках
class UserGuideScreen extends ConsumerStatefulWidget {
  const UserGuideScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const UserGuideScreen(),
      ),
    );
  }

  @override
  ConsumerState<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends ConsumerState<UserGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  UiLang? _overrideLang;
  String _searchQuery = '';
  final Set<String> _expandedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleNavigation(String action) {
    switch (action) {
      case 'primer':
        PrimerScreen.show(context);
      case 'onboarding':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const OnboardingScreen(isRestart: true),
          ),
        );
      case 'dictation':
        DictationScreen.show(context);
      case 'passport':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const PassportScreen(),
          ),
        );
      case 'wrapped':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const MonthlyWrappedScreen(),
          ),
        );
      case 'professions':
        ProfessionsScreen.show(context);
      case 'episodes':
        EpisodesScreen.show(context);
      case 'exam':
        ExamHubScreen.show(context);
      case 'translator':
        ref.read(currentTabProvider.notifier).setTab(1);
        Navigator.of(context).popUntil((route) => route.isFirst);
      case 'dictionary':
        ref.read(currentTabProvider.notifier).setTab(2);
        Navigator.of(context).popUntil((route) => route.isFirst);
      case 'settings':
        ref.read(currentTabProvider.notifier).setTab(3);
        Navigator.of(context).popUntil((route) => route.isFirst);
      default:
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final currentAppLang = ref.watch(settingsProvider.select((s) => s.lang));
    final activeLang = _overrideLang ?? currentAppLang;

    final filtered = kAllGuideSections.where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return item.title(activeLang).toLowerCase().contains(q) ||
          item.summary(activeLang).toLowerCase().contains(q) ||
          item.content(activeLang).toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const Text('📖', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                strings.userGuideTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Шапка с переключателем языка руководства
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _langButton(UiLang.uk, '🇺🇦 Українська', activeLang),
                    const SizedBox(width: 6),
                    _langButton(UiLang.ru, '🇷🇺 Русский', activeLang),
                    const SizedBox(width: 6),
                    _langButton(UiLang.pl, '🇵🇱 Polski', activeLang),
                  ],
                ),
                const SizedBox(height: 10),
                // Поле поиска
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: strings.userGuideSearchHint,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ],
            ),
          ),

          // Список глав руководства
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      activeLang == UiLang.pl
                          ? 'Brak wyników wyszukiwania'
                          : (activeLang == UiLang.uk
                              ? 'Нічого не знайдено'
                              : 'Ничего не найдено'),
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isExpanded = _expandedIds.contains(item.id);

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: isExpanded ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isExpanded
                                ? AppTheme.primaryCarmine.withValues(alpha: 0.35)
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expandedIds.remove(item.id);
                                  } else {
                                    _expandedIds.add(item.id);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title(activeLang),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            item.summary(activeLang),
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.content(activeLang),
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        height: 1.45,
                                      ),
                                    ),
                                    if (item.routeAction != null) ...[
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 44,
                                        child: FilledButton.tonalIcon(
                                          style: FilledButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () => _handleNavigation(item.routeAction!),
                                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                                          label: Text(
                                            strings.userGuideOpenSection,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _langButton(UiLang lang, String label, UiLang current) {
    final isSelected = lang == current;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _overrideLang = lang),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryCarmine : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryCarmine
                  : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
