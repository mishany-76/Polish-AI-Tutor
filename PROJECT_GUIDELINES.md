# PROJECT_GUIDELINES — Polish AI Tutor

## Роль проекта
**Polish AI Interactive Tutor** — Android-приложение (Flutter/Dart) для украино- и русскоязычных в Польше: Vision-сканер надписей (ML Kit OCR), голосовой ролевой тренажёр (Gemini Live), карточки с интервальным повторением (FSRS).

## Связь с базой знаний (Second Brain)
- Корень базы: `C:\Users\1\Obsidian Sync\`
- Генеральный чертёж: `C:\Users\1\Obsidian Sync\06_Mobile_Apps\Polish_AI_App\Polish_Language_App_Master_Blueprint.md`
- Перед архитектурными решениями сверяться с чертежом; при расхождении — обновлять чертёж осознанно, по запросу пользователя.
- Связанные заметки: Gemini_API_Guide, Gemini_Search_Grounding, AGENT_RULES, MOC_Index.

## Стандарты архитектуры (из чертежа)
- Flutter + Riverpod; feature-first: `lib/core`, `lib/features/{dashboard,scanner,tutor,review,dictionary,auth_sync}`, `lib/data`.
- БД: SQLite через `drift` (offline-first, версионированные миграции); повторение: FSRS (запасной SM-2).
- ИИ: Firebase AI Logic + App Check; **API-ключ никогда не в APK** (запасной режим BYOK + `flutter_secure_storage`).
- On-device: `google_mlkit_text_recognition`, `google_mlkit_translation`; облачный Gemini — только по тапу («Разобрать») и в голосовом тренажёре.
- Деградация: онлайн → лимит исчерпан → офлайн (ядро работает всегда).
- Приватность: согласие перед отправкой сканов в облако, маскирование цифр >8 знаков.
- Android: `minSdkVersion 24`, разрешения INTERNET/CAMERA/RECORD_AUDIO, не `com.example`.
- Keystore и `key.properties` не коммитить.

## Скиллы
Каталог: `C:\Users\1\Obsidian Sync\00_System\Skills\` (реестр: `SKILLS_REGISTRY_CATALOG.md`).
- `Brainstorming_First_Principles` — для новых фич, продуктовых и архитектурных решений.
- `Prom_Article_SEO_Copywriter` — для текстов (описание в Play Market, лендинг, статьи).

## Запрет на мусор в Obsidian
Obsidian хранит **только знания** (markdown). Весь код и артефакты сборки (`.dart`, `.gradle`, `build/`, `.dart_tool/`, `.apk`, keystore) живут **строго** в `C:\Users\1\Development\PolishApp`. В Obsidian ничего из этого не писать.


## ����������: ��-���� ������ Firebase AI
- �� �������� ����� OpenAI-compatible ���� (OmniRoute/CLIProxyAPI): `{baseUrl}/chat/completions`. Base URL, ������ � ���� � SharedPreferences, API-���� � flutter_secure_storage. ���� ������� �� ��������� � �� ������� � ���.
- Firebase AI Logic / App Check / flutter_soloud ������� �� ������������.
- �����: flutter_tts (������� pl-PL) + speech_to_text (����� ������������).
- ������� ����� � Learn Dashboard; ���������: �������� � ������ � ������� � ���������.
- ����� ��������� ����� drift: `dart run build_runner build`.
