import '../scanner/translation_service.dart' show UiLang;
import '../tutor/scenarios.dart';

/// Элемент словаря выживания в серии
class EpisodeVocab {
  const EpisodeVocab({
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
      case UiLang.ru:
        return translationRu;
      case UiLang.pl:
        return termPl;
    }
  }

  String example(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return exampleUk;
      case UiLang.ru:
        return exampleRu;
      case UiLang.pl:
        return examplePl;
    }
  }
}

/// Вариант ответа/решения в интерактивной симуляции сцены
class SceneDecisionOption {
  const SceneDecisionOption({
    required this.textPl,
    required this.textUk,
    required this.textRu,
    required this.isOptimal,
    required this.feedbackPl,
    required this.feedbackUk,
    required this.feedbackRu,
  });

  final String textPl;
  final String textUk;
  final String textRu;
  final bool isOptimal;
  final String feedbackPl;
  final String feedbackUk;
  final String feedbackRu;

  String text(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return textUk;
      case UiLang.ru:
        return textRu;
      case UiLang.pl:
        return textPl;
    }
  }

  String feedback(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return feedbackUk;
      case UiLang.ru:
        return feedbackRu;
      case UiLang.pl:
        return feedbackPl;
    }
  }
}

/// Отдельная сюжетная сцена серии
class EpisodeScene {
  const EpisodeScene({
    required this.id,
    required this.sceneNumber,
    required this.titlePl,
    required this.titleUk,
    required this.titleRu,
    required this.descPl,
    required this.descUk,
    required this.descRu,
    required this.npcName,
    required this.npcRole,
    required this.subScenario,
    this.decisionOptions = const [],
  });

  final String id;
  final int sceneNumber;
  final String titlePl;
  final String titleUk;
  final String titleRu;
  final String descPl;
  final String descUk;
  final String descRu;
  final String npcName;
  final String npcRole;
  final SubScenario subScenario;
  final List<SceneDecisionOption> decisionOptions;

  String title(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return titleUk;
      case UiLang.ru:
        return titleRu;
      case UiLang.pl:
        return titlePl;
    }
  }

  String desc(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return descUk;
      case UiLang.ru:
        return descRu;
      case UiLang.pl:
        return descPl;
    }
  }
}

/// Модель серии интерактивного сериала «Жизнь в Польше»
class EpisodeItem {
  const EpisodeItem({
    required this.id,
    required this.number,
    required this.emoji,
    required this.titlePl,
    required this.titleUk,
    required this.titleRu,
    required this.taglinePl,
    required this.taglineUk,
    required this.taglineRu,
    required this.synopsisPl,
    required this.synopsisUk,
    required this.synopsisRu,
    required this.duration,
    required this.level,
    required this.vocabulary,
    required this.scenes,
  });

  final String id;
  final int number;
  final String emoji;
  final String titlePl;
  final String titleUk;
  final String titleRu;
  final String taglinePl;
  final String taglineUk;
  final String taglineRu;
  final String synopsisPl;
  final String synopsisUk;
  final String synopsisRu;
  final String duration;
  final String level;
  final List<EpisodeVocab> vocabulary;
  final List<EpisodeScene> scenes;

  String title(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return titleUk;
      case UiLang.ru:
        return titleRu;
      case UiLang.pl:
        return titlePl;
    }
  }

  String tagline(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return taglineUk;
      case UiLang.ru:
        return taglineRu;
      case UiLang.pl:
        return taglinePl;
    }
  }

  String synopsis(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return synopsisUk;
      case UiLang.ru:
        return synopsisRu;
      case UiLang.pl:
        return synopsisPl;
    }
  }

  /// Преобразует эпизод в Scenario для передачи в RoleplayScreen
  Scenario toScenario() {
    return Scenario(
      key: 'ep_$id',
      emoji: emoji,
      titleUk: titleUk,
      titleRu: titleRu,
      titlePl: titlePl,
      level: level,
      npcRole: scenes.isNotEmpty ? scenes.first.npcRole : 'Obywatel Polski',
      setting: synopsisPl,
      vocab: vocabulary.map((v) => v.termPl).toList(),
      subScenarios: scenes.map((s) => s.subScenario).toList(),
    );
  }
}
