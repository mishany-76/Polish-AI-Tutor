import '../scanner/translation_service.dart';

/// Модель задания режима «Диктант» (Active Recall Speller).
class DictationItem {
  const DictationItem({
    required this.id,
    required this.word,
    required this.category,
    required this.translationUk,
    required this.translationRu,
    required this.translationPl,
    required this.ruleUk,
    required this.ruleRu,
    required this.rulePl,
    this.examplePl,
  });

  final String id;

  /// Правильное польское слово, которое диктуется голосом TTS.
  final String word;

  /// Категория орфографической сложности: 'rz_z' | 'u_o' | 'ch_h' | 'nasal' | 'soft' | 'deck'
  final String category;

  final String translationUk;
  final String translationRu;
  final String translationPl;

  /// Мнемоническое правило орфографии (почему пишется именно так).
  final String ruleUk;
  final String ruleRu;
  final String rulePl;

  /// Пример в предложении.
  final String? examplePl;

  String translation(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return translationUk;
      case UiLang.ru:
        return translationRu;
      case UiLang.pl:
        return translationPl.isNotEmpty ? translationPl : word;
    }
  }

  String rule(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return ruleUk;
      case UiLang.ru:
        return ruleRu;
      case UiLang.pl:
        return rulePl;
    }
  }

  factory DictationItem.fromJson(Map<String, dynamic> json) {
    return DictationItem(
      id: json['id'] as String? ?? 'dict_${json['word']}',
      word: (json['word'] as String? ?? '').trim(),
      category: json['category'] as String? ?? 'general',
      translationUk: json['translationUk'] as String? ?? '',
      translationRu: json['translationRu'] as String? ?? '',
      translationPl: json['translationPl'] as String? ?? '',
      ruleUk: json['ruleUk'] as String? ?? '',
      ruleRu: json['ruleRu'] as String? ?? '',
      rulePl: json['rulePl'] as String? ?? '',
      examplePl: json['examplePl'] as String?,
    );
  }
}

