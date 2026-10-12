import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Язык подсказок (см. чертёж: украинский или русский).
enum UiLang {
  uk(TranslateLanguage.ukrainian),
  ru(TranslateLanguage.russian);

  const UiLang(this.mlKit);
  final TranslateLanguage mlKit;
}

/// Офлайн-перевод польского через ML Kit. Модель (~30 МБ) скачивается один раз.
class TranslationService {
  TranslationService({this.lang = UiLang.uk});

  UiLang lang;
  OnDeviceTranslator? _translator;
  UiLang? _translatorLang;
  final _modelManager = OnDeviceTranslatorModelManager();

  Future<void> _ensureModels() async {
    for (final l in [TranslateLanguage.polish, lang.mlKit]) {
      if (!await _modelManager.isModelDownloaded(l.bcpCode)) {
        await _modelManager.downloadModel(l.bcpCode);
      }
    }
  }

  Future<String> translate(String text) async {
    await _ensureModels();
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

