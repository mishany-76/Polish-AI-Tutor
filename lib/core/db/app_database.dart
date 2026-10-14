import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../srs/sm2.dart';

part 'app_database.g.dart';

/// Слова пользователя + состояние интервального повторения (SM-2).
class Words extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Базовая форма в нижнем регистре (уникальна).
  TextColumn get lemma => text().unique()();

  /// Форма, как слово встретилось в тексте.
  TextColumn get surfaceForm => text().nullable()();
  TextColumn get pos => text().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get translationUk => text().nullable()();
  TextColumn get translationRu => text().nullable()();
  TextColumn get examplePl => text().nullable()();
  TextColumn get exampleTr => text().nullable()();

  /// Разбор падежа/окончания, заметки.
  TextColumn get note => text().nullable()();
  BoolColumn get isFalseFriend =>
      boolean().withDefault(const Constant(false))();

  /// scan | chat | manual
  TextColumn get source => text().withDefault(const Constant('scan'))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  // --- SM-2 ---
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get dueAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get lastReviewAt => dateTime().nullable()();
}

/// Кэш ответов ИИ (экономит квоту шлюза).
class AiCache extends Table {
  TextColumn get key => text()();
  TextColumn get response => text()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {key};
}

enum WordStatus { fresh, learning, mastered }

extension WordX on Word {
  WordStatus get status => reps == 0
      ? WordStatus.fresh
      : (intervalDays >= 21 ? WordStatus.mastered : WordStatus.learning);

  bool get isDue => !dueAt.isAfter(DateTime.now());

  String? translation(bool uk) {
    final primary = uk ? translationUk : translationRu;
    return primary ?? (uk ? translationRu : translationUk);
  }
}

@DriftDatabase(tables: [Words, AiCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'polish_tutor'));

  @override
  int get schemaVersion => 1;

  static String normalize(String s) => s.trim().toLowerCase();

  Stream<List<Word>> watchWords() => (select(words)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();

  Future<List<Word>> allWords() => select(words).get();

  /// Слово по лемме или по форме из текста.
  Future<Word?> findByForm(String form) {
    final f = normalize(form);
    return (select(words)
          ..where((t) => t.lemma.equals(f) | t.surfaceForm.equals(f))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<Word>> dueWords({int limit = 20}) => (select(words)
        ..where((t) => t.dueAt.isSmallerOrEqualValue(DateTime.now()))
        ..orderBy([(t) => OrderingTerm.asc(t.dueAt)])
        ..limit(limit))
      .get();

  /// Добавляет слово из скана. Возвращает false, если оно уже в колоде.
  Future<bool> addScanWord({
    required String form,
    String? translation,
    required bool uk,
    String? examplePl,
    String source = 'scan',
  }) async {
    if (await findByForm(form) != null) return false;
    final f = normalize(form);
    await into(words).insert(WordsCompanion.insert(
      lemma: f,
      surfaceForm: Value(f),
      translationUk: Value(uk ? translation : null),
      translationRu: Value(uk ? null : translation),
      examplePl: Value(examplePl),
      source: Value(source),
    ));
    return true;
  }

  /// Ручной ввод слова пользователем.
  Future<bool> addManualWord({
    required String lemma,
    required String translation,
    required bool uk,
    String? example,
    String? note,
  }) async {
    final lem = normalize(lemma);
    if (await findByForm(lem) != null) return false;
    await into(words).insert(WordsCompanion.insert(
      lemma: lem,
      surfaceForm: Value(lem),
      translationUk: Value(uk ? translation : null),
      translationRu: Value(uk ? null : translation),
      examplePl: Value(example?.trim().isEmpty == true ? null : example?.trim()),
      note: Value(note?.trim().isEmpty == true ? null : note?.trim()),
      source: const Value('manual'),
    ));
    return true;
  }

  static const stopwords = {
    'i', 'w', 'z', 'na', 'do', 'o', 'że', 'to', 'nie', 'się', 'co', 'jak', 'a',
    'ale', 'ze', 'po', 'od', 'za', 'dla', 'lub', 'czy', 'bo', 'go', 'jej', 'ich',
    'mu', 'mi', 'cię', 'mnie', 'tobie', 'nim', 'nią', 'nich', 'pan', 'pani',
    'ten', 'ta', 'te', 'tym', 'tej', 'tego', 'tych', 'temu', 'tak', 'tam',
    'tu', 'już', 'tylko', 'jeszcze', 'być', 'jest', 'są', 'był', 'była', 'było',
    'będzie', 'będą', 'ma', 'mają', 'miał', 'oraz', 'więc', 'gdy', 'kiedy', 'przy',
    'bez', 'nad', 'pod', 'przed', 'przez', 'gdzie', 'kto', 'nas', 'was', 'nam', 'wam'
  };

  /// Пакетное добавление уникальных слов из текста с переводами.
  Future<int> batchAddWords(
    List<String> rawWords, {
    required bool uk,
    Map<String, String>? translations,
  }) async {
    int addedCount = 0;
    for (final raw in rawWords) {
      final clean = normalize(raw.replaceAll(
        RegExp(r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$', unicode: true),
        '',
      ));
      if (clean.length < 3) continue;
      if (stopwords.contains(clean)) continue;
      if (RegExp(r'^\d+$').hasMatch(clean)) continue;

      if (await findByForm(clean) == null) {
        final tr = translations?[clean];
        await into(words).insert(WordsCompanion.insert(
          lemma: clean,
          surfaceForm: Value(clean),
          translationUk: Value(uk ? tr : null),
          translationRu: Value(uk ? null : tr),
          source: const Value('batch_text'),
        ));
        addedCount++;
      }
    }
    return addedCount;
  }

  /// Пакетное добавление извлеченных ИИ качественных слов (лемма, перевод, часть речи).
  Future<int> batchAddAiWords(
    List<({String lemma, String translation, String? pos})> aiWords, {
    required bool uk,
  }) async {
    int addedCount = 0;
    for (final item in aiWords) {
      final lem = normalize(item.lemma.replaceAll(
        RegExp(r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$', unicode: true),
        '',
      ));
      if (lem.length < 2) continue;
      if (stopwords.contains(lem)) continue;
      if (RegExp(r'^\d+$').hasMatch(lem)) continue;

      final tr = item.translation.trim();
      if (tr.isEmpty) continue;

      if (await findByForm(lem) == null) {
        await into(words).insert(WordsCompanion.insert(
          lemma: lem,
          surfaceForm: Value(lem),
          translationUk: Value(uk ? tr : null),
          translationRu: Value(uk ? null : tr),
          pos: Value(item.pos?.trim().isEmpty == true ? null : item.pos?.trim()),
          source: const Value('batch_ai'),
        ));
        addedCount++;
      }
    }
    return addedCount;
  }

  /// Добавляет/дополняет слово результатом ИИ-разбора.
  /// Если слово с такой леммой уже есть — данные сливаются в него.
  Future<void> saveAnalysis({
    required String form,
    required String lemma,
    required bool uk,
    String? pos,
    String? gender,
    String? translation,
    String? examplePl,
    String? exampleTr,
    String? note,
    bool isFalseFriend = false,
  }) async {
    final lem = normalize(lemma.isEmpty ? form : lemma);
    final byForm = await findByForm(form);
    final byLemma = await findByForm(lem);
    final target = byLemma ?? byForm;

    final companion = WordsCompanion(
      lemma: Value(lem),
      surfaceForm: Value(normalize(form)),
      pos: Value(pos),
      gender: Value(gender),
      translationUk: uk ? Value(translation) : const Value.absent(),
      translationRu: uk ? const Value.absent() : Value(translation),
      examplePl: Value(examplePl),
      exampleTr: Value(exampleTr),
      note: Value(note),
      isFalseFriend: Value(isFalseFriend),
    );

    if (target == null) {
      await into(words).insert(companion);
      return;
    }
    await (update(words)..where((t) => t.id.equals(target.id)))
        .write(companion);
    // Была отдельная запись по форме — убираем дубликат.
    if (byForm != null && byForm.id != target.id) {
      await (delete(words)..where((t) => t.id.equals(byForm.id))).go();
    }
  }

  Future<void> applyReview(Word w, int rating) {
    final r = sm2(
      ease: w.easeFactor,
      intervalDays: w.intervalDays,
      reps: w.reps,
      lapses: w.lapses,
      rating: rating,
    );
    return (update(words)..where((t) => t.id.equals(w.id))).write(
      WordsCompanion(
        easeFactor: Value(r.ease),
        intervalDays: Value(r.intervalDays),
        reps: Value(r.reps),
        lapses: Value(r.lapses),
        dueAt: Value(r.due),
        lastReviewAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteWord(int id) =>
      (delete(words)..where((t) => t.id.equals(id))).go();

  /// Очистить весь словарь пользователя (удалить все сохраненные слова).
  Future<int> deleteAllWords() => delete(words).go();

  /// Отложить очередь слов на завтра (очистить очередь повторений на сегодня).
  Future<int> deferDueWordsToTomorrow() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return (update(words)..where((t) => t.dueAt.isSmallerOrEqualValue(DateTime.now())))
        .write(WordsCompanion(dueAt: Value(tomorrow)));
  }

  Future<String?> cacheGet(String key) async {
    final row = await (select(aiCache)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.response;
  }

  Future<void> cachePut(String key, String response) => into(aiCache)
      .insertOnConflictUpdate(AiCacheCompanion.insert(key: key, response: response));

  Future<int> clearCache() => delete(aiCache).go();
}
