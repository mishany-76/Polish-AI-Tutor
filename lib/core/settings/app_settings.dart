import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/scanner/translation_service.dart';

const defaultBaseUrl = 'https://omniroute.citystyleshop.online/v1';
const defaultModel = 'anti/gemini-3.8-flash-high';
const suggestedModels = [
  'anti/gemini-3.8-flash-high',
  'anti/gemini-pro-agent',
  'anti/gemini-3.7-flash-high',
  'anti/claude-sonnet-4-6',
  'anti/claude-sonnet-5-5-high',
];

class AppSettings {
  const AppSettings({
    this.lang = UiLang.uk,
    this.baseUrl = defaultBaseUrl,
    this.apiKey = '',
    this.model = defaultModel,
  });

  final UiLang lang;
  final String baseUrl;
  final String apiKey;
  final String model;

  bool get isUk => lang == UiLang.uk;
  bool get isRu => lang == UiLang.ru;
  bool get isPl => lang == UiLang.pl;
  bool get hasKey => apiKey.trim().isNotEmpty;

  AppSettings copyWith({
    UiLang? lang,
    String? baseUrl,
    String? apiKey,
    String? model,
  }) =>
      AppSettings(
        lang: lang ?? this.lang,
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
      );
}

/// Хранение: base URL / модель / язык — SharedPreferences,
/// API-ключ — защищённое хранилище (Android Keystore).
class SettingsStore {
  SettingsStore(this._prefs, [FlutterSecureStorage? secure])
      : _secure = secure ?? const FlutterSecureStorage();

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  static const _kLang = 'ui_lang';
  static const _kUrl = 'ai_base_url';
  static const _kModel = 'ai_model';
  static const _kKey = 'ai_api_key';

  Future<AppSettings> load() async {
    String key = '';
    try {
      key = await _secure.read(key: _kKey) ?? '';
    } catch (_) {
      // Повреждённое хранилище — ключ придётся ввести заново.
    }
    final rawLang = _prefs.getString(_kLang);
    final uiLang = UiLang.values.firstWhere(
      (l) => l.name == rawLang,
      orElse: () => UiLang.uk,
    );
    return AppSettings(
      lang: uiLang,
      baseUrl: _prefs.getString(_kUrl) ?? defaultBaseUrl,
      model: _prefs.getString(_kModel) ?? defaultModel,
      apiKey: key,
    );
  }

  Future<void> save(AppSettings s) async {
    await _prefs.setString(_kLang, s.lang.name);
    await _prefs.setString(_kUrl, s.baseUrl);
    await _prefs.setString(_kModel, s.model);
    await _secure.write(key: _kKey, value: s.apiKey);
  }
}

final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => throw UnimplementedError('Переопределяется в main()'),
);

final initialSettingsProvider = Provider<AppSettings>(
  (ref) => throw UnimplementedError('Переопределяется в main()'),
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialSettingsProvider);

  Future<void> update(AppSettings s) async {
    state = s;
    await ref.read(settingsStoreProvider).save(s);
  }

  Future<void> setLang(UiLang lang) => update(state.copyWith(lang: lang));
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

