import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../core/ai_client/ai_client.dart';
import '../../core/db/app_database.dart';

/// Язык подсказок (см. чертёж: украинский или русский).
enum UiLang {
  uk(TranslateLanguage.ukrainian),
  ru(TranslateLanguage.russian),
  pl(TranslateLanguage.polish);

  const UiLang(this.mlKit);
  final TranslateLanguage mlKit;
}

/// Сервис перевода:
/// 1. Приоритетно переводит через облачный ИИ OmniRoute (anti/gemini-3.8-flash-high).
/// 2. Кэширует литературные переводы в SQLite (AiCache) для мгновенного повторного вызова.
/// 3. Резервный офлайн-перевод Google ML Kit (только при отсутствии сети/ключа).
class TranslationService {
  TranslationService({
    required this.aiClient,
    required this.db,
    this.lang = UiLang.uk,
  });

  final AiClient aiClient;
  final AppDatabase db;
  UiLang lang;

  OnDeviceTranslator? _translator;
  UiLang? _translatorLang;
  final _modelManager = OnDeviceTranslatorModelManager();

  String get _targetLangName {
    switch (lang) {
      case UiLang.uk:
        return 'Украинский';
      case UiLang.ru:
        return 'Русский';
      case UiLang.pl:
        return 'Украинский';
    }
  }

  /// Полный связный перевод абзаца/текста через OmniRoute.
  Future<String> translate(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';

    final cacheKey = 'tr_full_${lang.name}_${trimmed.hashCode}_${trimmed.length}';
    final cached = await db.cacheGet(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    if (aiClient.apiKey.trim().isNotEmpty) {
      try {
        final systemPrompt =
            'Ты — профессиональный переводчик с польского на $_targetLangName. '
            'Переведи текст связно, литературно, грамотно и контекстно. '
            'Выведи ТОЛЬКО готовый перевод без вступительных слов и пояснений.';

        final result = await aiClient.chat(
          [
            ChatMessage('system', systemPrompt),
            ChatMessage('user', trimmed),
          ],
          temperature: 0.2,
          timeout: const Duration(seconds: 25),
        );

        final clean = result.trim();
        if (clean.isNotEmpty) {
          await db.cachePut(cacheKey, clean);
          return clean;
        }
      } catch (_) {
        // Fallback на ML Kit при сбое сети
      }
    }

    return _translateMlKit(trimmed);
  }

  /// Перевод отдельного слова в контексте предложения через OmniRoute.
  Future<String> translateWord(String word, {String? sentence}) async {
    final cleanWord = word.trim().replaceAll(
      RegExp(r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$', unicode: true),
      '',
    );
    if (cleanWord.isEmpty) return '';

    final cleanSentence = sentence?.trim() ?? '';
    final cacheKey = 'tr_word_${lang.name}_${cleanWord.toLowerCase()}_${cleanSentence.hashCode}';
    final cached = await db.cacheGet(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    if (aiClient.apiKey.trim().isNotEmpty) {
      try {
        final contextPart = cleanSentence.isNotEmpty
            ? ' с учётом контекста предложения: "$cleanSentence"'
            : '';
        final systemPrompt =
            'Ты — профессиональный переводчик с польского на $_targetLangName. '
            'Переведи польское слово "$cleanWord"$contextPart. '
            'Выведи ТОЛЬКО готовый точный перевод этого слова без кавычек, вступительных слов и пояснений.';

        final result = await aiClient.chat(
          [
            ChatMessage('system', systemPrompt),
            ChatMessage('user', cleanWord),
          ],
          temperature: 0.2,
          timeout: const Duration(seconds: 15),
        );

        String clean = result.trim();
        clean = clean.replaceAll(RegExp(r'^["«]+|["»]+$'), '').trim();
        if (clean.isNotEmpty) {
          await db.cachePut(cacheKey, clean);
          return clean;
        }
      } catch (_) {
        // Fallback на ML Kit
      }
    }

    return _translateMlKit(cleanWord);
  }

  Future<void> _ensureMlKitModels() async {
    for (final l in [TranslateLanguage.polish, lang.mlKit]) {
      if (!await _modelManager.isModelDownloaded(l.bcpCode)) {
        await _modelManager.downloadModel(l.bcpCode);
      }
    }
  }

  Future<String> _translateMlKit(String text) async {
    await _ensureMlKitModels();
    if (_translator == null || _translatorLang != lang) {
      await _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.polish,
        targetLanguage: lang.mlKit,
      );
      _translatorLang = lang;
    }
    return _translator!.translateText(text);
  }

  Future<void> dispose() async => _translator?.close();
}
