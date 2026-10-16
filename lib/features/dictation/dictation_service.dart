import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/di/providers.dart';
import '../review/drill_progress_service.dart';
import 'dictation_item.dart';

enum DictationMode {
  traps, // Золотой фонд орфографических ловушек (rz/ż, ch/h, u/ó, ą/ę)
  myDeck, // Слова из персональной колоды пользователя
}

/// Сервис подготовки и адаптивного отбора заданий диктанта.
class DictationService {
  DictationService(this._db);

  final AppDatabase _db;
  static List<DictationItem>? _cachedTraps;

  /// Загрузка орфографических ловушек из json-ассетов.
  static Future<List<DictationItem>> loadTraps() async {
    if (_cachedTraps != null && _cachedTraps!.isNotEmpty) {
      return _cachedTraps!;
    }
    try {
      final raw = await rootBundle.loadString('assets/drills/dictation_words.json');
      final list = jsonDecode(raw) as List<dynamic>;
      _cachedTraps = list
          .map((e) => DictationItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return _cachedTraps!;
    } catch (_) {
      return const [];
    }
  }

  /// Адаптивная выборка заданий для раунда диктанта.
  Future<List<DictationItem>> buildRound({
    required DictationMode mode,
    int count = 8,
  }) async {
    if (mode == DictationMode.myDeck) {
      final words = await _db.allWords();
      if (words.isEmpty) {
        // Если колода пуста, переключаемся на ловушки
        return _selectAdaptiveTraps(count);
      }
      final deckItems = words.map((w) {
        return DictationItem(
          id: 'deck_${w.id}',
          word: w.lemma.trim(),
          category: 'deck',
          translationUk: w.translationUk ?? '',
          translationRu: w.translationRu ?? '',
          translationPl: w.surfaceForm ?? w.lemma,
          ruleUk: 'Слово з вашого персонального словника. Перевірте написання та наголос.',
          ruleRu: 'Слово из вашего персонального словаря. Проверьте написание и ударение.',
          rulePl: 'Słowo z Twojego słownika.',
          examplePl: w.examplePl,
        );
      }).toList();

      return DrillProgressService.instance.selectAdaptive<DictationItem>(
        category: 'dictation_deck',
        allItems: deckItems,
        idOf: (item) => item.id,
        count: count,
      );
    } else {
      return _selectAdaptiveTraps(count);
    }
  }

  Future<List<DictationItem>> _selectAdaptiveTraps(int count) async {
    final allTraps = await loadTraps();
    if (allTraps.isEmpty) return const [];

    return DrillProgressService.instance.selectAdaptive<DictationItem>(
      category: 'dictation',
      allItems: allTraps,
      idOf: (item) => item.id,
      count: count,
    );
  }

  /// Нормализация текста для проверки орфографии.
  static String normalize(String s) {
    return s.trim().toLowerCase().replaceAll(RegExp(r'[.,!?;:"„”\s]+'), '');
  }

  /// Проверка ответа: верно ли введено слово.
  static bool checkAnswer(String userInput, String expectedWord) {
    return normalize(userInput) == normalize(expectedWord);
  }

  /// Диагностика типичной орфографической ошибки.
  static String? detectOrthographyMistake(String input, String expected) {
    final inp = normalize(input);
    final exp = normalize(expected);

    if (inp == exp) return null;

    if (exp.contains('rz') && inp.contains('ż')) {
      return 'Внимание: в этом слове пишется «rz», а не «ż»!';
    }
    if (exp.contains('ż') && inp.contains('rz')) {
      return 'Внимание: в этом слове пишется «ż», а не «rz»!';
    }
    if (exp.contains('ó') && inp.contains('u')) {
      return 'Внимание: в этом слове пишется «ó» с черточкой, а не «u»!';
    }
    if (exp.contains('u') && inp.contains('ó')) {
      return 'Внимание: в этом слове пишется обычное «u», а не «ó»!';
    }
    if (exp.contains('ch') && inp.contains('h')) {
      return 'Внимание: в этом слове пишется «ch», а не «h»!';
    }
    if (exp.contains('h') && inp.contains('ch')) {
      return 'Внимание: в этом слове пишется «h», а не «ch»!';
    }
    if ((exp.contains('ą') || exp.contains('ę')) &&
        (inp.contains('om') || inp.contains('on') || inp.contains('em') || inp.contains('en'))) {
      return 'Внимание: здесь пишется носовой гласный с хвостиком (ą / ę)!';
    }

    return null;
  }
}

final dictationServiceProvider = Provider<DictationService>((ref) {
  return DictationService(ref.watch(databaseProvider));
});
