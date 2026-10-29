import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/achievements/achievement_service.dart';
import '../onboarding/user_profile.dart' show sharedPreferencesProvider;
import 'episodes_data.dart';

class EpisodeProgress {
  final bool isUnlocked;
  final bool isCompleted;
  final int stars;
  final Set<String> completedScenes;

  const EpisodeProgress({
    required this.isUnlocked,
    required this.isCompleted,
    required this.stars,
    required this.completedScenes,
  });
}

class EpisodesService {
  EpisodesService(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyPrefixUnlocked = 'episode_unlocked_';
  static const String _keyPrefixCompleted = 'episode_completed_';
  static const String _keyPrefixStars = 'episode_stars_';
  static const String _keyPrefixScenes = 'episode_scenes_done_';

  bool isEpisodeUnlocked(String episodeId, int number) {
    if (number == 1) return true;
    return _prefs.getBool('$_keyPrefixUnlocked$episodeId') ?? false;
  }

  bool isEpisodeCompleted(String episodeId) {
    return _prefs.getBool('$_keyPrefixCompleted$episodeId') ?? false;
  }

  int getEpisodeStars(String episodeId) {
    return _prefs.getInt('$_keyPrefixStars$episodeId') ?? 0;
  }

  Set<String> getCompletedScenes(String episodeId) {
    final list = _prefs.getStringList('$_keyPrefixScenes$episodeId') ?? [];
    return list.toSet();
  }

  EpisodeProgress getProgress(String episodeId, int number) {
    return EpisodeProgress(
      isUnlocked: isEpisodeUnlocked(episodeId, number),
      isCompleted: isEpisodeCompleted(episodeId),
      stars: getEpisodeStars(episodeId),
      completedScenes: getCompletedScenes(episodeId),
    );
  }

  Future<void> completeScene(String episodeId, String sceneId) async {
    final scenes = getCompletedScenes(episodeId);
    scenes.add(sceneId);
    await _prefs.setStringList('$_keyPrefixScenes$episodeId', scenes.toList());

    // Проверяем, завершены ли все сцены серии
    final episode = kAllEpisodes.firstWhere(
      (e) => e.id == episodeId,
      orElse: () => episode1Flat,
    );

    if (scenes.length >= episode.scenes.length) {
      await markEpisodeCompleted(episodeId);
    }
  }

  Future<void> markEpisodeCompleted(String episodeId, {int stars = 3}) async {
    await _prefs.setBool('$_keyPrefixCompleted$episodeId', true);
    await _prefs.setInt('$_keyPrefixStars$episodeId', stars);

    // Открываем следующий эпизод
    final currentIndex = kAllEpisodes.indexWhere((e) => e.id == episodeId);
    if (currentIndex != -1 && currentIndex + 1 < kAllEpisodes.length) {
      final nextEpisode = kAllEpisodes[currentIndex + 1];
      await _prefs.setBool('$_keyPrefixUnlocked${nextEpisode.id}', true);
    }

    // Фиксируем прогресс в достижениях / паспорте
    try {
      await AchievementService.instance.increment('dialogs_done');
    } catch (_) {}
  }

  int get completedEpisodesCount {
    int count = 0;
    for (final ep in kAllEpisodes) {
      if (isEpisodeCompleted(ep.id)) count++;
    }
    return count;
  }

  int get totalStarsCount {
    int stars = 0;
    for (final ep in kAllEpisodes) {
      stars += getEpisodeStars(ep.id);
    }
    return stars;
  }
}

final episodesServiceProvider = Provider<EpisodesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return EpisodesService(prefs);
});
