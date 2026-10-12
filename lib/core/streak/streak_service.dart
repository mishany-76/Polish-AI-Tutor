import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис отслеживания ежедневной серии входов (Streak).
/// Сохраняет дату последнего визита и число дней подряд в SharedPreferences.
class StreakNotifier extends AsyncNotifier<int> {
  static const _kLastDate = 'streak_last_date';
  static const _kCount = 'streak_count';

  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final lastDateStr = prefs.getString(_kLastDate);
    final currentStreak = prefs.getInt(_kCount) ?? 0;

    if (lastDateStr == null) {
      // Первый запуск приложения
      await prefs.setString(_kLastDate, todayStr);
      await prefs.setInt(_kCount, 1);
      return 1;
    }

    if (lastDateStr == todayStr) {
      // Уже заходили сегодня
      return currentStreak > 0 ? currentStreak : 1;
    }

    try {
      final lastDate = DateTime.parse(lastDateStr);
      final todayDate = DateTime(now.year, now.month, now.day);
      final prevDate = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diffDays = todayDate.difference(prevDate).inDays;

      if (diffDays == 1) {
        // Заход на следующий день подряд
        final newStreak = currentStreak + 1;
        await prefs.setString(_kLastDate, todayStr);
        await prefs.setInt(_kCount, newStreak);
        return newStreak;
      } else {
        // Пропущен день — серия сбрасывается до 1
        await prefs.setString(_kLastDate, todayStr);
        await prefs.setInt(_kCount, 1);
        return 1;
      }
    } catch (_) {
      await prefs.setString(_kLastDate, todayStr);
      await prefs.setInt(_kCount, 1);
      return 1;
    }
  }
}

final streakProvider =
    AsyncNotifierProvider<StreakNotifier, int>(StreakNotifier.new);

