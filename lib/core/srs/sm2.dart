/// Результат пересчёта интервала по SM-2.
class Sm2Result {
  const Sm2Result({
    required this.ease,
    required this.intervalDays,
    required this.reps,
    required this.lapses,
    required this.due,
  });

  final double ease;
  final int intervalDays;
  final int reps;
  final int lapses;
  final DateTime due;
}

/// Упрощённый SM-2. Оценка: 1 — Снова, 2 — Трудно, 3 — Хорошо, 4 — Легко.
Sm2Result sm2({
  required double ease,
  required int intervalDays,
  required int reps,
  required int lapses,
  required int rating,
  DateTime? now,
}) {
  assert(rating >= 1 && rating <= 4);
  final t = now ?? DateTime.now();

  if (rating == 1) {
    return Sm2Result(
      ease: (ease - 0.2).clamp(1.3, 3.0),
      intervalDays: 0,
      reps: 0,
      lapses: lapses + 1,
      due: t.add(const Duration(minutes: 10)),
    );
  }

  final q = const {2: 3, 3: 4, 4: 5}[rating]!;
  final newEase =
      (ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))).clamp(1.3, 3.0);
  final newReps = reps + 1;

  int days;
  if (newReps == 1) {
    days = rating == 4 ? 3 : 1;
  } else if (newReps == 2) {
    days = rating == 2 ? 3 : 6;
  } else {
    final factor = rating == 2 ? 1.2 : (rating == 4 ? newEase * 1.3 : newEase);
    days = (intervalDays * factor).round();
  }
  if (days < 1) days = 1;

  return Sm2Result(
    ease: newEase.toDouble(),
    intervalDays: days,
    reps: newReps,
    lapses: lapses,
    due: t.add(Duration(days: days)),
  );
}

