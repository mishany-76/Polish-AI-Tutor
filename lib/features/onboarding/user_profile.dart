import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/achievements/achievement_service.dart';

/// Уровень владения языком, выбранный при онбординге.
enum PolishLevel {
  starter, // С нуля (Dopiero zaczynam)
  basic, // Начальный/базовый (A1-A2)
  intermediate, // Средний (B1+)
}

/// Основная цель изучения языка в Польше.
enum PolishGoal {
  daily, // Жизнь и быт (Życie i zakupy)
  documents, // Документы и легализация (Urząd i dokumenty)
  work, // Работа и карьера (Praca w Polsce)
  exam, // Сертификат B1 / Гражданство (Egzamin państwowy)
}

/// Профиль пользователя, настроенный через онбординг.
class UserProfile {
  const UserProfile({
    this.name = '',
    this.level = PolishLevel.starter,
    this.goal = PolishGoal.daily,
    this.onboardingCompleted = false,
  });

  final String name;
  final PolishLevel level;
  final PolishGoal goal;
  final bool onboardingCompleted;

  String get displayName => name.trim().isEmpty ? 'Przyjaciel' : name.trim();

  UserProfile copyWith({
    String? name,
    PolishLevel? level,
    PolishGoal? goal,
    bool? onboardingCompleted,
  }) =>
      UserProfile(
        name: name ?? this.name,
        level: level ?? this.level,
        goal: goal ?? this.goal,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      );
}

class UserProfileNotifier extends Notifier<UserProfile> {
  static const _kName = 'profile_user_name';
  static const _kLevel = 'profile_polish_level';
  static const _kGoal = 'profile_polish_goal';
  static const _kCompleted = 'profile_onboarding_completed';

  @override
  UserProfile build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final name = prefs.getString(_kName) ?? '';
    final levelStr = prefs.getString(_kLevel);
    final goalStr = prefs.getString(_kGoal);
    final completed = prefs.getBool(_kCompleted) ?? false;

    final level = PolishLevel.values.firstWhere(
      (l) => l.name == levelStr,
      orElse: () => PolishLevel.starter,
    );
    final goal = PolishGoal.values.firstWhere(
      (g) => g.name == goalStr,
      orElse: () => PolishGoal.daily,
    );

    return UserProfile(
      name: name,
      level: level,
      goal: goal,
      onboardingCompleted: completed,
    );
  }

  Future<void> completeOnboarding({
    required String name,
    required PolishLevel level,
    required PolishGoal goal,
  }) async {
    final trimmedName = name.trim();
    state = state.copyWith(
      name: trimmedName,
      level: level,
      goal: goal,
      onboardingCompleted: true,
    );

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kName, trimmedName);
    await prefs.setString(_kLevel, level.name);
    await prefs.setString(_kGoal, goal.name);
    await prefs.setBool(_kCompleted, true);

    // Автоматически открываем первый диалог в Польском паспорте
    try {
      AchievementService.instance.unlock('first_dialog');
    } catch (_) {}
  }

  Future<void> resetOnboarding() async {
    state = state.copyWith(onboardingCompleted: false);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_kCompleted, false);
  }

  Future<void> updateProfile({
    String? name,
    PolishLevel? level,
    PolishGoal? goal,
  }) async {
    final newName = name != null ? name.trim() : state.name;
    final newLevel = level ?? state.level;
    final newGoal = goal ?? state.goal;

    state = state.copyWith(
      name: newName,
      level: newLevel,
      goal: newGoal,
    );

    final prefs = ref.read(sharedPreferencesProvider);
    if (name != null) await prefs.setString(_kName, newName);
    if (level != null) await prefs.setString(_kLevel, newLevel.name);
    if (goal != null) await prefs.setString(_kGoal, newGoal.name);
  }
}

/// Провайдер SharedPreferences для онбординга и профиля
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Инициализируется в main()');
});

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile>(UserProfileNotifier.new);
