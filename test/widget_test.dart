import 'dart:math';
import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polish_ai_tutor/core/achievements/achievement_service.dart';
import 'package:polish_ai_tutor/core/ai_client/ai_client.dart';
import 'package:polish_ai_tutor/core/db/app_database.dart';
import 'package:polish_ai_tutor/core/srs/sm2.dart';
import 'package:polish_ai_tutor/features/review/quiz_builders.dart';
import 'package:polish_ai_tutor/features/scanner/ocr_service.dart';
import 'package:polish_ai_tutor/features/scanner/translation_service.dart';
import 'package:polish_ai_tutor/features/scanner/word_analysis.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('OcrWord', () {
    test('clean убирает знаки препинания по краям', () {
      const w = OcrWord(text: '„Mleko,"', box: Rect.zero);
      expect(w.clean, 'Mleko');
    });

    test('clean сохраняет польские буквы', () {
      const w = OcrWord(text: 'żółć.', box: Rect.zero);
      expect(w.clean, 'żółć');
    });
  });

  group('SM-2', () {
    test('«Снова» сбрасывает прогресс и считает лапс', () {
      final r = sm2(ease: 2.5, intervalDays: 6, reps: 2, lapses: 0, rating: 1);
      expect(r.reps, 0);
      expect(r.lapses, 1);
      expect(r.intervalDays, 0);
      expect(r.ease, lessThan(2.5));
    });

    test('интервалы растут: 1 → 6 → больше', () {
      var r = sm2(ease: 2.5, intervalDays: 0, reps: 0, lapses: 0, rating: 3);
      expect(r.intervalDays, 1);
      r = sm2(ease: r.ease, intervalDays: r.intervalDays, reps: r.reps, lapses: 0, rating: 3);
      expect(r.intervalDays, 6);
      r = sm2(ease: r.ease, intervalDays: r.intervalDays, reps: r.reps, lapses: 0, rating: 3);
      expect(r.intervalDays, greaterThan(6));
    });

    test('ease не падает ниже 1.3', () {
      var ease = 1.4;
      for (var i = 0; i < 10; i++) {
        ease = sm2(ease: ease, intervalDays: 3, reps: 3, lapses: 0, rating: 1).ease;
      }
      expect(ease, greaterThanOrEqualTo(1.3));
    });
  });

  group('AI JSON', () {
    test('extractJson достаёт объект из markdown-ограждения', () {
      final o = extractJson('Вот:\n```json\n{"lemma":"mleko"}\n```');
      expect(o?['lemma'], 'mleko');
    });

    test('extractJson возвращает null без JSON', () {
      expect(extractJson('просто текст'), isNull);
    });

    test('WordAnalysis.fromJson терпим к null и пустым полям', () {
      final a = WordAnalysis.fromJson({
        'lemma': 'mleko',
        'gender': 'null',
        'translation': 'молоко',
        'is_false_friend': false,
        'examples': [
          {'pl': 'Lubię mleko.', 'tr': 'Люблю молоко.'},
          {'tr': 'без pl'},
        ],
      });
      expect(a.lemma, 'mleko');
      expect(a.gender, isNull);
      expect(a.examples.length, 1);
    });
  });

  group('Quiz builders', () {
    test('окончания: ровно один верный вариант из трёх', () {
      final qs = buildEndingsQuiz(UiLang.ru, random: Random(1));
      expect(qs, isNotEmpty);
      for (final q in qs) {
        expect(q.options.length, 3);
        expect(q.options.toSet().length, 3);
        expect(q.correctIndex, inInclusiveRange(0, 2));
      }
    });

    test('ложные друзья: 4 разных варианта, верный есть', () {
      final qs = buildFalseFriendsQuiz(UiLang.uk, random: Random(2));
      for (final q in qs) {
        expect(q.options.length, 4);
        expect(q.options.toSet().length, 4);
      }
    });

    test('аудио: работает с пустой колодой на стартовом словаре', () {
      final qs = buildAudioQuiz(const [], UiLang.uk, random: Random(3));
      expect(qs.length, 8);
      for (final q in qs) {
        expect(q.speakText, isNotNull);
        expect(q.options.length, 4);
      }
    });
  });

  group('AppDatabase', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('addScanWord: повторное добавление возвращает false', () async {
      expect(await db.addScanWord(form: 'Mleko', translation: 'молоко', uk: true), isTrue);
      expect(await db.addScanWord(form: 'mleko', translation: 'молоко', uk: true), isFalse);
      expect((await db.allWords()).length, 1);
    });

    test('saveAnalysis сливает форму и лемму без дубликатов', () async {
      await db.addScanWord(form: 'mleka', translation: 'молока', uk: true);
      await db.saveAnalysis(
        form: 'mleka',
        lemma: 'mleko',
        uk: true,
        translation: 'молоко',
        isFalseFriend: false,
      );
      final all = await db.allWords();
      expect(all.length, 1);
      expect(all.single.lemma, 'mleko');
      expect(all.single.translationUk, 'молоко');
    });

    test('applyReview переводит слово из новых в изучаемые', () async {
      await db.addScanWord(form: 'chleb', translation: 'хліб', uk: true);
      var w = (await db.allWords()).single;
      expect(w.status, WordStatus.fresh);
      await db.applyReview(w, 3);
      w = (await db.allWords()).single;
      expect(w.status, WordStatus.learning);
      expect(w.isDue, isFalse);
    });

    test('кэш ИИ: запись, чтение, очистка', () async {
      await db.cachePut('k', '{"a":1}');
      expect(await db.cacheGet('k'), '{"a":1}');
      await db.clearCache();
      expect(await db.cacheGet('k'), isNull);
    });
  });

  group('AchievementService (Польский паспорт)', () {
    test('15 базовых достижений определены корректно', () {
      expect(kAllAchievements.length, 15);
      expect(kAllAchievements.last.id, 'passport_complete');
    });

    test('разблокировка достижений и проверка уникальности', () async {
      final service = AchievementService.instance;
      await service.reset();

      final first = await service.unlock('first_word');
      expect(first, isTrue);

      final second = await service.unlock('first_word');
      expect(second, isFalse);

      final unlocked = await service.getUnlocked();
      expect(unlocked.contains('first_word'), isTrue);
    });

    test('пороги счетчиков активируют достижения', () async {
      final service = AchievementService.instance;
      await service.reset();

      final newIds = await service.increment('words_added', by: 10);
      expect(newIds.contains('first_word'), isTrue);
      expect(newIds.contains('words_10'), isTrue);

      final unlocked = await service.getUnlocked();
      expect(unlocked.length, greaterThanOrEqualTo(2));
    });
  });
}

