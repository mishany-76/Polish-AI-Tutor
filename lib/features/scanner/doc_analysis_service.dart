import 'dart:convert';

import '../../core/ai_client/ai_client.dart';
import '../../core/db/app_database.dart';
import 'translation_service.dart';

/// Финансовое условие или платеж в документе.
class DocFinancialItem {
  const DocFinancialItem({required this.label, required this.value});

  final String label;
  final String value;

  Map<String, String> toJson() => {'label': label, 'value': value};

  factory DocFinancialItem.fromJson(Map<String, dynamic> j) {
    return DocFinancialItem(
      label: (j['label'] as String? ?? '').trim(),
      value: (j['value'] as String? ?? '').trim(),
    );
  }
}

/// Критическое скрытое условие, риск или штраф.
class DocRiskItem {
  const DocRiskItem({
    required this.title,
    required this.description,
    this.isHighPriority = false,
  });

  final String title;
  final String description;
  final bool isHighPriority;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'is_high_priority': isHighPriority,
      };

  factory DocRiskItem.fromJson(Map<String, dynamic> j) {
    return DocRiskItem(
      title: (j['title'] as String? ?? '').trim(),
      description: (j['description'] as String? ?? '').trim(),
      isHighPriority: j['is_high_priority'] == true || j['high_priority'] == true,
    );
  }
}

/// Конкретное действие, требуемое от пользователя (с дедлайном).
class DocActionItem {
  const DocActionItem({required this.text, this.deadline});

  final String text;
  final String? deadline;

  Map<String, dynamic> toJson() => {'text': text, 'deadline': deadline};

  factory DocActionItem.fromJson(Map<String, dynamic> j) {
    final d = j['deadline'] as String?;
    return DocActionItem(
      text: (j['text'] as String? ?? '').trim(),
      deadline: (d != null && d.trim().isNotEmpty && d.trim() != 'null')
          ? d.trim()
          : null,
    );
  }
}

/// Юридический термин из документа с переводом и пояснением.
class DocVocabItem {
  const DocVocabItem({
    required this.polishTerm,
    required this.translation,
    required this.explanation,
  });

  final String polishTerm;
  final String translation;
  final String explanation;

  Map<String, String> toJson() => {
        'polish_term': polishTerm,
        'translation': translation,
        'explanation': explanation,
      };

  factory DocVocabItem.fromJson(Map<String, dynamic> j) {
    return DocVocabItem(
      polishTerm: (j['polish_term'] as String? ?? j['term'] as String? ?? '').trim(),
      translation: (j['translation'] as String? ?? '').trim(),
      explanation: (j['explanation'] as String? ?? '').trim(),
    );
  }
}

/// Полный структурированный разбор польского официального документа.
class DocAnalysis {
  const DocAnalysis({
    required this.docType,
    this.originalTitle,
    required this.summary,
    required this.financials,
    required this.risks,
    required this.actions,
    required this.vocabulary,
    required this.rawText,
  });

  final String docType;
  final String? originalTitle;
  final String summary;
  final List<DocFinancialItem> financials;
  final List<DocRiskItem> risks;
  final List<DocActionItem> actions;
  final List<DocVocabItem> vocabulary;
  final String rawText;

  factory DocAnalysis.fromJson(Map<String, dynamic> j, String rawText) {
    String? s(dynamic v) {
      final t = v?.toString().trim();
      return (t == null || t.isEmpty || t == 'null') ? null : t;
    }

    final finList = <DocFinancialItem>[];
    if (j['financials'] is List) {
      for (final item in j['financials'] as List) {
        if (item is Map<String, dynamic>) {
          final f = DocFinancialItem.fromJson(item);
          if (f.label.isNotEmpty && f.value.isNotEmpty) finList.add(f);
        }
      }
    }

    final riskList = <DocRiskItem>[];
    if (j['risks'] is List) {
      for (final item in j['risks'] as List) {
        if (item is Map<String, dynamic>) {
          final r = DocRiskItem.fromJson(item);
          if (r.title.isNotEmpty || r.description.isNotEmpty) riskList.add(r);
        }
      }
    }

    final actionList = <DocActionItem>[];
    if (j['actions'] is List) {
      for (final item in j['actions'] as List) {
        if (item is Map<String, dynamic>) {
          final a = DocActionItem.fromJson(item);
          if (a.text.isNotEmpty) actionList.add(a);
        }
      }
    }

    final vocabList = <DocVocabItem>[];
    if (j['vocabulary'] is List) {
      for (final item in j['vocabulary'] as List) {
        if (item is Map<String, dynamic>) {
          final v = DocVocabItem.fromJson(item);
          if (v.polishTerm.isNotEmpty && v.translation.isNotEmpty) {
            vocabList.add(v);
          }
        }
      }
    }

    return DocAnalysis(
      docType: s(j['doc_type']) ?? 'Польский документ',
      originalTitle: s(j['original_title']),
      summary: s(j['summary']) ?? 'Анализ документа выполнен.',
      financials: finList,
      risks: riskList,
      actions: actionList,
      vocabulary: vocabList,
      rawText: rawText,
    );
  }

  Map<String, dynamic> toJson() => {
        'doc_type': docType,
        'original_title': originalTitle,
        'summary': summary,
        'financials': [for (final f in financials) f.toJson()],
        'risks': [for (final r in risks) r.toJson()],
        'actions': [for (final a in actions) a.toJson()],
        'vocabulary': [for (final v in vocabulary) v.toJson()],
      };
}

/// Сервис умного разбора польских документов через OmniRoute.
class DocAnalysisService {
  DocAnalysisService(this._ai, this._db);

  final AiClient _ai;
  final AppDatabase _db;

  Future<DocAnalysis> analyze({
    required String text,
    required UiLang lang,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw AiException('Текст документа пуст.');
    }

    // Кэш в SQLite по хэшу текста и языку
    final cacheKey =
        'doc_analysis|${_ai.model}|${lang.name}|${trimmed.hashCode}_${trimmed.length}';
    final cached = await _db.cacheGet(cacheKey);
    if (cached != null) {
      final obj = extractJson(cached);
      if (obj != null) {
        return DocAnalysis.fromJson(obj, trimmed);
      }
    }

    final targetLang = lang == UiLang.uk
        ? 'украинском'
        : (lang == UiLang.pl ? 'польском' : 'русском');

    final system = '''
Ты — ведущий польский эксперт-юрист и консультант для иностранцев в Польше.
Тебе предоставлен текст официального документа на польском языке (Umowa o pracę, Umowa zlecenie, Umowa najmu lokalu, pismo z Urzędu Skarbowego, decyzja ZUS, mandat, wezwanie do zapłaty и т.д.), полученный через OCR-распознавание.

Твоя задача — провести детальный юридическо-практический разбор документа и объяснить его суть простыми словами на $targetLang языке.

Отвечай СТРОГО одним валидным JSON-объектом без лишних слов, без вступительного текста и без markdown-разметки по следующей схеме:
{
  "doc_type": "Тип документа на польском + перевод на $targetLang язык (напр.: Umowa najmu lokalu mieszkalnego (Договор аренды жилья))",
  "original_title": "Заголовок или стороны документа из текста (или null)",
  "summary": "Главная суть документа простыми и понятными словами в 2-4 предложениях: о чем этот документ, кто стороны, ключевые договоренности.",
  "financials": [
    {"label": "Название платежа или условия", "value": "Сумма, срок или условие (напр.: 4 300 PLN brutto, оплата до 10 числа каждого месяца, кауция 3 000 PLN)"}
  ],
  "risks": [
    {
      "title": "Суть риска, скрытого условия или штрафа",
      "description": "Понятное объяснение (напр.: Срок предупреждения о расторжении договора составляет 3 месяца; при досрочном съезде залог не возвращается)",
      "is_high_priority": true
    }
  ],
  "actions": [
    {"text": "Конкретное действие, которое нужно предпринять", "deadline": "Срок/дата (напр.: до 25.10.2026, в течение 14 дней) или null"}
  ],
  "vocabulary": [
    {"polish_term": "Официальный термин на польском", "translation": "Перевод на $targetLang", "explanation": "Краткое практическое значение"}
  ]
}

Важные правила:
1. Пиши понятно, без заумного канцелярита — представь, что объясняешь другу, который не знает польских законов.
2. В risks выделяй is_high_priority = true для опасных пунктов (штрафы, потеря залога, автоматическая пролонгация, отказ в выплате).
3. В vocabulary отбери от 3 до 5 ключевых терминов из текста (напр.: okres wypowiedzenia, kaucja, kary umowne, organ odwoławczy).
4. Если текст не является договором или письмом госорганов (напр., меню или чек), аккуратно опиши его суть в summary, а остальные списки заполни по смыслу или оставь пустыми.
''';

    final sample = trimmed.length > 5000 ? trimmed.substring(0, 5000) : trimmed;

    final obj = await _ai.chatJson(
      [
        ChatMessage('system', system),
        ChatMessage('user', 'Текст документа:\n$sample'),
      ],
      temperature: 0.2,
    );

    final analysis = DocAnalysis.fromJson(obj, trimmed);

    // Сохраняем в кэш
    await _db.cachePut(cacheKey, jsonEncode(analysis.toJson()));
    return analysis;
  }
}

