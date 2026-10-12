import 'dart:convert';

import '../../core/ai_client/ai_client.dart';
import '../../core/db/app_database.dart';
import '../scanner/translation_service.dart';

class AnalysisExample {
  const AnalysisExample({required this.pl, required this.tr});
  final String pl;
  final String tr;
}

/// Результат ИИ-разбора слова в контексте.
class WordAnalysis {
  const WordAnalysis({
    required this.lemma,
    required this.pos,
    required this.gender,
    required this.translation,
    required this.caseAnalysis,
    required this.isFalseFriend,
    required this.falseFriendNote,
    required this.examples,
  });

  final String lemma;
  final String? pos;
  final String? gender;
  final String translation;
  final String caseAnalysis;
  final bool isFalseFriend;
  final String? falseFriendNote;
  final List<AnalysisExample> examples;

  factory WordAnalysis.fromJson(Map<String, dynamic> j) {
    String? s(dynamic v) {
      final t = v?.toString().trim();
      return (t == null || t.isEmpty || t == 'null') ? null : t;
    }

    final ex = <AnalysisExample>[];
    final raw = j['examples'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          final pl = s(e['pl']);
          if (pl != null) {
            ex.add(AnalysisExample(pl: pl, tr: s(e['tr']) ?? ''));
          }
        }
      }
    }
    return WordAnalysis(
      lemma: s(j['lemma']) ?? '',
      pos: s(j['pos']),
      gender: s(j['gender']),
      translation: s(j['translation']) ?? '',
      caseAnalysis: s(j['case_analysis']) ?? '',
      isFalseFriend: j['is_false_friend'] == true,
      falseFriendNote: s(j['false_friend_note']),
      examples: ex,
    );
  }

  Map<String, dynamic> toJson() => {
        'lemma': lemma,
        'pos': pos,
        'gender': gender,
        'translation': translation,
        'case_analysis': caseAnalysis,
        'is_false_friend': isFalseFriend,
        'false_friend_note': falseFriendNote,
        'examples': [
          for (final e in examples) {'pl': e.pl, 'tr': e.tr}
        ],
      };
}

/// ИИ-разбор слова через настроенный шлюз (с кэшем в SQLite).
class WordAnalysisService {
  WordAnalysisService(this._ai, this._db);

  final AiClient _ai;
  final AppDatabase _db;

  Future<WordAnalysis> analyze({
    required String word,
    required String sentence,
    required UiLang lang,
  }) async {
    final key = 'analysis|${_ai.model}|${lang.name}|'
        '${word.toLowerCase()}|${sentence.toLowerCase()}';
    final cached = await _db.cacheGet(key);
    if (cached != null) {
      final obj = extractJson(cached);
      if (obj != null) return WordAnalysis.fromJson(obj);
    }

    final langName = lang == UiLang.uk ? 'украинском' : 'русском';
    final system = '''
Ты — преподаватель польского языка для людей, говорящих на ${lang == UiLang.uk ? 'украинском' : 'русском'}.
Тебе дают польское слово и предложение, где оно встретилось (текст получен OCR и может содержать ошибки).
Отвечай ТОЛЬКО одним JSON-объектом без пояснений и без markdown, строго по схеме:
{
  "lemma": "базовая форма (именительный падеж ед.ч. / инфинитив)",
  "pos": "часть речи",
  "gender": "m | f | n | null",
  "translation": "перевод базовой формы на $langName языке",
  "case_analysis": "1-2 предложения на $langName: какая форма/падеж/время в этом предложении и почему такое окончание",
  "is_false_friend": true|false,
  "false_friend_note": "если слово — «ложный друг» для носителя $langName языка, объясни обманчивое сходство; иначе null",
  "examples": [{"pl": "живое предложение, которое сказал бы поляк", "tr": "перевод на $langName"}, {"pl": "...", "tr": "..."}]
}
Ровно 2 примера. Не выдумывай: если не уверен, пиши это в case_analysis. Не добавляй ничего вне JSON.''';

    final user = 'Слово: "$word"\nПредложение: "${sentence.trim().isEmpty ? word : sentence}"';

    final obj = await _ai.chatJson([
      ChatMessage('system', system),
      ChatMessage('user', user),
    ]);
    final analysis = WordAnalysis.fromJson(obj);
    if (analysis.lemma.isEmpty && analysis.translation.isEmpty) {
      throw AiException('ИИ не смог разобрать это слово. Попробуйте ещё раз.');
    }
    // Кэшируем нормализованный вид, чтобы чтение было стабильным.
    await _db.cachePut(key, jsonEncode(analysis.toJson()));
    return analysis;
  }
}
