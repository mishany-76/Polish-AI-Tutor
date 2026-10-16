import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/db/app_database.dart';
import '../../core/di/providers.dart';
import '../scanner/translation_service.dart';

/// Статистические показатели пользователя за календарный месяц.
class MonthlyStats {
  const MonthlyStats({
    required this.year,
    required this.month,
    required this.totalWords,
    required this.wordsAddedThisMonth,
    required this.wordsMastered,
    required this.wordsLearning,
    required this.dialogsDone,
    required this.scansDone,
    required this.quizRoundsDone,
    required this.streakDays,
    required this.cefrLevel,
    required this.cefrTarget,
    required this.cefrProgressPercent,
    required this.titleUk,
    required this.titleRu,
    required this.titlePl,
    required this.titleEmoji,
    required this.quotePl,
  });

  final int year;
  final int month;
  final int totalWords;
  final int wordsAddedThisMonth;
  final int wordsMastered;
  final int wordsLearning;
  final int dialogsDone;
  final int scansDone;
  final int quizRoundsDone;
  final int streakDays;

  /// 'A1' | 'A2' | 'B1'
  final String cefrLevel;
  final int cefrTarget;
  final int cefrProgressPercent;

  final String titleUk;
  final String titleRu;
  final String titlePl;
  final String titleEmoji;
  final String quotePl;

  String title(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return titleUk;
      case UiLang.ru:
        return titleRu;
      case UiLang.pl:
        return titlePl;
    }
  }

  String monthName(UiLang lang) {
    const plMonths = [
      'Styczeń',
      'Luty',
      'Marzec',
      'Kwiecień',
      'Maj',
      'Czerwiec',
      'Lipiec',
      'Sierpień',
      'Wrzesień',
      'Październik',
      'Listopad',
      'Grudzień',
    ];
    const ukMonths = [
      'Січень',
      'Лютий',
      'Березень',
      'Квітень',
      'Травень',
      'Червень',
      'Липень',
      'Серпень',
      'Вересень',
      'Жовтень',
      'Листопад',
      'Грудень',
    ];
    const ruMonths = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];

    final index = (month >= 1 && month <= 12) ? month - 1 : 0;
    switch (lang) {
      case UiLang.uk:
        return ukMonths[index];
      case UiLang.ru:
        return ruMonths[index];
      case UiLang.pl:
        return plMonths[index];
    }
  }
}

/// Сервис вычисления ежемесячного прогресса «Мой польский за месяц» на базе SQLite.
class MonthlyStatsService {
  MonthlyStatsService(this._db);

  final AppDatabase _db;

  Future<MonthlyStats> computeStats({DateTime? forDate}) async {
    final now = forDate ?? DateTime.now();
    final allWords = await _db.allWords();

    final wordsAddedThisMonth = allWords
        .where(
          (w) => w.createdAt.year == now.year && w.createdAt.month == now.month,
        )
        .length;

    final wordsMastered = allWords
        .where((w) => w.status == WordStatus.mastered)
        .length;
    final wordsLearning = allWords
        .where((w) => w.status == WordStatus.learning)
        .length;

    // Счётчики событий из SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt('streak_count') ?? 1;

    final ach = AchievementService.instance;
    final dialogsDone = await ach.getCounter('dialogs_done');
    final scansDone = await ach.getCounter('scans_done');
    final quizRoundsDone = await ach.getCounter('quiz_rounds_done');

    // CEFR Прогресс:
    // A1 = 500 базовых слов
    // A2 = 1000 слов
    // B1 = 2000 слов
    final total = allWords.length;
    final String cefrLevel;
    final int cefrTarget;
    final int cefrPercent;

    if (total < 500) {
      cefrLevel = 'A1 (Początkujący)';
      cefrTarget = 500;
      cefrPercent = total > 0 ? max(1, (total / 500 * 100).round()) : 0;
    } else if (total < 1000) {
      cefrLevel = 'A2 (Średniozaawansowany)';
      cefrTarget = 1000;
      cefrPercent = min(100, max(1, ((total - 500) / 500 * 100).round()));
    } else {
      cefrLevel = 'B1 (Samodzielny)';
      cefrTarget = 2000;
      cefrPercent = min(100, max(1, ((total - 1000) / 1000 * 100).round()));
    }

    // Присвоение персонализированного титула месяца
    final String titleUk;
    final String titleRu;
    final String titlePl;
    final String titleEmoji;

    if (dialogsDone >= 5 && scansDone >= 3) {
      titleEmoji = '👑';
      titleUk = 'Варшавський Переговорник';
      titleRu = 'Варшавский Переговорщик';
      titlePl = 'Warszawski Negocjator';
    } else if (wordsAddedThisMonth >= 30 || total >= 50) {
      titleEmoji = '📚';
      titleUk = 'Лексичний Снайпер';
      titleRu = 'Лексический Снайпер';
      titlePl = 'Leksykalny Snajper';
    } else if (quizRoundsDone >= 5) {
      titleEmoji = '🎯';
      titleUk = 'Майстер Практики';
      titleRu = 'Мастер Практики';
      titlePl = 'Mistrz Praktyki';
    } else if (streak >= 7) {
      titleEmoji = '🔥';
      titleUk = 'Людина зі Сталі';
      titleRu = 'Человек из Стали';
      titlePl = 'Człowiek z Żelaza';
    } else {
      titleEmoji = '🇵🇱';
      titleUk = 'Активний Студент';
      titleRu = 'Активный Студент';
      titlePl = 'Aktywny Student';
    }

    const quotePl =
        '„Kropla drąży skałę nie siłą, lecz częstym spadaniem.” Każdy dzień w Polish AI Tutor przybliża Cię do płynności językowej!';

    return MonthlyStats(
      year: now.year,
      month: now.month,
      totalWords: total,
      wordsAddedThisMonth: wordsAddedThisMonth,
      wordsMastered: wordsMastered,
      wordsLearning: wordsLearning,
      dialogsDone: dialogsDone,
      scansDone: scansDone,
      quizRoundsDone: quizRoundsDone,
      streakDays: streak,
      cefrLevel: cefrLevel,
      cefrTarget: cefrTarget,
      cefrProgressPercent: cefrPercent,
      titleUk: titleUk,
      titleRu: titleRu,
      titlePl: titlePl,
      titleEmoji: titleEmoji,
      quotePl: quotePl,
    );
  }
}

final monthlyStatsServiceProvider = Provider<MonthlyStatsService>((ref) {
  return MonthlyStatsService(ref.watch(databaseProvider));
});

final monthlyStatsFutureProvider = FutureProvider.autoDispose<MonthlyStats>((
  ref,
) {
  return ref.watch(monthlyStatsServiceProvider).computeStats();
});
