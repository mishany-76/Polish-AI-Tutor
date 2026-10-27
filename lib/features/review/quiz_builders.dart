import 'dart:math';

import '../../core/db/app_database.dart';
import '../scanner/translation_service.dart';
import 'drill_data.dart';
import 'drill_progress_service.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    this.promptSub,
    this.speakText,
    this.translation,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final String prompt;
  final String? promptSub;

  /// Если задано — вопрос озвучивается (польский TTS).
  final String? speakText;
  final String? translation;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

QuizQuestion _make({
  required String id,
  required String prompt,
  String? sub,
  String? speak,
  String? translation,
  required String correct,
  required List<String> wrong,
  required String explanation,
  required Random rnd,
}) {
  final options = [correct, ...wrong]..shuffle(rnd);
  return QuizQuestion(
    id: id,
    prompt: prompt,
    promptSub: sub,
    speakText: speak,
    translation: translation,
    options: options,
    correctIndex: options.indexOf(correct),
    explanation: explanation,
  );
}

/// Адаптивный режим 1: «Угадай правильное окончание».
/// Исключает выученные, в первую очередь повторяет ошибки (1800+ предложений).
Future<List<QuizQuestion>> buildAdaptiveEndingsQuiz(UiLang lang, {int count = 8}) async {
  final allItems = await DrillDataLoader.getEndings();
  final chosen = await DrillProgressService.instance.selectAdaptive<EndingItem>(
    category: 'endings',
    allItems: allItems,
    idOf: (e) => e.sentence,
    count: count,
  );
  final rnd = Random();
  return [
    for (final e in chosen)
      _make(
        id: e.sentence,
        prompt: e.sentence,
        sub: lang == UiLang.uk ? 'Оберіть правильну форму' : 'Выберите правильную форму',
        speak: e.sentence.replaceAll('___', e.correct),
        correct: e.correct,
        wrong: e.wrong,
        explanation: lang == UiLang.uk ? e.explainUk : e.explainRu,
        rnd: rnd,
      ),
  ];
}

/// Обычный (не адаптивный) фолбэк для окончаний.
List<QuizQuestion> buildEndingsQuiz(UiLang lang, {int count = 8, Random? random}) {
  final rnd = random ?? Random();
  final items = [...endingItems]..shuffle(rnd);
  return [
    for (final e in items.take(count))
      _make(
        id: e.sentence,
        prompt: e.sentence,
        sub: lang == UiLang.uk ? 'Оберіть правильну форму' : 'Выберите правильную форму',
        speak: e.sentence.replaceAll('___', e.correct),
        correct: e.correct,
        wrong: e.wrong,
        explanation: lang == UiLang.uk ? e.explainUk : e.explainRu,
        rnd: rnd,
      ),
  ];
}

String _resolveTrapPolish(FalseFriendItem f) {
  final note = f.noteRu;
  final match = RegExp(r'[—–-]\s*([a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ]{3,})').allMatches(note);
  if (match.length >= 2) {
    final candidate = match.last.group(1)?.trim();
    if (candidate != null && candidate.toLowerCase() != f.pl.toLowerCase()) {
      return candidate;
    }
  }
  return '';
}

/// Адаптивный режим 3: «Осторожно, ложные друзья!».
/// 1200+ карточек, перехват коварных языковых ловушек.
/// Ответы содержат дубляж польского слова и перевода для привыкания глаз.
Future<List<QuizQuestion>> buildAdaptiveFalseFriendsQuiz(UiLang lang, {int count = 8}) async {
  final allItems = await DrillDataLoader.getFalseFriends();
  final chosen = await DrillProgressService.instance.selectAdaptive<FalseFriendItem>(
    category: 'false_friends',
    allItems: allItems,
    idOf: (f) => f.pl,
    count: count,
  );
  final rnd = Random();
  final uk = lang == UiLang.uk;
  return [
    for (final f in chosen)
      () {
        final correctTr = uk ? f.uk : f.ru;
        final correctOption = '${f.pl} — $correctTr';

        final trapTr = uk ? f.trapUk : f.trapRu;
        final trapPl = _resolveTrapPolish(f);
        final trapOption = trapPl.isNotEmpty
            ? '$trapPl — $trapTr'
            : '$trapTr (${f.pl} ➔ хибний зміст)';

        final otherItems = allItems.where((o) => o.pl != f.pl).toList()..shuffle(rnd);
        final otherOptions = [
          for (final o in otherItems.take(2))
            '${o.pl} — ${uk ? o.uk : o.ru}',
        ];

        return _make(
          id: f.pl,
          prompt: f.pl,
          sub: uk ? '⚠️ Оберіть правильне значення та переклад:' : '⚠️ Выберите правильное значение и перевод:',
          speak: f.pl,
          correct: correctOption,
          wrong: [trapOption, ...otherOptions],
          explanation: uk ? f.noteUk : f.noteRu,
          rnd: rnd,
        );
      }(),
  ];
}

/// Обычный фолбэк для ложных друзей.
List<QuizQuestion> buildFalseFriendsQuiz(UiLang lang, {int count = 8, Random? random}) {
  final rnd = random ?? Random();
  final uk = lang == UiLang.uk;
  final items = [...falseFriendItems]..shuffle(rnd);
  final chosen = items.take(count).toList();
  return [
    for (final f in chosen)
      () {
        final correctTr = uk ? f.uk : f.ru;
        final correctOption = '${f.pl} — $correctTr';

        final trapTr = uk ? f.trapUk : f.trapRu;
        final trapPl = _resolveTrapPolish(f);
        final trapOption = trapPl.isNotEmpty
            ? '$trapPl — $trapTr'
            : '$trapTr (${f.pl} ➔ хибний зміст)';

        final otherItems = falseFriendItems.where((o) => o.pl != f.pl).toList()..shuffle(rnd);
        final otherOptions = [
          for (final o in otherItems.take(2))
            '${o.pl} — ${uk ? o.uk : o.ru}',
        ];

        return _make(
          id: f.pl,
          prompt: f.pl,
          sub: uk ? '⚠️ Оберіть правильне значення та переклад:' : '⚠️ Выберите правильное значение и перевод:',
          speak: f.pl,
          correct: correctOption,
          wrong: [trapOption, ...otherOptions],
          explanation: uk ? f.noteUk : f.noteRu,
          rnd: rnd,
        );
      }(),
  ];
}

/// Адаптивный режим 2: «Аудио-тренажёр».
/// Масштабированная база (1800+ выражений и слов из живой речи).
/// Вопрос показывает польский текст крупно, а варианты ответов дублируют польский и перевод.
Future<List<QuizQuestion>> buildAdaptiveAudioQuiz(
  List<Word> deck,
  UiLang lang, {
  int count = 8,
}) async {
  final uk = lang == UiLang.uk;
  final pool = <String, String>{};
  for (final w in deck) {
    final tr = w.translation(uk);
    if (tr != null && tr.trim().isNotEmpty) pool[w.lemma] = tr.trim();
  }
  final audioWords = await DrillDataLoader.getAudioWords();
  for (final a in audioWords) {
    pool.putIfAbsent(a.pl, () => uk ? a.uk : a.ru);
  }
  for (final s in seedWords) {
    pool.putIfAbsent(s.pl, () => uk ? s.uk : s.ru);
  }

  final allKeys = pool.keys.toList();
  final chosen = await DrillProgressService.instance.selectAdaptive<String>(
    category: 'audio',
    allItems: allKeys,
    idOf: (k) => k,
    count: count,
  );

  final rnd = Random();
  return [
    for (final pl in chosen)
      () {
        final correctTr = pool[pl]!;
        final correctOption = '$pl — $correctTr';

        final otherKeys = pool.keys.where((k) => k != pl).toList()..shuffle(rnd);
        final wrongOptions = [
          for (final oKey in otherKeys.take(3))
            '$oKey — ${pool[oKey]!}',
        ];

        return _make(
          id: pl,
          prompt: pl,
          sub: uk ? '🎧 Послухайте та оберіть переклад:' : '🎧 Послушайте и выберите перевод:',
          speak: pl,
          correct: correctOption,
          wrong: wrongOptions,
          explanation: '$pl — $correctTr',
          rnd: rnd,
        );
      }(),
  ];
}

/// Обычный фолбэк для аудио-тренажёра.
List<QuizQuestion> buildAudioQuiz(
  List<Word> deck,
  UiLang lang, {
  int count = 8,
  Random? random,
}) {
  final rnd = random ?? Random();
  final uk = lang == UiLang.uk;

  final pool = <String, String>{};
  for (final w in deck) {
    final tr = w.translation(uk);
    if (tr != null && tr.trim().isNotEmpty) pool[w.lemma] = tr.trim();
  }
  for (final s in seedWords) {
    pool.putIfAbsent(s.pl, () => uk ? s.uk : s.ru);
  }

  final allWords = pool.keys.toList()..shuffle(rnd);
  final order = allWords.take(count).toList();

  return [
    for (final pl in order)
      () {
        final correctTr = pool[pl]!;
        final correctOption = '$pl — $correctTr';

        final otherKeys = pool.keys.where((k) => k != pl).toList()..shuffle(rnd);
        final wrongOptions = [
          for (final oKey in otherKeys.take(3))
            '$oKey — ${pool[oKey]!}',
        ];

        return _make(
          id: pl,
          prompt: pl,
          sub: uk ? '🎧 Послухайте та оберіть переклад:' : '🎧 Послушайте и выберите перевод:',
          speak: pl,
          correct: correctOption,
          wrong: wrongOptions,
          explanation: '$pl — $correctTr',
          rnd: rnd,
        );
      }(),
  ];
}

/// Адаптивный режим 4: «Числа, ціни та рахунок».
/// 1200+ вопросов: суммы на кассе, время/часы, коварные десятки и сотни.
/// Польский текст вопроса всегда виден крупно и четко перед глазами!
Future<List<QuizQuestion>> buildAdaptiveNumbersPricesQuiz(UiLang lang, {int count = 8}) async {
  final allItems = await DrillDataLoader.getNumbersPrices();
  final chosen = await DrillProgressService.instance.selectAdaptive<NumberPriceItem>(
    category: 'numbers_prices',
    allItems: allItems,
    idOf: (n) => n.id,
    count: count,
  );
  final rnd = Random();
  final uk = lang == UiLang.uk;
  return [
    for (final n in chosen)
      _make(
        id: n.id,
        prompt: n.spokenPl,
        sub: n.promptPl ?? (uk ? '🎧 Послухайте та оберіть значення:' : '🎧 Послушайте и выберите значение:'),
        speak: n.spokenPl,
        correct: n.correct,
        wrong: n.wrong,
        explanation: '${uk ? n.explainUk : n.explainRu} («${n.spokenPl}» ➔ ${n.correct})',
        rnd: rnd,
      ),
  ];
}

List<QuizQuestion> buildNumbersPricesQuiz(UiLang lang, {int count = 8, Random? random}) {
  final rnd = random ?? Random();
  final items = [...numberPriceItems]..shuffle(rnd);
  final uk = lang == UiLang.uk;
  return [
    for (final n in items.take(count))
      _make(
        id: n.id,
        prompt: n.spokenPl,
        sub: n.promptPl ?? (uk ? '🎧 Послухайте та оберіть значення:' : '🎧 Послушайте и выберите значение:'),
        speak: n.spokenPl,
        correct: n.correct,
        wrong: n.wrong,
        explanation: '${uk ? n.explainUk : n.explainRu} («${n.spokenPl}» ➔ ${n.correct})',
        rnd: rnd,
      ),
  ];
}

