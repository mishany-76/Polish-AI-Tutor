import '../scanner/translation_service.dart' show UiLang;

/// Экзаменатор
class ExamExaminer {
  const ExamExaminer({
    required this.name,
    required this.rolePl,
    required this.roleUk,
    required this.roleRu,
    required this.emoji,
    required this.openingPl,
    required this.openingUk,
    required this.openingRu,
  });

  final String name;
  final String rolePl;
  final String roleUk;
  final String roleRu;
  final String emoji;
  final String openingPl;
  final String openingUk;
  final String openingRu;

  String role(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return roleUk;
      case UiLang.ru:
        return roleRu;
      case UiLang.pl:
        return rolePl;
    }
  }

  String opening(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return openingUk;
      case UiLang.ru:
        return openingRu;
      case UiLang.pl:
        return openingPl;
    }
  }
}

/// Стандартные экзаменаторы
const kDefaultExaminers = [
  ExamExaminer(
    name: 'Prof. Ewa Wiśniewska',
    rolePl: 'Przewodnicząca Państwowej Komisji Egzaminacyjnej',
    roleUk: 'Голова Державної екзаменаційної комісії',
    roleRu: 'Председатель Государственной экзаменационной комиссии',
    emoji: '👩‍🏫',
    openingPl:
        'Dzień dobry. Nazywam się prof. Ewa Wiśniewska. Rozpoczynamy egzamin ustny ze znajomości języka polskiego jako obcego. Proszę mówić swobodnie i pełnymi zdaniami. Na początek: proszę krótko przedstawić się, powiedzieć skąd pan/pani pochodzi i jak długo uczy się pan/pani języka polskiego?',
    openingUk:
        'Доброго дня. Мене звуть проф. Ева Вишнєвська. Розпочинаємо усний іспит з польської мови. Будь ласка, говоріть вільно та повними реченнями. Для початку: коротко відрекомендуйтеся, розкажіть звідки ви та як довго вивчаєте польську?',
    openingRu:
        'Добрый день. Меня зовут проф. Эва Вишневская. Начинаем устный экзамен по польскому языку. Пожалуйста, говорите свободно и полными предложениями. Для начала: представьтесь, расскажите откуда вы и как давно учите польский язык?',
  ),
  ExamExaminer(
    name: 'Dr Janusz Kowalczyk',
    rolePl: 'Egzaminator Certyfikatowy B1/B2',
    roleUk: 'Сертифікований екзаменатор B1/B2',
    roleRu: 'Сертифицированный экзаменатор B1/B2',
    emoji: '👨‍🏫',
    openingPl:
        'Dzień dobry państwu. Nazywam się dr Janusz Kowalczyk. Dziś sprawdzimy pana/pani praktyczną biegłość w języku polskim w realistycznych sytuacjach. Proszę opowiedzieć o sobie, swoich zainteresowaniach oraz czym zajmuje się pan/pani w Polsce.',
    openingUk:
        'Доброго дня. Мене звуть д-р Януш Ковальчик. Сьогодні перевіримо вашу практичну вільність у польській мові. Розкажіть про себе, свої інтереси та чим займаєтеся у Польщі.',
    openingRu:
        'Добрый день. Меня зовут д-р Януш Ковальчик. Сегодня проверим вашу практическую беглость в польском языке. Расскажите о себе, своих интересах и чем занимаетесь в Польше.',
  ),
];

/// Результат экзаменационного оценивания (CEFR Assessment)
class ExamAssessmentResult {
  const ExamAssessmentResult({
    required this.id,
    required this.date,
    required this.examinerName,
    required this.overallLevel,
    required this.score,
    required this.passed,
    required this.vocabScore,
    required this.grammarScore,
    required this.fluencyScore,
    required this.interactionScore,
    required this.feedbackPl,
    required this.feedbackTr,
    required this.strongPoints,
    required this.weakPoints,
    required this.recommendations,
  });

  final String id;
  final DateTime date;
  final String examinerName;
  final String overallLevel; // 'A1', 'A2', 'B1', 'B2'
  final int score; // 0 - 100
  final bool passed; // score >= 60
  final int vocabScore; // 0 - 25
  final int grammarScore; // 0 - 25
  final int fluencyScore; // 0 - 25
  final int interactionScore; // 0 - 25
  final String feedbackPl;
  final String feedbackTr;
  final List<String> strongPoints;
  final List<String> weakPoints;
  final List<String> recommendations;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'examinerName': examinerName,
        'overallLevel': overallLevel,
        'score': score,
        'passed': passed,
        'vocabScore': vocabScore,
        'grammarScore': grammarScore,
        'fluencyScore': fluencyScore,
        'interactionScore': interactionScore,
        'feedbackPl': feedbackPl,
        'feedbackTr': feedbackTr,
        'strongPoints': strongPoints,
        'weakPoints': weakPoints,
        'recommendations': recommendations,
      };

  factory ExamAssessmentResult.fromJson(Map<String, dynamic> j) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    final scoreVal = (j['score'] as num?)?.toInt() ?? 70;
    return ExamAssessmentResult(
      id: j['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
      examinerName: j['examinerName']?.toString() ?? 'Prof. Ewa Wiśniewska',
      overallLevel: j['overallLevel']?.toString() ?? 'A2',
      score: scoreVal,
      passed: (j['passed'] as bool?) ?? (scoreVal >= 60),
      vocabScore: (j['vocabScore'] as num?)?.toInt() ?? (scoreVal ~/ 4),
      grammarScore: (j['grammarScore'] as num?)?.toInt() ?? (scoreVal ~/ 4),
      fluencyScore: (j['fluencyScore'] as num?)?.toInt() ?? (scoreVal ~/ 4),
      interactionScore: (j['interactionScore'] as num?)?.toInt() ?? (scoreVal ~/ 4),
      feedbackPl: j['feedbackPl']?.toString() ?? 'Dobra komunikacja w sytuacjach codziennych.',
      feedbackTr: j['feedbackTr']?.toString() ?? 'Хорошая коммуникация в повседневных ситуациях.',
      strongPoints: parseList(j['strongPoints']),
      weakPoints: parseList(j['weakPoints']),
      recommendations: parseList(j['recommendations']),
    );
  }

  /// Эвристическая оценка на случай отсутствия сети / сбоя ИИ
  static ExamAssessmentResult evaluateFallback({
    required List<String> userUtterances,
    required String examinerName,
    required UiLang lang,
  }) {
    final totalWords = userUtterances.fold<int>(
      0,
      (acc, s) => acc + s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
    );
    final count = userUtterances.length;

    String level;
    int score;
    int vocab;
    int grammar;
    int fluency;
    int interaction;

    if (totalWords >= 35 && count >= 3) {
      level = 'B1';
      score = 82;
      vocab = 21;
      grammar = 20;
      fluency = 21;
      interaction = 20;
    } else if (totalWords >= 20 && count >= 2) {
      level = 'A2';
      score = 72;
      vocab = 18;
      grammar = 18;
      fluency = 18;
      interaction = 18;
    } else if (totalWords >= 8) {
      level = 'A1';
      score = 60;
      vocab = 15;
      grammar = 15;
      fluency = 15;
      interaction = 15;
    } else {
      level = 'A0/A1';
      score = 45;
      vocab = 12;
      grammar = 11;
      fluency = 10;
      interaction = 12;
    }

    final isUk = lang == UiLang.uk;
    return ExamAssessmentResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      examinerName: examinerName,
      overallLevel: level,
      score: score,
      passed: score >= 60,
      vocabScore: vocab,
      grammarScore: grammar,
      fluencyScore: fluency,
      interactionScore: interaction,
      feedbackPl: 'Kandydat wykazuje dobrą gotowość komunikacyjną w języku polskim ($level).',
      feedbackTr: isUk
          ? 'Кандидат демонструє хорошу комунікативну готовність польською мовою ($level).'
          : 'Кандидат демонстрирует хорошую коммуникативную готовность на польском языке ($level).',
      strongPoints: isUk
          ? ['Розуміння запитань екзаменатора', 'Використання базових повсякденних конструкцій']
          : ['Понимание вопросов экзаменатора', 'Использование базовых повседневных конструкций'],
      weakPoints: isUk
          ? ['Варто звернути увагу на відмінкові закінчення (Biernik, Miejscownik)']
          : ['Стоит обратить внимание на падежные окончания (Biernik, Miejscownik)'],
      recommendations: isUk
          ? ['Регулярно тренувати тренажер закінчень та живі ролеві діалоги']
          : ['Регулярно тренировать тренажер окончаний и живые ролевые диалоги'],
    );
  }
}

