import '../scanner/translation_service.dart' show UiLang;

/// Элемент фонетической звуковой карты польского алфавита
class LetterItem {
  final String letter;
  final String soundTranscript;
  final String phoneticDescPl;
  final String phoneticDescUk;
  final String phoneticDescRu;
  final String exampleWord;
  final String exampleTrUk;
  final String exampleTrRu;
  final bool isDiacritic;
  final bool isDigraph;

  const LetterItem({
    required this.letter,
    required this.soundTranscript,
    required this.phoneticDescPl,
    required this.phoneticDescUk,
    required this.phoneticDescRu,
    required this.exampleWord,
    required this.exampleTrUk,
    required this.exampleTrRu,
    this.isDiacritic = false,
    this.isDigraph = false,
  });

  String desc(UiLang lang) {
    switch (lang) {
      case UiLang.pl:
        return phoneticDescPl;
      case UiLang.uk:
        return phoneticDescUk;
      case UiLang.ru:
        return phoneticDescRu;
    }
  }

  String exampleTr(UiLang lang) {
    switch (lang) {
      case UiLang.pl:
        return exampleWord;
      case UiLang.uk:
        return exampleTrUk;
      case UiLang.ru:
        return exampleTrRu;
    }
  }
}

/// Число и его словесная форма в польском языке
class NumberItem {
  final int number;
  final String word;
  final String transcript;
  final String ruleNotePl;
  final String ruleNoteUk;
  final String ruleNoteRu;

  const NumberItem({
    required this.number,
    required this.word,
    required this.transcript,
    required this.ruleNotePl,
    required this.ruleNoteUk,
    required this.ruleNoteRu,
  });

  String rule(UiLang lang) {
    switch (lang) {
      case UiLang.pl:
        return ruleNotePl;
      case UiLang.uk:
        return ruleNoteUk;
      case UiLang.ru:
        return ruleNoteRu;
    }
  }
}

/// Категория словаря первоклассника
class PrimerCategory {
  final String id;
  final String icon;
  final String titlePl;
  final String titleUk;
  final String titleRu;

  const PrimerCategory({
    required this.id,
    required this.icon,
    required this.titlePl,
    required this.titleUk,
    required this.titleRu,
  });

  String title(UiLang lang) {
    switch (lang) {
      case UiLang.pl:
        return titlePl;
      case UiLang.uk:
        return titleUk;
      case UiLang.ru:
        return titleRu;
    }
  }
}

/// Слово-кирпичик из базового банка 250 слов
class PrimerBrickItem {
  final String id;
  final String polishWord;
  final String translationUk;
  final String translationRu;
  final String transcript;
  final String categoryId;
  final String examplePl;
  final String exampleUk;
  final String exampleRu;
  final String emoji;

  const PrimerBrickItem({
    required this.id,
    required this.polishWord,
    required this.translationUk,
    required this.translationRu,
    required this.transcript,
    required this.categoryId,
    required this.examplePl,
    required this.exampleUk,
    required this.exampleRu,
    this.emoji = '📌',
  });

  String translation(UiLang lang) {
    switch (lang) {
      case UiLang.pl:
        return polishWord;
      case UiLang.uk:
        return translationUk;
      case UiLang.ru:
        return translationRu;
    }
  }

  String exampleTr(UiLang lang) {
    switch (lang) {
      case UiLang.pl:
        return examplePl;
      case UiLang.uk:
        return exampleUk;
      case UiLang.ru:
        return exampleRu;
    }
  }
}

/// Хелпер для конвертации любого целого числа от 0 до 999 (и 1000) в польские слова
class NumberBuilderHelper {
  static const List<String> units = [
    'zero',
    'jeden',
    'dwa',
    'trzy',
    'cztery',
    'pięć',
    'sześć',
    'siedem',
    'osiem',
    'dziewięć',
    'dziesięć',
    'jedenaście',
    'dwanaście',
    'trzynaście',
    'czternaście',
    'piętnaście',
    'szesnaście',
    'siedemnaście',
    'osiemnaście',
    'dziewiętnaście',
  ];

  static const List<String> tens = [
    '',
    'dziesięć',
    'dwadzieścia',
    'trzydzieści',
    'czterdzieści',
    'pięćdziesiąt',
    'sześćdziesiąt',
    'siedemdziesiąt',
    'osiemdziesiąt',
    'dziewięćdziesiąt',
  ];

  static const List<String> hundreds = [
    '',
    'sto',
    'dwieście',
    'trzysta',
    'czterysta',
    'pięćset',
    'sześćset',
    'siedemset',
    'osiemset',
    'dziewięćset',
  ];

  /// Превращает целое число 0..1000 в польский текст
  static String toPolishWords(int n) {
    if (n < 0) return 'minus ${toPolishWords(-n)}';
    if (n == 0) return 'zero';
    if (n == 1000) return 'tysiąc';
    if (n > 1000) return n.toString(); // выше 1000 пока возвращаем строку

    final parts = <String>[];

    // Сотни
    final h = n ~/ 100;
    if (h > 0) {
      parts.add(hundreds[h]);
    }

    final rem = n % 100;
    if (rem == 0) {
      return parts.join(' ');
    }

    // До 20
    if (rem < 20) {
      parts.add(units[rem]);
    } else {
      final t = rem ~/ 10;
      final u = rem % 10;
      parts.add(tens[t]);
      if (u > 0) {
        parts.add(units[u]);
      }
    }

    return parts.join(' ');
  }
}
