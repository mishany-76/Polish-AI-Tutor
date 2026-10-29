import '../scanner/translation_service.dart' show UiLang;
import '../tutor/scenarios.dart';

/// Отдельный профессиональный термин с переводом и примером употребления.
class ProfessionVocab {
  const ProfessionVocab({
    required this.termPl,
    required this.translationUk,
    required this.translationRu,
    required this.examplePl,
    required this.exampleUk,
    required this.exampleRu,
  });

  final String termPl;
  final String translationUk;
  final String translationRu;
  final String examplePl;
  final String exampleUk;
  final String exampleRu;

  String translation(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return translationUk;
      case UiLang.pl:
        return termPl;
      case UiLang.ru:
        return translationRu;
    }
  }

  String example(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return exampleUk;
      case UiLang.pl:
        return examplePl;
      case UiLang.ru:
        return exampleRu;
    }
  }
}

/// Направление/профессия с набором терминов и ролевым сценарием.
class ProfessionItem {
  const ProfessionItem({
    required this.id,
    required this.emoji,
    required this.titlePl,
    required this.titleUk,
    required this.titleRu,
    required this.descPl,
    required this.descUk,
    required this.descRu,
    required this.vocabulary,
    required this.scenario,
  });

  final String id;
  final String emoji;
  final String titlePl;
  final String titleUk;
  final String titleRu;
  final String descPl;
  final String descUk;
  final String descRu;
  final List<ProfessionVocab> vocabulary;
  final Scenario scenario;

  String title(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return titleUk;
      case UiLang.pl:
        return titlePl;
      case UiLang.ru:
        return titleRu;
    }
  }

  String desc(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return descUk;
      case UiLang.pl:
        return descPl;
      case UiLang.ru:
        return descRu;
    }
  }
}

