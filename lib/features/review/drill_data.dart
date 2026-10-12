/// Статические данные тренажёров: окончания, ложные друзья, стартовый словарь.
/// Масштабированная база (1100+ карточек):
/// - 344 «Хибні друзі» (ложные друзья переводчика)
/// - 360 «Закінчення» (практические предложения на падежи)
/// - 435 «Аудіо-тренажер» (лексика, цены, числа, бытовые ситуации)
library;

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
