import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/ai_client/ai_client.dart';
import '../../core/di/providers.dart';
import '../onboarding/user_profile.dart' show sharedPreferencesProvider;
import '../scanner/translation_service.dart' show UiLang;
import 'exam_model.dart';

class ExamService {
  ExamService(this._prefs, this._aiClient);

  final SharedPreferences _prefs;
  final AiClient _aiClient;

  static const String _kExamHistory = 'exam_results_history';

  List<ExamAssessmentResult> getHistory() {
    final raw = _prefs.getStringList(_kExamHistory) ?? [];
    final list = <ExamAssessmentResult>[];
    for (final s in raw) {
      try {
        final j = jsonDecode(s) as Map<String, dynamic>;
        list.add(ExamAssessmentResult.fromJson(j));
      } catch (_) {}
    }
    // Сортировка от новых к старым
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  ExamAssessmentResult? getLatestResult() {
    final h = getHistory();
    return h.isNotEmpty ? h.first : null;
  }

  ExamAssessmentResult? getBestResult() {
    final h = getHistory();
    if (h.isEmpty) return null;
    h.sort((a, b) => b.score.compareTo(a.score));
    return h.first;
  }

  Future<void> saveResult(ExamAssessmentResult result) async {
    final current = _prefs.getStringList(_kExamHistory) ?? [];
    current.add(jsonEncode(result.toJson()));
    await _prefs.setStringList(_kExamHistory, current);

    // Засчитываем в достижения диалогов
    try {
      await AchievementService.instance.increment('dialogs_done');
    } catch (_) {}
  }

  /// Запрос к ИИ для полноценной оценки диалога экзамена по шкале CEFR
  Future<ExamAssessmentResult> evaluateExam({
    required List<ChatMessage> transcript,
    required String examinerName,
    required UiLang lang,
  }) async {
    final userUtterances = transcript
        .where((m) => m.role == 'user')
        .map((m) => m.content)
        .toList();

    if (userUtterances.isEmpty) {
      return ExamAssessmentResult.evaluateFallback(
        userUtterances: [],
        examinerName: examinerName,
        lang: lang,
      );
    }

    final targetLang = lang == UiLang.uk ? 'українською' : (lang == UiLang.pl ? 'po polsku' : 'на русском');

    final prompt = '''
Jesteś członkiem Państwowej Komisji Egzaminacyjnej Języka Polskiego jako Obcego.
Oto pełny zapis egzaminu ustnego kandydata (dialog z egzaminatorem $examinerName):

${transcript.map((m) => '${m.role == 'assistant' ? 'Egzaminator' : 'Kandydat'}: ${m.content}').join('\n')}

Oceń wypowiedzi kandydata według Europejskiego Systemu Opisu Kształcenia Językowego (CEFR) na poziomach A1, A2, B1, B2.
Kryteria oceny (każde od 0 do 25 punktów, łącznie 0–100 punktów):
1. Zasób leksykalny i słownictwo (0-25)
2. Poprawność gramatyczna i fleksyjna (0-25)
3. Płynność, spójność i budowa zdań (0-25)
4. Reakcja językowa i zrozumienie pytań (0-25)

Warunek zaliczenia (passed): score >= 60 punktów.
Zwróć odpowiedź WYŁĄCZNIE jako czysty obiekt JSON (bez markdown ```json):
{
  "overallLevel": "A1" | "A2" | "B1" | "B2",
  "score": liczba_całkowita_0_100,
  "passed": true_lub_false,
  "vocabScore": liczba_0_25,
  "grammarScore": liczba_0_25,
  "fluencyScore": liczba_0_25,
  "interactionScore": liczba_0_25,
  "feedbackPl": "Krótkie profesjonalne podsumowanie po polsku (2-3 zdania)",
  "feedbackTr": "To samo podsumowanie przetłumaczone na język $targetLang",
  "strongPoints": ["mocna strona 1 po $targetLang", "mocna strona 2"],
  "weakPoints": ["słaba strona / błędy do poprawy po $targetLang"],
  "recommendations": ["praktyczna rada po $targetLang"]
}
''';

    try {
      final response = await _aiClient.chat([
        ChatMessage('system', 'Jesteś oficjalnym egzaminatorem języka polskiego. Zwracasz wyłącznie poprawny JSON.'),
        ChatMessage('user', prompt),
      ], temperature: 0.3);

      final clean = response.replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
                            .replaceAll(RegExp(r'\s*```$', multiLine: true), '')
                            .trim();

      final json = jsonDecode(clean) as Map<String, dynamic>;
      final result = ExamAssessmentResult.fromJson({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'date': DateTime.now().toIso8601String(),
        'examinerName': examinerName,
        'overallLevel': json['overallLevel'] ?? 'A2',
        'score': json['score'] ?? 70,
        'passed': json['passed'] ?? true,
        'vocabScore': json['vocabScore'] ?? 18,
        'grammarScore': json['grammarScore'] ?? 18,
        'fluencyScore': json['fluencyScore'] ?? 17,
        'interactionScore': json['interactionScore'] ?? 17,
        'feedbackPl': json['feedbackPl'],
        'feedbackTr': json['feedbackTr'],
        'strongPoints': json['strongPoints'],
        'weakPoints': json['weakPoints'],
        'recommendations': json['recommendations'],
      });

      await saveResult(result);
      return result;
    } catch (_) {
      final fallback = ExamAssessmentResult.evaluateFallback(
        userUtterances: userUtterances,
        examinerName: examinerName,
        lang: lang,
      );
      await saveResult(fallback);
      return fallback;
    }
  }
}

final examServiceProvider = Provider<ExamService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final ai = ref.watch(aiClientProvider);
  return ExamService(prefs, ai);
});

