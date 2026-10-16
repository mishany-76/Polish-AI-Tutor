import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Модель одного достижения «Польского паспорта».
class Achievement {
  const Achievement({
    required this.id,
    required this.emoji,
    required this.titleUk,
    required this.titleRu,
    required this.titlePl,
    required this.descUk,
    required this.descRu,
    required this.descPl,
  });

  final String id;
  final String emoji;
  final String titleUk;
  final String titleRu;
  final String titlePl;
  final String descUk;
  final String descRu;
  final String descPl;
}

/// Полный список 15 достижений польского паспорта.
const List<Achievement> kAllAchievements = [
  Achievement(
    id: 'first_word',
    emoji: '✍️',
    titleUk: 'Перше слово',
    titleRu: 'Первое слово',
    titlePl: 'Pierwsze słowo',
    descUk: 'Додано перше слово до словника',
    descRu: 'Добавлено первое слово в словарь',
    descPl: 'Dodano pierwsze słowo do słownika',
  ),
  Achievement(
    id: 'words_10',
    emoji: '📖',
    titleUk: '10 слів',
    titleRu: '10 слов',
    titlePl: '10 słów',
    descUk: 'У словнику вже 10 польських слів',
    descRu: 'В словаре уже 10 польских слов',
    descPl: 'W słowniku już 10 polskich słów',
  ),
  Achievement(
    id: 'words_50',
    emoji: '📚',
    titleUk: '50 слів',
    titleRu: '50 слов',
    titlePl: '50 słów',
    descUk: 'Ваш словник налічує 50 слів!',
    descRu: 'Ваш словарь насчитывает 50 слов!',
    descPl: 'Twój słownik liczy 50 słów!',
  ),
  Achievement(
    id: 'words_100',
    emoji: '🏆',
    titleUk: '100 слів',
    titleRu: '100 слов',
    titlePl: '100 słów',
    descUk: 'Словниковий запас 100 польських слів!',
    descRu: 'Словарный запас 100 польских слов!',
    descPl: '100 słów polskich w słowniku!',
  ),
  Achievement(
    id: 'first_scan',
    emoji: '📷',
    titleUk: 'Перший скан',
    titleRu: 'Первый скан',
    titlePl: 'Pierwsze skanowanie',
    descUk: 'Перший переклад тексту через камеру',
    descRu: 'Первый перевод текста через камеру',
    descPl: 'Pierwsze tłumaczenie przez aparat',
  ),
  Achievement(
    id: 'first_dialog',
    emoji: '💬',
    titleUk: 'Перший діалог',
    titleRu: 'Первый диалог',
    titlePl: 'Pierwszy dialog',
    descUk: 'Перший ролевий діалог з Kasią',
    descRu: 'Первый ролевой диалог с Kasią',
    descPl: 'Pierwszy dialog sytuacyjny z Kasią',
  ),
  Achievement(
    id: 'dialogs_5',
    emoji: '🗣️',
    titleUk: '5 діалогів',
    titleRu: '5 диалогов',
    titlePl: '5 dialogów',
    descUk: 'Проведено 5 ролевих діалогів з тьютором',
    descRu: 'Проведено 5 ролевых диалогов с тьютором',
    descPl: 'Odbyto 5 dialogów sytuacyjnych',
  ),
  Achievement(
    id: 'quiz_10',
    emoji: '🎯',
    titleUk: '10 вікторин',
    titleRu: '10 викторин',
    titlePl: '10 quizów',
    descUk: 'Пройдено 10 раундів тренажера',
    descRu: 'Пройдено 10 раундов тренажера',
    descPl: 'Ukończono 10 rund treningu',
  ),
  Achievement(
    id: 'streak_3',
    emoji: '🔥',
    titleUk: '3 дні поспіль',
    titleRu: '3 дня подряд',
    titlePl: '3 dni z rzędu',
    descUk: '3 дні поспіль у додатку',
    descRu: '3 дня подряд в приложении',
    descPl: '3 dni z rzędu w aplikacji',
  ),
  Achievement(
    id: 'streak_7',
    emoji: '⚡',
    titleUk: '7 днів поспіль',
    titleRu: '7 дней подряд',
    titlePl: '7 dni z rzędu',
    descUk: 'Тижневий streak! Ви в ударі',
    descRu: 'Недельный streak! Вы в ударе',
    descPl: 'Tygodniowy streak! Jesteś świetny',
  ),
  Achievement(
    id: 'streak_30',
    emoji: '🌟',
    titleUk: '30 днів поспіль',
    titleRu: '30 дней подряд',
    titlePl: '30 dni z rzędu',
    descUk: 'Місяць безперервного навчання! Легенда',
    descRu: 'Месяц непрерывного обучения! Легенда',
    descPl: 'Miesiąc nauki bez przerwy! Legenda',
  ),
  Achievement(
    id: 'mastered_10',
    emoji: '✅',
    titleUk: '10 засвоєних слів',
    titleRu: '10 освоенных слов',
    titlePl: '10 opanowanych słów',
    descUk: '10 слів вже точно ваші — SM-2 підтвердив',
    descRu: '10 слов уже точно ваши — SM-2 подтвердил',
    descPl: '10 słów na zawsze — SM-2 to potwierdził',
  ),
  Achievement(
    id: 'mastered_50',
    emoji: '🎓',
    titleUk: '50 засвоєних слів',
    titleRu: '50 освоенных слов',
    titlePl: '50 opanowanych słów',
    descUk: '50 слів у довготривалій пам\'яті',
    descRu: '50 слов в долгосрочной памяти',
    descPl: '50 słów w pamięci długotrwałej',
  ),
  Achievement(
    id: 'all_drills',
    emoji: '🏅',
    titleUk: 'Всі тренажери',
    titleRu: 'Все тренажеры',
    titlePl: 'Wszystkie trenery',
    descUk: 'Зіграно хоч один раз у всі 4 тренажери',
    descRu: 'Сыграно хотя бы раз во все 4 тренажера',
    descPl: 'Zagrano co najmniej raz we wszystkie 4 trenerach',
  ),
  Achievement(
    id: 'passport_complete',
    emoji: '🇵🇱',
    titleUk: 'Польський паспорт',
    titleRu: 'Польский паспорт',
    titlePl: 'Polski Paszport',
    descUk: 'Всі 14 попередніх досягнень отримано. Ласкаво просимо до Польщі!',
    descRu: 'Все 14 предыдущих достижений получены. Добро пожаловать в Польшу!',
    descPl: 'Wszystkie 14 poprzednich osiągnięć zdobyte. Witaj w Polsce!',
  ),
];

/// Хранилище прогресса достижений в SharedPreferences.
class AchievementService {
  AchievementService._();
  static final AchievementService instance = AchievementService._();

  static const _kUnlockedKey = 'achievements_unlocked_v1';
  static const _kCountersKey = 'achievements_counters_v1';

  SharedPreferences? _prefs;
  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ---- Разблокировка ----

  Future<Set<String>> getUnlocked() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_kUnlockedKey);
    if (raw == null) return {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  /// Разблокировать достижение. Возвращает `true`, если оно было НОВЫМ.
  Future<bool> unlock(String id) async {
    final unlocked = await getUnlocked();
    if (unlocked.contains(id)) return false;
    unlocked.add(id);
    // Проверить, закрыт ли теперь «Паспорт»
    final nonPassport = kAllAchievements
        .where((a) => a.id != 'passport_complete')
        .map((a) => a.id)
        .toSet();
    if (nonPassport.difference(unlocked).isEmpty) {
      unlocked.add('passport_complete');
    }
    final prefs = await _getPrefs();
    await prefs.setString(_kUnlockedKey, jsonEncode(unlocked.toList()));
    return true;
  }

  // ---- Счётчики событий ----

  Future<Map<String, int>> _getCounters() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_kCountersKey);
    if (raw == null) return {};
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveCounters(Map<String, int> counters) async {
    final prefs = await _getPrefs();
    await prefs.setString(_kCountersKey, jsonEncode(counters));
  }

  /// Инкрементировать счётчик и разблокировать связанные достижения.
  /// Возвращает список ID новых достижений (если появились).
  Future<List<String>> increment(String counter, {int by = 1}) async {
    final counters = await _getCounters();
    counters[counter] = (counters[counter] ?? 0) + by;
    await _saveCounters(counters);
    return _checkThresholds(counter, counters[counter]!);
  }

  Future<List<String>> _checkThresholds(String counter, int value) async {
    final newlyUnlocked = <String>[];

    Future<void> tryUnlock(String id) async {
      final isNew = await unlock(id);
      if (isNew) newlyUnlocked.add(id);
    }

    switch (counter) {
      case 'words_added':
        if (value >= 1) await tryUnlock('first_word');
        if (value >= 10) await tryUnlock('words_10');
        if (value >= 50) await tryUnlock('words_50');
        if (value >= 100) await tryUnlock('words_100');
      case 'scans_done':
        if (value >= 1) await tryUnlock('first_scan');
      case 'dialogs_done':
        if (value >= 1) await tryUnlock('first_dialog');
        if (value >= 5) await tryUnlock('dialogs_5');
      case 'quiz_rounds_done':
        if (value >= 10) await tryUnlock('quiz_10');
      case 'streak_days':
        if (value >= 3) await tryUnlock('streak_3');
        if (value >= 7) await tryUnlock('streak_7');
        if (value >= 30) await tryUnlock('streak_30');
      case 'words_mastered':
        if (value >= 10) await tryUnlock('mastered_10');
        if (value >= 50) await tryUnlock('mastered_50');
      case 'drills_used':
        if (value >= 4) await tryUnlock('all_drills');
    }

    return newlyUnlocked;
  }

  /// Получить текущее значение счётчика.
  Future<int> getCounter(String counter) async {
    final counters = await _getCounters();
    return counters[counter] ?? 0;
  }

  /// Полный сброс достижений (для тестирования).
  Future<void> reset() async {
    final prefs = await _getPrefs();
    await prefs.remove(_kUnlockedKey);
    await prefs.remove(_kCountersKey);
  }
}

// ---- Riverpod провайдер ----

class AchievementsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    return AchievementService.instance.getUnlocked();
  }

  /// Вызывается извне при новом событии. Обновляет UI при появлении достижений.
  Future<List<String>> recordEvent(String counter, {int by = 1}) async {
    final newIds =
        await AchievementService.instance.increment(counter, by: by);
    if (newIds.isNotEmpty) {
      state = AsyncData(await AchievementService.instance.getUnlocked());
    }
    return newIds;
  }

  /// Синхронизировать streak с существующим StreakService.
  Future<void> syncStreak(int streakDays) async {
    await AchievementService.instance
        ._getCounters()
        .then((counters) async {
      // Обновляем счётчик до текущего значения стрика (не инкрементируем)
      final prefs = await AchievementService.instance._getPrefs();
      counters['streak_days'] = streakDays;
      await prefs.setString(
          AchievementService._kCountersKey, jsonEncode(counters));
      final newIds = await AchievementService.instance
          ._checkThresholds('streak_days', streakDays);
      if (newIds.isNotEmpty) {
        state = AsyncData(await AchievementService.instance.getUnlocked());
      }
    });
  }
}

final achievementsProvider =
    AsyncNotifierProvider<AchievementsNotifier, Set<String>>(
        AchievementsNotifier.new);

