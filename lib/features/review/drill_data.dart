/// Статические данные тренажёров: окончания, ложные друзья, стартовый словарь.
/// Масштабированная база (1100+ карточек):
/// - 344 «Хибні друзі» (ложные друзья переводчика)
/// - 360 «Закінчення» (практические предложения на падежи)
/// - 435 «Аудіо-тренажер» (лексика, цены, числа, бытовые ситуации)
library;

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'data/endings_data.dart';
import 'data/false_friends_data.dart';
import 'data/numbers_prices_data.dart';
import 'data/seed_words_data.dart';

export 'data/endings_data.dart' show endingItems;
export 'data/false_friends_data.dart' show falseFriendItems;
export 'data/numbers_prices_data.dart' show numberPriceItems;
export 'data/seed_words_data.dart' show seedWords;

class EndingItem {
  const EndingItem({
    required this.sentence,
    required this.correct,
    required this.wrong,
    required this.explainUk,
    required this.explainRu,
  });

  /// Предложение с пропуском `___`.
  final String sentence;
  final String correct;

  /// Две неверные формы.
  final List<String> wrong;
  final String explainUk;
  final String explainRu;
}

class FalseFriendItem {
  const FalseFriendItem({
    required this.pl,
    required this.uk,
    required this.ru,
    required this.trapUk,
    required this.trapRu,
    required this.noteUk,
    required this.noteRu,
  });

  final String pl;
  final String uk;
  final String ru;

  /// Что «подсказывает» обманчивое сходство.
  final String trapUk;
  final String trapRu;
  final String noteUk;
  final String noteRu;
}

class SeedWord {
  const SeedWord(this.pl, this.uk, this.ru);
  final String pl;
  final String uk;
  final String ru;
}

class NumberPriceItem {
  const NumberPriceItem({
    required this.id,
    required this.spokenPl,
    required this.correct,
    required this.wrong,
    required this.explainUk,
    required this.explainRu,
    this.promptPl,
  });

  final String id;
  /// Польский текст, озвучиваемый голосом диктора (TTS)
  final String spokenPl;
  /// Правильный ответ (цифра или время, напр. '72,50 zł', '14:30', '19')
  final String correct;
  /// Неправильные варианты ответов
  final List<String> wrong;
  /// Подсказка и объяснение на украинском
  final String explainUk;
  /// Подсказка и объяснение на русском
  final String explainRu;
  /// Дополнительный контекст/подпись
  final String? promptPl;
}

class AudioWordItem {
  const AudioWordItem({
    required this.pl,
    required this.uk,
    required this.ru,
    this.distractorsUk = const [],
    this.distractorsRu = const [],
  });

  final String pl;
  final String uk;
  final String ru;
  final List<String> distractorsUk;
  final List<String> distractorsRu;
}

/// Асинхронный загрузчик масштабированной базы 6000+ карточек из JSON-ассетов.
/// Позволяет мгновенно запускать тренировки без лишнего расхода оперативной памяти.
class DrillDataLoader {
  static List<EndingItem>? _cachedEndings;
  static List<FalseFriendItem>? _cachedFalseFriends;
  static List<NumberPriceItem>? _cachedNumbersPrices;
  static List<AudioWordItem>? _cachedAudioWords;

  static Future<List<EndingItem>> getEndings() async {
    if (_cachedEndings != null && _cachedEndings!.isNotEmpty) return _cachedEndings!;
    try {
      final raw = await rootBundle.loadString('assets/drills/endings.json');
      final list = jsonDecode(raw) as List<dynamic>;
      _cachedEndings = list.map((e) => EndingItem(
        sentence: e['sentence'] as String,
        correct: e['correct'] as String,
        wrong: (e['wrong'] as List<dynamic>).map((w) => w.toString()).toList(),
        explainUk: e['explainUk'] as String,
        explainRu: e['explainRu'] as String,
      )).toList();
      return _cachedEndings!;
    } catch (_) {
      return endingItems;
    }
  }

  static Future<List<FalseFriendItem>> getFalseFriends() async {
    if (_cachedFalseFriends != null && _cachedFalseFriends!.isNotEmpty) return _cachedFalseFriends!;
    try {
      final raw = await rootBundle.loadString('assets/drills/false_friends.json');
      final list = jsonDecode(raw) as List<dynamic>;
      _cachedFalseFriends = list.map((e) => FalseFriendItem(
        pl: e['pl'] as String,
        uk: e['uk'] as String,
        ru: e['ru'] as String,
        trapUk: e['trapUk'] as String,
        trapRu: e['trapRu'] as String,
        noteUk: e['noteUk'] as String,
        noteRu: e['noteRu'] as String,
      )).toList();
      return _cachedFalseFriends!;
    } catch (_) {
      return falseFriendItems;
    }
  }

  static Future<List<NumberPriceItem>> getNumbersPrices() async {
    if (_cachedNumbersPrices != null && _cachedNumbersPrices!.isNotEmpty) return _cachedNumbersPrices!;
    try {
      final raw = await rootBundle.loadString('assets/drills/numbers_prices.json');
      final list = jsonDecode(raw) as List<dynamic>;
      _cachedNumbersPrices = list.map((e) => NumberPriceItem(
        id: e['id'] as String,
        spokenPl: e['spokenPl'] as String,
        correct: e['correct'] as String,
        wrong: (e['wrong'] as List<dynamic>).map((w) => w.toString()).toList(),
        explainUk: e['explainUk'] as String,
        explainRu: e['explainRu'] as String,
        promptPl: e['promptPl'] as String?,
      )).toList();
      return _cachedNumbersPrices!;
    } catch (_) {
      return numberPriceItems;
    }
  }

  static Future<List<AudioWordItem>> getAudioWords() async {
    if (_cachedAudioWords != null && _cachedAudioWords!.isNotEmpty) return _cachedAudioWords!;
    try {
      final raw = await rootBundle.loadString('assets/drills/audio_words.json');
      final list = jsonDecode(raw) as List<dynamic>;
      _cachedAudioWords = list.map((e) => AudioWordItem(
        pl: e['pl'] as String,
        uk: e['uk'] as String,
        ru: e['ru'] as String,
        distractorsUk: ((e['distractorsUk'] ?? []) as List<dynamic>).map((w) => w.toString()).toList(),
        distractorsRu: ((e['distractorsRu'] ?? []) as List<dynamic>).map((w) => w.toString()).toList(),
      )).toList();
      return _cachedAudioWords!;
    } catch (_) {
      return seedWords.map((s) => AudioWordItem(pl: s.pl, uk: s.uk, ru: s.ru)).toList();
    }
  }
}
