import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';

// Helper: get localized title/desc from Achievement based on lang
String _achTitle(Achievement a, AppStrings s) {
  if (s.isPl) return a.titlePl;
  if (s.isUk) return a.titleUk;
  return a.titleRu;
}

String _achDesc(Achievement a, AppStrings s) {
  if (s.isPl) return a.descPl;
  if (s.isUk) return a.descUk;
  return a.descRu;
}

/// Экран «Польский паспорт» — визуальная коллекция достижений.
class PassportScreen extends ConsumerWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final unlockedAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.passportTitle),
        actions: [
          IconButton(
            tooltip: strings.passportShareTooltip,
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _sharePassport(context, ref, strings),
          ),
        ],
      ),
      body: unlockedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (unlocked) {
          final total = kAllAchievements.length;
          final obtained = unlocked.length;

          return Column(
            children: [
              // --- Заголовок паспорта ---
              _PassportHeader(
                obtained: obtained,
                total: total,
                strings: strings,
              ),
              // --- Сетка достижений ---
              Expanded(
                child: _PassportGrid(
                  unlocked: unlocked,
                  strings: strings,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _sharePassport(
      BuildContext context, WidgetRef ref, AppStrings strings) async {
    // Показать снэкбар с подсказкой (полноценный share требует плагина,
    // пока делаем скриншот через RepaintBoundary → Clipboard подсказку)
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.passportShareHint),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Заголовок — паспортная «обложка» с прогресс-баром
// ---------------------------------------------------------------------------

class _PassportHeader extends StatelessWidget {
  const _PassportHeader({
    required this.obtained,
    required this.total,
    required this.strings,
  });

  final int obtained;
  final int total;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total > 0 ? obtained / total : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryCarmine,
            AppTheme.primaryCarmine.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryCarmine.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🇵🇱', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.passportTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      strings.passportSubtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$obtained / $total',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            strings.passportProgressLabel(obtained, total),
            style:
                theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Сетка достижений — «печати в паспорте»
// ---------------------------------------------------------------------------

class _PassportGrid extends ConsumerWidget {
  const _PassportGrid({
    required this.unlocked,
    required this.strings,
  });

  final Set<String> unlocked;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: kAllAchievements.length,
      itemBuilder: (context, i) {
        final ach = kAllAchievements[i];
        final isUnlocked = unlocked.contains(ach.id);
        return _StampCard(
          achievement: ach,
          isUnlocked: isUnlocked,
          strings: strings,
          onTap: () => _showDetail(context, ach, isUnlocked, strings),
        );
      },
    );
  }

  void _showDetail(BuildContext context, Achievement ach, bool isUnlocked,
      AppStrings strings) {
    final title = _achTitle(ach, strings);
    final desc = _achDesc(ach, strings);

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${ach.emoji}  $title',
            style: const TextStyle(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              desc,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.green.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isUnlocked
                    ? strings.achievementUnlocked
                    : strings.achievementLocked,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Одна «печать» — карточка достижения
// ---------------------------------------------------------------------------

class _StampCard extends StatelessWidget {
  const _StampCard({
    required this.achievement,
    required this.isUnlocked,
    required this.strings,
    required this.onTap,
  });

  final Achievement achievement;
  final bool isUnlocked;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppTheme.primaryPastel
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? AppTheme.primaryCarmine.withValues(alpha: 0.35)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isUnlocked ? 1.5 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Эмодзи-печать
            ColorFiltered(
              colorFilter: isUnlocked
                  ? const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply)
                  : const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
                    ]),
              child: Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: isUnlocked ? 34 : 28,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Название достижения
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                _achTitle(achievement, strings),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Метка статуса
            if (isUnlocked)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✓',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCarmine,
                  ),
                ),
              )
            else
              Text(
                '🔒',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Всплывающее уведомление о новом достижении
// ---------------------------------------------------------------------------

/// Показывает тост-уведомление о новом достижении.
/// Вызывается из любого экрана при получении нового достижения.
void showAchievementToast(BuildContext context, Achievement ach,
    AppStrings strings) {
  if (!context.mounted) return;
  HapticFeedback.mediumImpact();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppTheme.primaryCarmine,
      content: Row(
        children: [
          Text(ach.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.achievementToastTitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _achTitle(ach, strings),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
