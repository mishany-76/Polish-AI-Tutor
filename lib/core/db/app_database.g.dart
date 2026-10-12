// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lemmaMeta = const VerificationMeta('lemma');
  @override
  late final GeneratedColumn<String> lemma = GeneratedColumn<String>(
    'lemma',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _surfaceFormMeta = const VerificationMeta(
    'surfaceForm',
  );
  @override
  late final GeneratedColumn<String> surfaceForm = GeneratedColumn<String>(
    'surface_form',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posMeta = const VerificationMeta('pos');
  @override
  late final GeneratedColumn<String> pos = GeneratedColumn<String>(
    'pos',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _translationUkMeta = const VerificationMeta(
    'translationUk',
  );
  @override
  late final GeneratedColumn<String> translationUk = GeneratedColumn<String>(
    'translation_uk',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _translationRuMeta = const VerificationMeta(
    'translationRu',
  );
  @override
  late final GeneratedColumn<String> translationRu = GeneratedColumn<String>(
    'translation_ru',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _examplePlMeta = const VerificationMeta(
    'examplePl',
  );
  @override
  late final GeneratedColumn<String> examplePl = GeneratedColumn<String>(
    'example_pl',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exampleTrMeta = const VerificationMeta(
    'exampleTr',
  );
  @override
  late final GeneratedColumn<String> exampleTr = GeneratedColumn<String>(
    'example_tr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFalseFriendMeta = const VerificationMeta(
    'isFalseFriend',
  );
  @override
  late final GeneratedColumn<bool> isFalseFriend = GeneratedColumn<bool>(
    'is_false_friend',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_false_friend" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('scan'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _lastReviewAtMeta = const VerificationMeta(
    'lastReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewAt = GeneratedColumn<DateTime>(
    'last_review_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lemma,
    surfaceForm,
    pos,
    gender,
    translationUk,
    translationRu,
    examplePl,
    exampleTr,
    note,
    isFalseFriend,
    source,
    createdAt,
    easeFactor,
    intervalDays,
    reps,
    lapses,
    dueAt,
    lastReviewAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lemma')) {
      context.handle(
        _lemmaMeta,
        lemma.isAcceptableOrUnknown(data['lemma']!, _lemmaMeta),
      );
    } else if (isInserting) {
      context.missing(_lemmaMeta);
    }
    if (data.containsKey('surface_form')) {
      context.handle(
        _surfaceFormMeta,
        surfaceForm.isAcceptableOrUnknown(
          data['surface_form']!,
          _surfaceFormMeta,
        ),
      );
    }
    if (data.containsKey('pos')) {
      context.handle(
        _posMeta,
        pos.isAcceptableOrUnknown(data['pos']!, _posMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('translation_uk')) {
      context.handle(
        _translationUkMeta,
        translationUk.isAcceptableOrUnknown(
          data['translation_uk']!,
          _translationUkMeta,
        ),
      );
    }
    if (data.containsKey('translation_ru')) {
      context.handle(
        _translationRuMeta,
        translationRu.isAcceptableOrUnknown(
          data['translation_ru']!,
          _translationRuMeta,
        ),
      );
    }
    if (data.containsKey('example_pl')) {
      context.handle(
        _examplePlMeta,
        examplePl.isAcceptableOrUnknown(data['example_pl']!, _examplePlMeta),
      );
    }
    if (data.containsKey('example_tr')) {
      context.handle(
        _exampleTrMeta,
        exampleTr.isAcceptableOrUnknown(data['example_tr']!, _exampleTrMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_false_friend')) {
      context.handle(
        _isFalseFriendMeta,
        isFalseFriend.isAcceptableOrUnknown(
          data['is_false_friend']!,
          _isFalseFriendMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('last_review_at')) {
      context.handle(
        _lastReviewAtMeta,
        lastReviewAt.isAcceptableOrUnknown(
          data['last_review_at']!,
          _lastReviewAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lemma: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lemma'],
      )!,
      surfaceForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surface_form'],
      ),
      pos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pos'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      translationUk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_uk'],
      ),
      translationRu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_ru'],
      ),
      examplePl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_pl'],
      ),
      exampleTr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_tr'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isFalseFriend: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_false_friend'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      lastReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review_at'],
      ),
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int id;

  /// Базовая форма в нижнем регистре (уникальна).
  final String lemma;

  /// Форма, как слово встретилось в тексте.
  final String? surfaceForm;
  final String? pos;
  final String? gender;
  final String? translationUk;
  final String? translationRu;
  final String? examplePl;
  final String? exampleTr;

  /// Разбор падежа/окончания, заметки.
  final String? note;
  final bool isFalseFriend;

  /// scan | chat | manual
  final String source;
  final DateTime createdAt;
  final double easeFactor;
  final int intervalDays;
  final int reps;
  final int lapses;
  final DateTime dueAt;
  final DateTime? lastReviewAt;
  const Word({
    required this.id,
    required this.lemma,
    this.surfaceForm,
    this.pos,
    this.gender,
    this.translationUk,
    this.translationRu,
    this.examplePl,
    this.exampleTr,
    this.note,
    required this.isFalseFriend,
    required this.source,
    required this.createdAt,
    required this.easeFactor,
    required this.intervalDays,
    required this.reps,
    required this.lapses,
    required this.dueAt,
    this.lastReviewAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lemma'] = Variable<String>(lemma);
    if (!nullToAbsent || surfaceForm != null) {
      map['surface_form'] = Variable<String>(surfaceForm);
    }
    if (!nullToAbsent || pos != null) {
      map['pos'] = Variable<String>(pos);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || translationUk != null) {
      map['translation_uk'] = Variable<String>(translationUk);
    }
    if (!nullToAbsent || translationRu != null) {
      map['translation_ru'] = Variable<String>(translationRu);
    }
    if (!nullToAbsent || examplePl != null) {
      map['example_pl'] = Variable<String>(examplePl);
    }
    if (!nullToAbsent || exampleTr != null) {
      map['example_tr'] = Variable<String>(exampleTr);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_false_friend'] = Variable<bool>(isFalseFriend);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval_days'] = Variable<int>(intervalDays);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || lastReviewAt != null) {
      map['last_review_at'] = Variable<DateTime>(lastReviewAt);
    }
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      lemma: Value(lemma),
      surfaceForm: surfaceForm == null && nullToAbsent
          ? const Value.absent()
          : Value(surfaceForm),
      pos: pos == null && nullToAbsent ? const Value.absent() : Value(pos),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      translationUk: translationUk == null && nullToAbsent
          ? const Value.absent()
          : Value(translationUk),
      translationRu: translationRu == null && nullToAbsent
          ? const Value.absent()
          : Value(translationRu),
      examplePl: examplePl == null && nullToAbsent
          ? const Value.absent()
          : Value(examplePl),
      exampleTr: exampleTr == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleTr),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isFalseFriend: Value(isFalseFriend),
      source: Value(source),
      createdAt: Value(createdAt),
      easeFactor: Value(easeFactor),
      intervalDays: Value(intervalDays),
      reps: Value(reps),
      lapses: Value(lapses),
      dueAt: Value(dueAt),
      lastReviewAt: lastReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewAt),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      lemma: serializer.fromJson<String>(json['lemma']),
      surfaceForm: serializer.fromJson<String?>(json['surfaceForm']),
      pos: serializer.fromJson<String?>(json['pos']),
      gender: serializer.fromJson<String?>(json['gender']),
      translationUk: serializer.fromJson<String?>(json['translationUk']),
      translationRu: serializer.fromJson<String?>(json['translationRu']),
      examplePl: serializer.fromJson<String?>(json['examplePl']),
      exampleTr: serializer.fromJson<String?>(json['exampleTr']),
      note: serializer.fromJson<String?>(json['note']),
      isFalseFriend: serializer.fromJson<bool>(json['isFalseFriend']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      lastReviewAt: serializer.fromJson<DateTime?>(json['lastReviewAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lemma': serializer.toJson<String>(lemma),
      'surfaceForm': serializer.toJson<String?>(surfaceForm),
      'pos': serializer.toJson<String?>(pos),
      'gender': serializer.toJson<String?>(gender),
      'translationUk': serializer.toJson<String?>(translationUk),
      'translationRu': serializer.toJson<String?>(translationRu),
      'examplePl': serializer.toJson<String?>(examplePl),
      'exampleTr': serializer.toJson<String?>(exampleTr),
      'note': serializer.toJson<String?>(note),
      'isFalseFriend': serializer.toJson<bool>(isFalseFriend),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'lastReviewAt': serializer.toJson<DateTime?>(lastReviewAt),
    };
  }

  Word copyWith({
    int? id,
    String? lemma,
    Value<String?> surfaceForm = const Value.absent(),
    Value<String?> pos = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<String?> translationUk = const Value.absent(),
    Value<String?> translationRu = const Value.absent(),
    Value<String?> examplePl = const Value.absent(),
    Value<String?> exampleTr = const Value.absent(),
    Value<String?> note = const Value.absent(),
    bool? isFalseFriend,
    String? source,
    DateTime? createdAt,
    double? easeFactor,
    int? intervalDays,
    int? reps,
    int? lapses,
    DateTime? dueAt,
    Value<DateTime?> lastReviewAt = const Value.absent(),
  }) => Word(
    id: id ?? this.id,
    lemma: lemma ?? this.lemma,
    surfaceForm: surfaceForm.present ? surfaceForm.value : this.surfaceForm,
    pos: pos.present ? pos.value : this.pos,
    gender: gender.present ? gender.value : this.gender,
    translationUk: translationUk.present
        ? translationUk.value
        : this.translationUk,
    translationRu: translationRu.present
        ? translationRu.value
        : this.translationRu,
    examplePl: examplePl.present ? examplePl.value : this.examplePl,
    exampleTr: exampleTr.present ? exampleTr.value : this.exampleTr,
    note: note.present ? note.value : this.note,
    isFalseFriend: isFalseFriend ?? this.isFalseFriend,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    easeFactor: easeFactor ?? this.easeFactor,
    intervalDays: intervalDays ?? this.intervalDays,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    dueAt: dueAt ?? this.dueAt,
    lastReviewAt: lastReviewAt.present ? lastReviewAt.value : this.lastReviewAt,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      lemma: data.lemma.present ? data.lemma.value : this.lemma,
      surfaceForm: data.surfaceForm.present
          ? data.surfaceForm.value
          : this.surfaceForm,
      pos: data.pos.present ? data.pos.value : this.pos,
      gender: data.gender.present ? data.gender.value : this.gender,
      translationUk: data.translationUk.present
          ? data.translationUk.value
          : this.translationUk,
      translationRu: data.translationRu.present
          ? data.translationRu.value
          : this.translationRu,
      examplePl: data.examplePl.present ? data.examplePl.value : this.examplePl,
      exampleTr: data.exampleTr.present ? data.exampleTr.value : this.exampleTr,
      note: data.note.present ? data.note.value : this.note,
      isFalseFriend: data.isFalseFriend.present
          ? data.isFalseFriend.value
          : this.isFalseFriend,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastReviewAt: data.lastReviewAt.present
          ? data.lastReviewAt.value
          : this.lastReviewAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('lemma: $lemma, ')
          ..write('surfaceForm: $surfaceForm, ')
          ..write('pos: $pos, ')
          ..write('gender: $gender, ')
          ..write('translationUk: $translationUk, ')
          ..write('translationRu: $translationRu, ')
          ..write('examplePl: $examplePl, ')
          ..write('exampleTr: $exampleTr, ')
          ..write('note: $note, ')
          ..write('isFalseFriend: $isFalseFriend, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewAt: $lastReviewAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lemma,
    surfaceForm,
    pos,
    gender,
    translationUk,
    translationRu,
    examplePl,
    exampleTr,
    note,
    isFalseFriend,
    source,
    createdAt,
    easeFactor,
    intervalDays,
    reps,
    lapses,
    dueAt,
    lastReviewAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.lemma == this.lemma &&
          other.surfaceForm == this.surfaceForm &&
          other.pos == this.pos &&
          other.gender == this.gender &&
          other.translationUk == this.translationUk &&
          other.translationRu == this.translationRu &&
          other.examplePl == this.examplePl &&
          other.exampleTr == this.exampleTr &&
          other.note == this.note &&
          other.isFalseFriend == this.isFalseFriend &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.easeFactor == this.easeFactor &&
          other.intervalDays == this.intervalDays &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.dueAt == this.dueAt &&
          other.lastReviewAt == this.lastReviewAt);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> lemma;
  final Value<String?> surfaceForm;
  final Value<String?> pos;
  final Value<String?> gender;
  final Value<String?> translationUk;
  final Value<String?> translationRu;
  final Value<String?> examplePl;
  final Value<String?> exampleTr;
  final Value<String?> note;
  final Value<bool> isFalseFriend;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<double> easeFactor;
  final Value<int> intervalDays;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<DateTime> dueAt;
  final Value<DateTime?> lastReviewAt;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.lemma = const Value.absent(),
    this.surfaceForm = const Value.absent(),
    this.pos = const Value.absent(),
    this.gender = const Value.absent(),
    this.translationUk = const Value.absent(),
    this.translationRu = const Value.absent(),
    this.examplePl = const Value.absent(),
    this.exampleTr = const Value.absent(),
    this.note = const Value.absent(),
    this.isFalseFriend = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewAt = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String lemma,
    this.surfaceForm = const Value.absent(),
    this.pos = const Value.absent(),
    this.gender = const Value.absent(),
    this.translationUk = const Value.absent(),
    this.translationRu = const Value.absent(),
    this.examplePl = const Value.absent(),
    this.exampleTr = const Value.absent(),
    this.note = const Value.absent(),
    this.isFalseFriend = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewAt = const Value.absent(),
  }) : lemma = Value(lemma);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? lemma,
    Expression<String>? surfaceForm,
    Expression<String>? pos,
    Expression<String>? gender,
    Expression<String>? translationUk,
    Expression<String>? translationRu,
    Expression<String>? examplePl,
    Expression<String>? exampleTr,
    Expression<String>? note,
    Expression<bool>? isFalseFriend,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<double>? easeFactor,
    Expression<int>? intervalDays,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lemma != null) 'lemma': lemma,
      if (surfaceForm != null) 'surface_form': surfaceForm,
      if (pos != null) 'pos': pos,
      if (gender != null) 'gender': gender,
      if (translationUk != null) 'translation_uk': translationUk,
      if (translationRu != null) 'translation_ru': translationRu,
      if (examplePl != null) 'example_pl': examplePl,
      if (exampleTr != null) 'example_tr': exampleTr,
      if (note != null) 'note': note,
      if (isFalseFriend != null) 'is_false_friend': isFalseFriend,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewAt != null) 'last_review_at': lastReviewAt,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? lemma,
    Value<String?>? surfaceForm,
    Value<String?>? pos,
    Value<String?>? gender,
    Value<String?>? translationUk,
    Value<String?>? translationRu,
    Value<String?>? examplePl,
    Value<String?>? exampleTr,
    Value<String?>? note,
    Value<bool>? isFalseFriend,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<double>? easeFactor,
    Value<int>? intervalDays,
    Value<int>? reps,
    Value<int>? lapses,
    Value<DateTime>? dueAt,
    Value<DateTime?>? lastReviewAt,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      lemma: lemma ?? this.lemma,
      surfaceForm: surfaceForm ?? this.surfaceForm,
      pos: pos ?? this.pos,
      gender: gender ?? this.gender,
      translationUk: translationUk ?? this.translationUk,
      translationRu: translationRu ?? this.translationRu,
      examplePl: examplePl ?? this.examplePl,
      exampleTr: exampleTr ?? this.exampleTr,
      note: note ?? this.note,
      isFalseFriend: isFalseFriend ?? this.isFalseFriend,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      dueAt: dueAt ?? this.dueAt,
      lastReviewAt: lastReviewAt ?? this.lastReviewAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lemma.present) {
      map['lemma'] = Variable<String>(lemma.value);
    }
    if (surfaceForm.present) {
      map['surface_form'] = Variable<String>(surfaceForm.value);
    }
    if (pos.present) {
      map['pos'] = Variable<String>(pos.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (translationUk.present) {
      map['translation_uk'] = Variable<String>(translationUk.value);
    }
    if (translationRu.present) {
      map['translation_ru'] = Variable<String>(translationRu.value);
    }
    if (examplePl.present) {
      map['example_pl'] = Variable<String>(examplePl.value);
    }
    if (exampleTr.present) {
      map['example_tr'] = Variable<String>(exampleTr.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isFalseFriend.present) {
      map['is_false_friend'] = Variable<bool>(isFalseFriend.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastReviewAt.present) {
      map['last_review_at'] = Variable<DateTime>(lastReviewAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('lemma: $lemma, ')
          ..write('surfaceForm: $surfaceForm, ')
          ..write('pos: $pos, ')
          ..write('gender: $gender, ')
          ..write('translationUk: $translationUk, ')
          ..write('translationRu: $translationRu, ')
          ..write('examplePl: $examplePl, ')
          ..write('exampleTr: $exampleTr, ')
          ..write('note: $note, ')
          ..write('isFalseFriend: $isFalseFriend, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewAt: $lastReviewAt')
          ..write(')'))
        .toString();
  }
}

class $AiCacheTable extends AiCache with TableInfo<$AiCacheTable, AiCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseMeta = const VerificationMeta(
    'response',
  );
  @override
  late final GeneratedColumn<String> response = GeneratedColumn<String>(
    'response',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [key, response, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('response')) {
      context.handle(
        _responseMeta,
        response.isAcceptableOrUnknown(data['response']!, _responseMeta),
      );
    } else if (isInserting) {
      context.missing(_responseMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AiCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiCacheData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      response: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiCacheTable createAlias(String alias) {
    return $AiCacheTable(attachedDatabase, alias);
  }
}

class AiCacheData extends DataClass implements Insertable<AiCacheData> {
  final String key;
  final String response;
  final DateTime createdAt;
  const AiCacheData({
    required this.key,
    required this.response,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['response'] = Variable<String>(response);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiCacheCompanion toCompanion(bool nullToAbsent) {
    return AiCacheCompanion(
      key: Value(key),
      response: Value(response),
      createdAt: Value(createdAt),
    );
  }

  factory AiCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiCacheData(
      key: serializer.fromJson<String>(json['key']),
      response: serializer.fromJson<String>(json['response']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'response': serializer.toJson<String>(response),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiCacheData copyWith({String? key, String? response, DateTime? createdAt}) =>
      AiCacheData(
        key: key ?? this.key,
        response: response ?? this.response,
        createdAt: createdAt ?? this.createdAt,
      );
  AiCacheData copyWithCompanion(AiCacheCompanion data) {
    return AiCacheData(
      key: data.key.present ? data.key.value : this.key,
      response: data.response.present ? data.response.value : this.response,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiCacheData(')
          ..write('key: $key, ')
          ..write('response: $response, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, response, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiCacheData &&
          other.key == this.key &&
          other.response == this.response &&
          other.createdAt == this.createdAt);
}

class AiCacheCompanion extends UpdateCompanion<AiCacheData> {
  final Value<String> key;
  final Value<String> response;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AiCacheCompanion({
    this.key = const Value.absent(),
    this.response = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiCacheCompanion.insert({
    required String key,
    required String response,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       response = Value(response);
  static Insertable<AiCacheData> custom({
    Expression<String>? key,
    Expression<String>? response,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (response != null) 'response': response,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? response,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AiCacheCompanion(
      key: key ?? this.key,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (response.present) {
      map['response'] = Variable<String>(response.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiCacheCompanion(')
          ..write('key: $key, ')
          ..write('response: $response, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordsTable words = $WordsTable(this);
  late final $AiCacheTable aiCache = $AiCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [words, aiCache];
}

typedef $$WordsTableCreateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  required String lemma,
  Value<String?> surfaceForm,
  Value<String?> pos,
  Value<String?> gender,
  Value<String?> translationUk,
  Value<String?> translationRu,
  Value<String?> examplePl,
  Value<String?> exampleTr,
  Value<String?> note,
  Value<bool> isFalseFriend,
  Value<String> source,
  Value<DateTime> createdAt,
  Value<double> easeFactor,
  Value<int> intervalDays,
  Value<int> reps,
  Value<int> lapses,
  Value<DateTime> dueAt,
  Value<DateTime?> lastReviewAt,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  Value<String> lemma,
  Value<String?> surfaceForm,
  Value<String?> pos,
  Value<String?> gender,
  Value<String?> translationUk,
  Value<String?> translationRu,
  Value<String?> examplePl,
  Value<String?> exampleTr,
  Value<String?> note,
  Value<bool> isFalseFriend,
  Value<String> source,
  Value<DateTime> createdAt,
  Value<double> easeFactor,
  Value<int> intervalDays,
  Value<int> reps,
  Value<int> lapses,
  Value<DateTime> dueAt,
  Value<DateTime?> lastReviewAt,
});

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surfaceForm => $composableBuilder(
    column: $table.surfaceForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationUk => $composableBuilder(
    column: $table.translationUk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationRu => $composableBuilder(
    column: $table.translationRu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examplePl => $composableBuilder(
    column: $table.examplePl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleTr => $composableBuilder(
    column: $table.exampleTr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFalseFriend => $composableBuilder(
    column: $table.isFalseFriend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surfaceForm => $composableBuilder(
    column: $table.surfaceForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationUk => $composableBuilder(
    column: $table.translationUk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationRu => $composableBuilder(
    column: $table.translationRu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examplePl => $composableBuilder(
    column: $table.examplePl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleTr => $composableBuilder(
    column: $table.exampleTr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFalseFriend => $composableBuilder(
    column: $table.isFalseFriend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lemma =>
      $composableBuilder(column: $table.lemma, builder: (column) => column);

  GeneratedColumn<String> get surfaceForm => $composableBuilder(
    column: $table.surfaceForm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pos =>
      $composableBuilder(column: $table.pos, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get translationUk => $composableBuilder(
    column: $table.translationUk,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translationRu => $composableBuilder(
    column: $table.translationRu,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examplePl =>
      $composableBuilder(column: $table.examplePl, builder: (column) => column);

  GeneratedColumn<String> get exampleTr =>
      $composableBuilder(column: $table.exampleTr, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isFalseFriend => $composableBuilder(
    column: $table.isFalseFriend,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => column,
  );
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, BaseReferences<_$AppDatabase, $WordsTable, Word>),
          Word,
          PrefetchHooks Function()
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> lemma = const Value.absent(),
                Value<String?> surfaceForm = const Value.absent(),
                Value<String?> pos = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> translationUk = const Value.absent(),
                Value<String?> translationRu = const Value.absent(),
                Value<String?> examplePl = const Value.absent(),
                Value<String?> exampleTr = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isFalseFriend = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewAt = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                lemma: lemma,
                surfaceForm: surfaceForm,
                pos: pos,
                gender: gender,
                translationUk: translationUk,
                translationRu: translationRu,
                examplePl: examplePl,
                exampleTr: exampleTr,
                note: note,
                isFalseFriend: isFalseFriend,
                source: source,
                createdAt: createdAt,
                easeFactor: easeFactor,
                intervalDays: intervalDays,
                reps: reps,
                lapses: lapses,
                dueAt: dueAt,
                lastReviewAt: lastReviewAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String lemma,
                Value<String?> surfaceForm = const Value.absent(),
                Value<String?> pos = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> translationUk = const Value.absent(),
                Value<String?> translationRu = const Value.absent(),
                Value<String?> examplePl = const Value.absent(),
                Value<String?> exampleTr = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isFalseFriend = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewAt = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                lemma: lemma,
                surfaceForm: surfaceForm,
                pos: pos,
                gender: gender,
                translationUk: translationUk,
                translationRu: translationRu,
                examplePl: examplePl,
                exampleTr: exampleTr,
                note: note,
                isFalseFriend: isFalseFriend,
                source: source,
                createdAt: createdAt,
                easeFactor: easeFactor,
                intervalDays: intervalDays,
                reps: reps,
                lapses: lapses,
                dueAt: dueAt,
                lastReviewAt: lastReviewAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordsTable, Word>(table),
                  BaseReferences<_$AppDatabase, $WordsTable, Word>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, BaseReferences<_$AppDatabase, $WordsTable, Word>),
      Word,
      PrefetchHooks Function()
    >;
typedef $$AiCacheTableCreateCompanionBuilder = AiCacheCompanion Function({
  required String key,
  required String response,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$AiCacheTableUpdateCompanionBuilder = AiCacheCompanion Function({
  Value<String> key,
  Value<String> response,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AiCacheTableFilterComposer
    extends Composer<_$AppDatabase, $AiCacheTable> {
  $$AiCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get response => $composableBuilder(
    column: $table.response,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $AiCacheTable> {
  $$AiCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get response => $composableBuilder(
    column: $table.response,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiCacheTable> {
  $$AiCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get response =>
      $composableBuilder(column: $table.response, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AiCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiCacheTable,
          AiCacheData,
          $$AiCacheTableFilterComposer,
          $$AiCacheTableOrderingComposer,
          $$AiCacheTableAnnotationComposer,
          $$AiCacheTableCreateCompanionBuilder,
          $$AiCacheTableUpdateCompanionBuilder,
          (
            AiCacheData,
            BaseReferences<_$AppDatabase, $AiCacheTable, AiCacheData>,
          ),
          AiCacheData,
          PrefetchHooks Function()
        > {
  $$AiCacheTableTableManager(_$AppDatabase db, $AiCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> response = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiCacheCompanion(
                key: key,
                response: response,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String response,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiCacheCompanion.insert(
                key: key,
                response: response,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiCacheTable, AiCacheData>(table),
                  BaseReferences<_$AppDatabase, $AiCacheTable, AiCacheData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiCacheTable,
      AiCacheData,
      $$AiCacheTableFilterComposer,
      $$AiCacheTableOrderingComposer,
      $$AiCacheTableAnnotationComposer,
      $$AiCacheTableCreateCompanionBuilder,
      $$AiCacheTableUpdateCompanionBuilder,
      (AiCacheData, BaseReferences<_$AppDatabase, $AiCacheTable, AiCacheData>),
      AiCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$AiCacheTableTableManager get aiCache =>
      $$AiCacheTableTableManager(_db, _db.aiCache);
}
