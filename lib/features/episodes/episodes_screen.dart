import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../scanner/translation_service.dart' show UiLang;
import '../tutor/roleplay_screen.dart';
import 'episode_model.dart';
import 'episodes_data.dart';
import 'episodes_service.dart';

/// Главный экран интерактивного сериала «Живые эпизоды: Жизнь в Польше»
class EpisodesScreen extends ConsumerStatefulWidget {
  const EpisodesScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const EpisodesScreen(),
      ),
    );
  }

  @override
  ConsumerState<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends ConsumerState<EpisodesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));
    final episodesService = ref.watch(episodesServiceProvider);

    final completedCount = episodesService.completedEpisodesCount;
    final totalStars = episodesService.totalStarsCount;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const Text('🎬', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                strings.episodesTitle,
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Баннер прогресса сезона
          Container(
            padding: const EdgeInsets.all(16),
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
                    Flexible(
                      child: Text(
                        strings.episodesSeason1,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCarmine,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'STORY MODE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  strings.episodesSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            '$completedCount / ${kAllEpisodes.length} ${strings.isPl ? 'odc.' : (strings.isUk ? 'серій' : 'серий')}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text(
                            '$totalStars / 15 ⭐',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Список серий
          for (final ep in kAllEpisodes) ...[
            _EpisodeCard(
              episode: ep,
              progress: episodesService.getProgress(ep.id, ep.number),
              lang: lang,
              onTap: () async {
                final isUnlocked = episodesService.isEpisodeUnlocked(ep.id, ep.number);
                if (!isUnlocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        strings.isPl
                            ? '🔒 Najpierw ukończ poprzedni odcinek!'
                            : (strings.isUk
                                ? '🔒 Спочатку пройдіть попередню серію!'
                                : '🔒 Сначала пройдите предыдущую серию!'),
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EpisodeDetailScreen(episode: ep),
                  ),
                );
                if (mounted) setState(() {});
              },
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

/// Карточка серии в общем списке
class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({
    required this.episode,
    required this.progress,
    required this.lang,
    required this.onTap,
  });

  final EpisodeItem episode;
  final EpisodeProgress progress;
  final UiLang lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = !progress.isUnlocked;
    final isCompleted = progress.isCompleted;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isLocked ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.35)
              : (isLocked
                  ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
                  : AppTheme.primaryCarmine.withValues(alpha: 0.25)),
          width: isCompleted ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: isLocked
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
              : theme.colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? Colors.grey.withValues(alpha: 0.15)
                          : AppTheme.primaryCarmine.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      isLocked ? '🔒' : episode.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : (isLocked
                                        ? Colors.grey.withValues(alpha: 0.2)
                                        : AppTheme.primaryCarmine.withValues(alpha: 0.12)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ODCINEK ${episode.number}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? Colors.green.shade800
                                      : (isLocked ? Colors.grey : AppTheme.primaryCarmine),
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (isCompleted)
                              Row(
                                children: [
                                  for (int i = 0; i < progress.stars; i++)
                                    const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          episode.title(lang),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? theme.colorScheme.onSurfaceVariant : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          episode.tagline(lang),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _metaChip(context, Icons.timer_outlined, episode.duration),
                  _metaChip(context, Icons.bar_chart_rounded, 'CEFR ${episode.level}'),
                  _metaChip(
                    context,
                    Icons.layers_outlined,
                    '${episode.scenes.length} ${lang == UiLang.uk ? 'сцени' : (lang == UiLang.pl ? 'sceny' : 'сцены')}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: isLocked
                    ? OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: onTap,
                        icon: const Icon(Icons.lock_outline, size: 16),
                        label: Text(
                          lang == UiLang.pl
                              ? 'Zablokowane'
                              : (lang == UiLang.uk ? 'Заблоковано' : 'Заблокировано'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )
                    : FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: isCompleted ? Colors.green.shade700 : AppTheme.primaryCarmine,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: onTap,
                        icon: Icon(isCompleted ? Icons.replay : Icons.play_arrow_rounded, size: 18),
                        label: Text(
                          isCompleted
                              ? (lang == UiLang.pl
                                  ? 'Powtórz odcinek'
                                  : (lang == UiLang.uk ? 'Пройти ще раз' : 'Пройти повторно'))
                              : (lang == UiLang.pl
                                  ? 'Rozpocznij odcinek'
                                  : (lang == UiLang.uk ? 'Розпочати серію' : 'Начать серию')),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaChip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Экран деталей серии (Брифинг, словарь выживания, интерактивные сцены)
class EpisodeDetailScreen extends ConsumerStatefulWidget {
  const EpisodeDetailScreen({super.key, required this.episode});

  final EpisodeItem episode;

  @override
  ConsumerState<EpisodeDetailScreen> createState() => _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends ConsumerState<EpisodeDetailScreen> {
  final Set<String> _addedTerms = {};

  Future<void> _speak(String text) async {
    try {
      await ref.read(ttsProvider).speak(text);
    } catch (_) {}
  }

  Future<void> _addAllTermsToDeck() async {
    final db = ref.read(databaseProvider);
    final lang = ref.read(settingsProvider).lang;
    final isUk = lang == UiLang.uk;
    int count = 0;

    for (final v in widget.episode.vocabulary) {
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
            lang == UiLang.pl
                ? '📥 Dodano $count nowych słów z odcinka do Twojego słownika!'
                : (lang == UiLang.uk
                    ? '📥 Додано $count нових слів серії до вашого словника!'
                    : '📥 Добавлено $count новых слов серии в ваш словарь!'),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _openRoleplay(EpisodeScene scene) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoleplayScreen(
          scenario: widget.episode.toScenario(),
          subScenario: scene.subScenario,
        ),
      ),
    );
    // Отмечаем сцену завершенной после возврата из диалога
    await ref.read(episodesServiceProvider).completeScene(widget.episode.id, scene.id);
    if (mounted) setState(() {});
  }

  void _openSimulationModal(EpisodeScene scene, UiLang lang) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SceneSimulationSheet(
        episode: widget.episode,
        scene: scene,
        lang: lang,
        onSuccess: () async {
          await ref.read(episodesServiceProvider).completeScene(widget.episode.id, scene.id);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));
    final episodesService = ref.watch(episodesServiceProvider);
    final progress = episodesService.getProgress(widget.episode.id, widget.episode.number);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Text(widget.episode.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.episode.title(lang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Карточка синопсиса серии
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryCarmine.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ODCINEK ${widget.episode.number}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCarmine,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.episode.duration,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.episode.synopsis(lang),
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Заголовок словаря выживания
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.episodesVocabTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.playlist_add_check, color: AppTheme.primaryCarmine),
                tooltip: strings.episodesAddVocabAll,
                onPressed: _addAllTermsToDeck,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Карточки словаря
          for (final item in widget.episode.vocabulary) ...[
            _VocabItemCard(
              item: item,
              lang: lang,
              isAdded: _addedTerms.contains(item.termPl),
              onSpeak: () => _speak(item.termPl),
              onAdd: () async {
                final db = ref.read(databaseProvider);
                final added = await db.addScanWord(
                  form: item.termPl,
                  translation: item.translation(lang),
                  uk: lang == UiLang.uk,
                  examplePl: item.examplePl,
                );
                setState(() => _addedTerms.add(item.termPl));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(added
                          ? '✅ «${item.termPl}» dodano do słownika!'
                          : 'ℹ️ «${item.termPl}» już jest w słowniku.'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),

          // Кнопка пакетного добавления всех слов
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _addAllTermsToDeck,
              icon: const Icon(Icons.library_add_check, size: 18),
              label: Text(
                strings.episodesAddVocabAll,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Сюжетные сцены
          Text(
            strings.episodesScenesTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          for (final scene in widget.episode.scenes) ...[
            _SceneCard(
              scene: scene,
              lang: lang,
              isDone: progress.completedScenes.contains(scene.id),
              onPlayRoleplay: () => _openRoleplay(scene),
              onPlaySimulation: () => _openSimulationModal(scene, lang),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Карточка словаря серии
class _VocabItemCard extends StatelessWidget {
  const _VocabItemCard({
    required this.item,
    required this.lang,
    required this.isAdded,
    required this.onSpeak,
    required this.onAdd,
  });

  final EpisodeVocab item;
  final UiLang lang;
  final bool isAdded;
  final VoidCallback onSpeak;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.termPl,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.volume_up, size: 19),
                onPressed: onSpeak,
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isAdded ? Icons.check_circle : Icons.bookmark_add_outlined,
                  size: 19,
                  color: isAdded ? Colors.green : AppTheme.primaryCarmine,
                ),
                onPressed: onAdd,
              ),
            ],
          ),
          Text(
            item.translation(lang),
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '💡 ${item.examplePl}',
            style: TextStyle(
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

/// Карточка интерактивной сцены серии
class _SceneCard extends StatelessWidget {
  const _SceneCard({
    required this.scene,
    required this.lang,
    required this.isDone,
    required this.onPlayRoleplay,
    required this.onPlaySimulation,
  });

  final EpisodeScene scene;
  final UiLang lang;
  final bool isDone;
  final VoidCallback onPlayRoleplay;
  final VoidCallback onPlaySimulation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? Colors.green.withValues(alpha: 0.4)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isDone ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green.withValues(alpha: 0.15)
                      : AppTheme.primaryCarmine.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SCENA ${scene.sceneNumber}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDone ? Colors.green.shade800 : AppTheme.primaryCarmine,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '👤 ${scene.npcName}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              if (isDone)
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            scene.title(lang),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            scene.desc(lang),
            style: TextStyle(
              fontSize: 12.5,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          // Две кнопки взаимодействия
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryCarmine,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onPlayRoleplay,
                    icon: const Icon(Icons.record_voice_over, size: 16),
                    label: Text(
                      lang == UiLang.pl
                          ? 'Dialog z AI'
                          : (lang == UiLang.uk ? 'Діалог з ШІ' : 'Диалог с ИИ'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onPlaySimulation,
                    icon: const Icon(Icons.touch_app_rounded, size: 16),
                    label: Text(
                      lang == UiLang.pl
                          ? 'Symulacja'
                          : (lang == UiLang.uk ? 'Симуляція' : 'Симуляция'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
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
}

/// Модалка интерактивной сценарной симуляции (квеста с выбором фраз)
class _SceneSimulationSheet extends StatefulWidget {
  const _SceneSimulationSheet({
    required this.episode,
    required this.scene,
    required this.lang,
    required this.onSuccess,
  });

  final EpisodeItem episode;
  final EpisodeScene scene;
  final UiLang lang;
  final VoidCallback onSuccess;

  @override
  State<_SceneSimulationSheet> createState() => _SceneSimulationSheetState();
}

class _SceneSimulationSheetState extends State<_SceneSimulationSheet> {
  int? _selectedIndex;
  bool _resolved = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final starterPl = widget.scene.subScenario.npcFirstStarterPl ?? widget.scene.subScenario.starterHintPl;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('🧩', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.scene.title(widget.lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Реплика собеседника (NPC)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.primaryCarmine.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👤 ${widget.scene.npcName}:',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCarmine,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '«$starterPl»',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.lang == UiLang.pl
                  ? 'Co odpowiesz w tej sytuacji?'
                  : (widget.lang == UiLang.uk
                      ? 'Що ви відповісте у цій ситуації?'
                      : 'Что вы ответите в этой ситуации?'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Варианты выбора
            for (int i = 0; i < widget.scene.decisionOptions.length; i++) ...[
              _buildOptionTile(i, widget.scene.decisionOptions[i]),
              const SizedBox(height: 8),
            ],

            if (_resolved) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    widget.onSuccess();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(
                    widget.lang == UiLang.pl
                        ? 'Zatwierdź i kontynuuj'
                        : (widget.lang == UiLang.uk
                            ? 'Затвердити та продовжити'
                            : 'Завершить сцену'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(int index, SceneDecisionOption opt) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    Color borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.5);
    Color bgColor = theme.colorScheme.surface;

    if (isSelected) {
      if (opt.isOptimal) {
        borderColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
      } else {
        borderColor = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.1);
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _selectedIndex = index;
          if (opt.isOptimal) {
            _resolved = true;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opt.isOptimal ? '🟢' : '⚪',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    opt.text(widget.lang),
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: opt.isOptimal
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  opt.feedback(widget.lang),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: opt.isOptimal ? Colors.green.shade900 : Colors.deepOrange.shade900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
