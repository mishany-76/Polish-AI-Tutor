import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DrillQuestionStatus {
  const DrillQuestionStatus({
    this.correctStreak = 0,
    this.lapses = 0,
    this.isMastered = false,
  });

  final int correctStreak;
  final int lapses;
  final bool isMastered;

  Map<String, dynamic> toJson() => {
        's': correctStreak,
        'l': lapses,
        'm': isMastered,
      };

  factory DrillQuestionStatus.fromJson(Map<String, dynamic> json) {
    return DrillQuestionStatus(
      correctStreak: (json['s'] as num?)?.toInt() ?? 0,
      lapses: (json['l'] as num?)?.toInt() ?? 0,
      isMastered: json['m'] as bool? ?? false,
    );
  }
}

/// Сервис адаптивной памяти тренировок («Ошибся — учи, знаешь — убирай»).
class DrillProgressService {
  DrillProgressService._();
  static final DrillProgressService instance = DrillProgressService._();

  static const _prefix = 'drill_stat_v2_';
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  String _key(String category) => '$_prefix$category';

  Future<Map<String, DrillQuestionStatus>> _loadCategory(String category) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_key(category));
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (k, v) => MapEntry(k, DrillQuestionStatus.fromJson(v as Map<String, dynamic>)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveCategory(
    String category,
    Map<String, DrillQuestionStatus> data,
  ) async {
    final prefs = await _getPrefs();
    final raw = jsonEncode(data.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_key(category), raw);
  }

  /// Запись ответа пользователя на вопрос.
  Future<void> recordAnswer(String category, String id, bool isCorrect) async {
    final data = await _loadCategory(category);
    final cur = data[id] ?? const DrillQuestionStatus();

    final int newStreak = isCorrect ? cur.correctStreak + 1 : 0;
    final int newLapses = isCorrect ? cur.lapses : cur.lapses + 1;
    // Считаем вопрос выученным, если отвечен правильно 1 раз без ошибок,
    // либо 2 раза подряд после допущенной ошибки.
    final bool mastered = isCorrect && (cur.lapses == 0 ? newStreak >= 1 : newStreak >= 2);

    data[id] = DrillQuestionStatus(
      correctStreak: newStreak,
      lapses: newLapses,
      isMastered: mastered,
    );

    await _saveCategory(category, data);
  }

  /// Сброс прогресса по категории (начать сначала).
  Future<void> resetCategory(String category) async {
    final prefs = await _getPrefs();
    await prefs.remove(_key(category));
  }

  /// Сколько вопросов освоено в категории.
  Future<int> getMasteredCount(String category) async {
    final data = await _loadCategory(category);
    return data.values.where((s) => s.isMastered).length;
  }

  /// Адаптивный отбор вопросов для раунда:
  /// 1. Исключает выученные (isMastered).
  /// 2. В первую очередь подмешивает вопросы с ошибками (lapses > 0).
  /// 3. Добавляет свежие неизученные вопросы.
  Future<List<T>> selectAdaptive<T>({
    required String category,
    required List<T> allItems,
    required String Function(T) idOf,
    int count = 8,
  }) async {
    final data = await _loadCategory(category);

    final needsReview = <T>[]; // Была ошибка, ещё не выучено
    final fresh = <T>[];       // Ещё ни разу не встречалось

    for (final item in allItems) {
      final id = idOf(item);
      final stat = data[id];
      if (stat == null) {
        fresh.add(item);
      } else if (!stat.isMastered) {
        needsReview.add(item);
      }
      // stat.isMastered == true исключается!
    }

    // Если всё выучено — возвращаем пустой список (UI покажет экран триумфа)
    if (needsReview.isEmpty && fresh.isEmpty) {
      return [];
    }

    needsReview.shuffle();
    fresh.shuffle();

    // Сначала проблемные, затем свежие
    final result = <T>[];
    result.addAll(needsReview.take(count));
    if (result.length < count) {
      result.addAll(fresh.take(count - result.length));
    }

    result.shuffle();
    return result;
  }
}

