import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/app_settings.dart';
import '../../features/scanner/translation_service.dart';

/// Централизованная система локализации интерфейса на 3 языка:
/// uk: Українська (за замовчуванням)
/// ru: Русский
/// pl: Polski (językowe zanurzenie)
class AppStrings {
  final UiLang lang;
  const AppStrings(this.lang);

  bool get isUk => lang == UiLang.uk;
  bool get isRu => lang == UiLang.ru;
  bool get isPl => lang == UiLang.pl;

  // --- Навигация ---
  String get tabLearn => isPl ? 'Nauka' : (isUk ? 'Навчання' : 'Обучение');
  String get tabTranslator => isPl ? 'Tłumacz' : (isUk ? 'Перекладач' : 'Переводчик');
  String get tabDictionary => isPl ? 'Słownik' : (isUk ? 'Словник' : 'Словарь');
  String get tabSettings => isPl ? 'Ustawienia' : (isUk ? 'Налаштування' : 'Настройки');

  // --- Главный экран (LearnDashboard) ---
  String streakDays(int n) {
    if (isPl) {
      if (n == 1) return 'dzień';
      return 'dni';
    }
    if (isUk) {
      if (n % 10 == 1 && n % 100 != 11) return 'день';
      if ([2, 3, 4].contains(n % 10) && ![12, 13, 14].contains(n % 100)) return 'дні';
      return 'днів';
    }
    if (n % 10 == 1 && n % 100 != 11) return 'день';
    if ([2, 3, 4].contains(n % 10) && ![12, 13, 14].contains(n % 100)) return 'дня';
    return 'дней';
  }

  String get dueWordsToday => isPl
      ? 'Słowa do powtórzenia dzisiaj'
      : (isUk ? 'Слів на повторення сьогодні' : 'Слов на повторение сегодня');

  String totalInDeck(int total) => isPl
      ? 'Razem w talii: $total'
      : (isUk ? 'Всього в колоді: $total' : 'Всего в колоде: $total');

  String get startReview => isPl
      ? 'Rozpocznij powtórkę'
      : (isUk ? 'Почати повторення' : 'Начать повторение');

  String get allDoneToday => isPl
      ? 'Na dzisiaj to wszystko 🎉'
      : (isUk ? 'На сьогодні все 🎉' : 'На сегодня всё 🎉');

  String get scanWords => isPl
      ? 'Skanuj słowa'
      : (isUk ? 'Сканувати слова' : 'Сканировать слова');

  String get manualWordBtn => isPl
      ? '✍️ Dodaj słowo ręcznie'
      : (isUk ? '✍️ Ввести слово вручну' : '✍️ Ввести слово вручную');

  String get clearQueueBtn => isPl
      ? '⏰ Wyczyść kolejkę na dziś'
      : (isUk ? '⏰ Очистити чергу на сьогодні' : '⏰ Очистить очередь на сегодня');

  String queueDeferredSnack(int count) => isPl
      ? '⏰ Kolejka powtórek na dziś wyczyszczona (odłożono na jutro: $count)'
      : (isUk
          ? '⏰ Чергу повторень на сьогодні очищено (відкладено на завтра: $count)'
          : '⏰ Очередь повторений на сегодня очищена (отложено на завтра: $count)');

  String get drillsTitle => isPl
      ? 'Trening i quizy'
      : (isUk ? 'Тренажери та вікторини' : 'Тренажеры и викторины');

  String get drillEndingsTitle =>
      isPl ? 'Trener końcówek' : (isUk ? 'Тренажер закінчень' : 'Тренажёр окончаний');
  String get drillEndingsSub => isPl
      ? 'Odmiana i formy słów w kontekście'
      : (isUk ? 'Відмінки та форми слів у контексті' : 'Падежи и формы слов в контексте');

  String get drillFalseFriendsTitle =>
      isPl ? 'Fałszywi przyjaciele' : (isUk ? 'Хибні друзі' : 'Ложные друзья');
  String get drillFalseFriendsSub => isPl
      ? 'Słowa-pułapki i mylące znaczenia'
      : (isUk ? 'Слова-пастки та обманки' : 'Слова-ловушки и обманки');

  String get drillNumbersTitle =>
      isPl ? 'Liczby, ceny i rachunki' : (isUk ? 'Числа, ціни та рахунок' : 'Числа, цены и счёт');
  String get drillNumbersSub => isPl
      ? 'Kasy, paragony, BLIK i godziny'
      : (isUk ? 'Каси, чеки, BLIK та години' : 'Кассы, чеки, BLIK и время');

  String get drillAudioTitle =>
      isPl ? 'Trener słuchowy' : (isUk ? 'Аудіо-тренажер' : 'Аудио-тренажёр');
  String get drillAudioSub => isPl
      ? 'Rozumienie polskiego ze słuchu'
      : (isUk ? 'Сприйняття польської мови на слух' : 'Восприятие польской речи на слух');

  String get drillDictationTitle =>
      isPl ? 'Dyktando i pisownia' : (isUk ? 'Режим «Диктант»' : 'Режим «Диктант»');
  String get drillDictationSub => isPl
      ? 'Pisanie ze słuchu i pułapki (rz/ż, ch/h, ó/u)'
      : (isUk ? 'Письмо на слух та пастки (rz/ż, ch/h, ó/u)' : 'Письмо на слух и ловушки (rz/ż, ch/h, ó/u)');

  String get roleplayTitle =>
      isPl ? 'Dialogi sytuacyjne' : (isUk ? 'Рольові діалоги' : 'Ролевые диалоги');
  String get readyToChat => isPl ? 'Gotowy' : (isUk ? 'Готовий' : 'Готов');
  String get guideTooltip => isPl ? 'Instrukcja' : (isUk ? 'Інструкція' : 'Инструкция');
  String get chooseSubSituation => isPl
      ? 'Wybierz sytuację życiową:'
      : (isUk ? 'Оберіть життєву ситуацію:' : 'Выберите жизненную ситуацию:');
  String get whoSpeaksFirst => isPl
      ? 'Kto mówi pierwszy:'
      : (isUk ? 'Хто говорить першим:' : 'Кто говорит первым:');
  String get initiatorUserFirst => isPl
      ? '🗣️ Zaczynam ja'
      : (isUk ? '🗣️ Я перший' : '🗣️ Я первый');
  String get initiatorNpcFirst => isPl
      ? '👂 Rozmówca'
      : (isUk ? '👂 Співрозмовник' : '👂 Собеседник');
  String get dialogueDifficulty => isPl
      ? 'Poziom trudności i styl:'
      : (isUk ? 'Рівень складності та стиль:' : 'Сложность и стиль диалога:');
  String get difficultyCalm => isPl
      ? '🟢 Spokojny'
      : (isUk ? '🟢 Спокійний' : '🟢 Спокойный');
  String get difficultyCalmSub => isPl
      ? 'A1–A2 · Prosty i łagodny'
      : (isUk ? 'A1–A2 · Простий і терплячий' : 'A1–A2 · Простой и терпеливый');
  String get difficultyLife => isPl
      ? '🟡 Życiowy'
      : (isUk ? '🟡 Життєвий' : '🟡 Жизненный');
  String get difficultyLifeSub => isPl
      ? 'A2–B1 · Codzienne zgrzyty'
      : (isUk ? 'A2–B1 · Живі нюанси' : 'A2–B1 · Живые нюансы');
  String get difficultyChallenge => isPl
      ? '🔴 Wyzwanie'
      : (isUk ? '🔴 Виклик' : '🔴 Вызов (Стресс)');
  String get difficultyChallengeSub => isPl
      ? 'B1–B2 · Presja i spór'
      : (isUk ? 'B1–B2 · Суперечка і тиск' : 'B1–B2 · Претензия и спор');
  String get difficultyRandom => isPl
      ? '🎲 Losowy'
      : (isUk ? '🎲 Випадковий' : '🎲 Случайный');
  String get difficultyRandomSub => isPl
      ? 'Niespodzianka'
      : (isUk ? 'Сюрприз щоразу' : 'Сюрприз каждый раз');
  String get startDialogBtn => isPl
      ? 'Rozpocznij dialog 🚀'
      : (isUk ? 'Розпочати діалог 🚀' : 'Начать диалог 🚀');

  // --- Диалог ручного ввода (Smart Manual Word Dialog) ---
  String get newWordTitle => isPl ? '✍️ Nowe słowo' : (isUk ? '✍️ Нове слово' : '✍️ Новое слово');
  String get plWordLabel => isPl ? 'Polskie słowo *' : (isUk ? 'Польське слово *' : 'Польское слово *');
  String get plWordHint => isPl ? 'np. dworzec' : (isUk ? 'наприклад, dworzec' : 'например, dworzec');
  String get autoTranslateTooltip => isPl
      ? 'Automatyczne tłumaczenie AI'
      : (isUk ? 'Автопереклад через ШІ' : 'Автоперевод через ИИ');
  String get translatingAi => isPl
      ? 'Tłumaczę przez AI…'
      : (isUk ? 'Перекладаю через ШІ…' : 'Перевожу через ИИ…');
  String get translationLabel => isPl ? 'Tłumaczenie *' : (isUk ? 'Переклад *' : 'Перевод *');
  String get translationHint => isPl ? 'np. stacja kolejowa' : (isUk ? 'наприклад, вокзал' : 'например, вокзал');
  String get contextLabel => isPl
      ? 'Kontekst / notatka (opcjonalnie)'
      : (isUk ? 'Контекст / примітка (опціонально)' : 'Контекст / заметка (опционально)');
  String get contextHint => isPl
      ? 'np. Idę na dworzec kolejowy'
      : (isUk ? 'наприклад, Idę na dworzec kolejowy' : 'например, Idę na dworzec kolejowy');
  String get cancel => isPl ? 'Anuluj' : (isUk ? 'Скасувати' : 'Отмена');
  String get save => isPl ? 'Zapisz' : (isUk ? 'Зберегти' : 'Сохранить');
  String wordAdded(String w) => isPl
      ? '✅ Słowo "$w" dodane do talii'
      : (isUk ? '✅ Слово "$w" додано до колоди' : '✅ Слово "$w" добавлено в колоду');
  String wordAutoTranslated(String w, String tr) => isPl
      ? '✅ Słowo "$w" ($tr) przetłumaczone i dodane do słownika'
      : (isUk
          ? '✅ Слово "$w" ($tr) перекладено та додано до словника'
          : '✅ Слово "$w" ($tr) успешно переведено и добавлено в словарь');
  String wordAlreadyExists(String w) => isPl
      ? '⚠️ Słowo "$w" już jest w słowniku'
      : (isUk ? '⚠️ Слово "$w" вже є у словнику' : '⚠️ Слово "$w" уже есть в словаре');

  // --- Словарь ---
  String get dictTitle => isPl ? '📖 Mój słownik' : (isUk ? '📖 Мій словник' : '📖 Мой словарь');
  String get clearDictTooltip => isPl ? 'Wyczyść słownik' : (isUk ? 'Очистити словник' : 'Очистить словарь');
  String get searchWordHint => isPl
      ? 'Szukaj słowa lub tłumaczenia…'
      : (isUk ? 'Пошук за словом або перекладом…' : 'Поиск по слову или переводу…');
  String get filterAll => isPl ? 'Wszystkie' : (isUk ? 'Всі' : 'Все');
  String get filterFresh => isPl ? 'Nowe' : (isUk ? 'Нові' : 'Новые');
  String get filterLearning => isPl ? 'W trakcie' : (isUk ? 'Вчу' : 'Учу');
  String get filterMastered => isPl ? 'Opanowane' : (isUk ? 'Вивчені' : 'Выучены');
  String get clearDictConfirmTitle => isPl
      ? 'Wyczyścić słownik?'
      : (isUk ? 'Очистити словник?' : 'Очистить словарь?');
  String get clearDictConfirmBody => isPl
      ? 'Czy na pewno chcesz usunąć wszystkie zapisane słowa? Zresetuje to postęp powtórek.'
      : (isUk
          ? 'Ви впевнені, що хочете видалити всі збережені слова? Це скине прогрес повторень.'
          : 'Вы уверены, что хотите удалить все сохраненные слова? Это сбросит прогресс повторений.');
  String get clearBtn => isPl ? 'Wyczyść' : (isUk ? 'Очистити' : 'Очистить');
  String dictClearedSnack(int c) => isPl
      ? '🗑️ Słownik wyczyszczony (usunięto słów: $c)'
      : (isUk ? '🗑️ Словник очищено (видалено слів: $c)' : '🗑️ Словарь очищен (удалено слов: $c)');

  // Экспорт колод (Anki / Quizlet / CSV)
  String get exportDeckTooltip => isPl
      ? 'Eksportuj słowa (Anki / Quizlet)'
      : (isUk ? 'Експортувати слова (Anki / Quizlet)' : 'Экспортировать слова (Anki / Quizlet)');
  String get exportDialogTitle => isPl
      ? '📤 Eksport do Anki / Quizlet'
      : (isUk ? '📤 Експорт в Anki / Quizlet' : '📤 Экспорт в Anki / Quizlet');
  String get exportDialogSub => isPl
      ? 'Wybierz wygodny format do powtórek w zewnętrznych aplikacjach:'
      : (isUk
          ? 'Оберіть зручний формат для повторення у зовнішніх додатках:'
          : 'Выберите удобный формат для повторения во внешних приложениях:');
  String get exportAnkiTitle => 'Anki Deck (.txt / TSV)';
  String get exportAnkiDesc => isPl
      ? 'Gotowy do importu w Anki / AnkiDroid z tagami, częściami mowy, przykładami zdań i interwałami SM-2.'
      : (isUk
          ? 'Готовий для імпорту в Anki / AnkiDroid з тегами, частинами мови, прикладами речень та інтервалами SM-2.'
          : 'Готов для импорта в Anki / AnkiDroid с тегами, частями речи, примерами предложений и интервалами SM-2.');
  String get exportQuizletTitle => 'Quizlet (.csv)';
  String get exportQuizletDesc => isPl
      ? 'Szybki import terminu i definicji w Quizlet dla nauki na fiszkach.'
      : (isUk
          ? 'Швидкий імпорт терміну та визначення в Quizlet для навчання на картках.'
          : 'Быстрый импорт термина и определения в Quizlet для обучения по карточкам.');
  String get exportCsvTitle => 'Excel / CSV (.csv)';
  String get exportCsvDesc => isPl
      ? 'Pełna tabela z kolumnami dla arkuszy kalkulacyjnych Excel i Google Sheets (kodowanie UTF-8 BOM).'
      : (isUk
          ? 'Повна таблиця зі стовпцями для електронних таблиць Excel та Google Sheets (кодування UTF-8 BOM).'
          : 'Полная таблица со столбцами для электронных таблиц Excel и Google Sheets (кодировка UTF-8 BOM).');
  String get exportEmptyDictAlert => isPl
      ? 'Słownik jest pusty. Dodaj słowa przed eksportem!'
      : (isUk ? 'Словник порожній. Додайте слова перед експортом!' : 'Словарь пуст. Добавьте слова перед экспортом!');
  String exportSuccessSnack(int count, String format) => isPl
      ? '📤 Wyeksportowano $count słów ($format)'
      : (isUk ? '📤 Експортовано $count слів ($format)' : '📤 Экспортировано $count слов ($format)');

  // --- Настройки ---
  String get settingsTitle => isPl ? '⚙️ Ustawienia' : (isUk ? '⚙️ Налаштування' : '⚙️ Настройки');
  String get uiLangTitle => isPl ? 'Język interfejsu' : (isUk ? 'Мова інтерфейсу' : 'Язык интерфейса');
  String get aiGatewayTitle => isPl
      ? 'Bramka AI (OpenAI-compatible)'
      : (isUk ? 'Шлюз ШІ (OpenAI-compatible)' : 'ИИ-Шлюз (OpenAI-compatible)');
  String get aiGatewaySub => isPl
      ? 'OmniRoute / CLIProxyAPI. Zapytania do {Base URL}/chat/completions.'
      : (isUk
          ? 'OmniRoute / CLIProxyAPI. Запити йдуть на {Base URL}/chat/completions.'
          : 'OmniRoute / CLIProxyAPI. Запросы идут на {Base URL}/chat/completions.');
  String get saveSettings => isPl ? 'Zapisz' : (isUk ? 'Зберегти' : 'Сохранить');
  String get settingsSaved => isPl ? '✅ Ustawienia zapisane' : (isUk ? '✅ Налаштування збережено' : '✅ Настройки сохранены');
  String get testConnection => isPl ? 'Testuj połączenie' : (isUk ? 'Перевірити' : 'Проверить');
  String get testingConnection => isPl ? 'Sprawdzanie…' : (isUk ? 'Перевірка…' : 'Проверка…');
  String get dataSection => isPl ? 'Dane' : (isUk ? 'Дані' : 'Данные');
  String get clearCacheTitle => isPl ? 'Wyczyść pamięć podręczną AI' : (isUk ? 'Очистити кеш ШІ-розборів' : 'Очистить кэш ИИ-разборов');
  String get clearCacheSub => isPl
      ? 'Słowa w słowniku nie zostaną usunięte'
      : (isUk ? 'Слова у словнику не видаляються' : 'Слова в словаре не удаляются');
  String cacheClearedSnack(int n) => isPl
      ? 'Pamięć podręczna AI wyczyszczona (wpisów: $n)'
      : (isUk ? 'Кеш ШІ очищено (записів: $n)' : 'Кэш ИИ очищен (записей: $n)');
  String get aboutAppTitle => isPl ? 'O aplikacji i aktualizacje' : (isUk ? 'Про додаток та оновлення' : 'О приложении и обновления');
  String versionShort(String v) => isPl ? 'Wersja: v$v' : (isUk ? 'Версія: v$v' : 'Версия: v$v');
  String get checkUpdatesBtn => isPl ? '🔄 Sprawdź aktualizacje' : (isUk ? '🔄 Перевірити оновлення' : '🔄 Проверить обновления');
  String get checkingUpdates => isPl ? 'Sprawdzanie…' : (isUk ? 'Перевірка…' : 'Проверка…');
  String alreadyLatestVersion(String v) => isPl
      ? '✅ Masz zainstalowaną najnowszą wersję (v$v)'
      : (isUk
          ? '✅ У вас встановлена актуальна версія (v$v)'
          : '✅ У вас установлена актуальная версия (v$v)');
  String updateAvailable(String v) => isPl ? 'Aktualizacja v$v' : (isUk ? 'Оновлення v$v' : 'Обновление v$v');
  String get currentVersion => isPl ? 'Aktualna wersja' : (isUk ? 'Поточна версія' : 'Текущая версия');
  String get newVersion => isPl ? 'Nowa wersja' : (isUk ? 'Нова версія' : 'Новая версия');
  String get whatsNew => isPl ? 'Co nowego:' : (isUk ? 'Що нового:' : 'Что нового:');
  String get downloadApk => isPl ? 'Pobierz APK' : (isUk ? 'Завантажити APK' : 'Скачать APK');

  // --- Переводчик / Сканер ---
  String get modeCamera => isPl ? 'Aparat' : (isUk ? 'Камера' : 'Камера');
  String get modeDocument => isPl ? 'Dokument' : (isUk ? 'Документ' : 'Документ');
  String get modeText => isPl ? 'Tekst' : (isUk ? 'Текст' : 'Текст');
  String get translateAll => isPl ? '📄 Przetłumacz wszystko' : (isUk ? '📄 Перекласти все' : '📄 Перевести всё');
  String get batchAddWordsBtn => isPl
      ? '📥 Dodaj słowa kluczowe do słownika'
      : (isUk ? '📥 Додати ключові слова до словника' : '📥 Добавить ключевые слова в словарь');
  String get originalText => isPl ? 'Oryginał' : (isUk ? 'Оригінал' : 'Оригинал');
  String get translationAi => isPl ? '文A Tłumaczenie' : (isUk ? '文A Переклад' : '文A Перевод');
  String get translatingParagraph => isPl
      ? 'Wykonywanie tłumaczenia…'
      : (isUk ? 'Виконується переклад…' : 'Выполняется перевод…');

  // --- Ролевые диалоги ---
  String get roleplayScreenTitle => isPl ? '💬 Dialog sytuacyjny' : (isUk ? '💬 Рольовий діалог' : '💬 Ролевой диалог');
  String get hintLabel => isPl ? 'Podpowiedź:' : (isUk ? 'Підказка:' : 'Подсказка:');
  String get listenHint => isPl ? 'Posłuchaj' : (isUk ? 'Послухати' : 'Послушать');
  String get inputMessageHint => isPl
      ? 'Napisz odpowiedź po polsku…'
      : (isUk ? 'Напишіть відповідь польською…' : 'Напишите ответ по-польски…');

  // --- Паспорт достижений ---
  String get passportTitle =>
      isPl ? '🇵🇱 Polski Paszport' : (isUk ? '🇵🇱 Польський паспорт' : '🇵🇱 Польский паспорт');

  String get passportSubtitle => isPl
      ? 'Twoje osiągnięcia w nauce polskiego'
      : (isUk ? 'Ваші досягнення у вивченні польської' : 'Ваши достижения в изучении польского');

  String passportProgressLabel(int obtained, int total) => isPl
      ? 'Odblokowano $obtained z $total pieczęci'
      : (isUk ? 'Отримано $obtained з $total печаток' : 'Получено $obtained из $total печатей');

  String get passportShareTooltip => isPl
      ? 'Podziel się paszportem'
      : (isUk ? 'Поділитися паспортом' : 'Поделиться паспортом');

  String get passportShareHint => isPl
      ? 'Zrób zrzut ekranu i pochwal się w mediach społecznościowych! 🇵🇱'
      : (isUk ? 'Зробіть скріншот та поділіться у соцмережах! 🇵🇱' : 'Сделайте скриншот и поделитесь в соцсетях! 🇵🇱');

  String get passportNavLabel =>
      isPl ? 'Paszport' : (isUk ? 'Паспорт' : 'Паспорт');

  String get achievementUnlocked =>
      isPl ? '✅ Odblokowane!' : (isUk ? '✅ Отримано!' : '✅ Получено!');

  String get achievementLocked => isPl
      ? '🔒 Jeszcze nie odblokowane'
      : (isUk ? '🔒 Ще не отримано' : '🔒 Ещё не получено');

  String get achievementToastTitle => isPl
      ? '🎉 Nowe osiągnięcie!'
      : (isUk ? '🎉 Нове досягнення!' : '🎉 Новое достижение!');

  // --- Разбор польских документов (Smart Doc Scanner) ---
  String get docAnalysisBtn => isPl
      ? '⚖️ Analiza dokumentu (AI)'
      : (isUk ? '⚖️ Аналіз документа (ШІ)' : '⚖️ Анализ документа (ИИ)');

  String get docAnalysisTitle => isPl
      ? 'Analiza dokumentu'
      : (isUk ? 'Аналіз документа' : 'Анализ документа');

  String get docAnalyzing => isPl
      ? 'AI analizuje warunki, opłaty i ryzyka…'
      : (isUk ? 'ШІ аналізує умови, платежі та ризики…' : 'ИИ анализирует условия, платежи и риски…');

  String get docSectionSummary => isPl
      ? '💡 Sedno dokumentu'
      : (isUk ? '💡 Суть документа' : '💡 Суть документа');

  String get docSectionFinancials => isPl
      ? '💰 Warunki finansowe i opłaty'
      : (isUk ? '💰 Фінансові умови та платежі' : '💰 Финансовые условия и платежи');

  String get docSectionRisks => isPl
      ? '⚠️ Ukryte ryzyka i pułapki'
      : (isUk ? '⚠️ Підводні камені та ризики' : '⚠️ Подводные камни и риски');

  String get docSectionActions => isPl
      ? '📋 Wymagane działania (Co zrobić)'
      : (isUk ? '📋 Що потрібно зробити (Дії)' : '📋 Что нужно сделать (Действия)');

  String get docSectionVocab => isPl
      ? '📚 Terminy urzędowe z dokumentu'
      : (isUk ? '📚 Офіційні терміни з документа' : '📚 Официальные термины из документа');

  String get docAddVocabBtn => isPl
      ? '📥 Dodaj terminy do słownika'
      : (isUk ? '📥 Додати терміни до словника' : '📥 Добавить термины в словарь');

  String get docCopySummary => isPl
      ? 'Kopiuj analizę'
      : (isUk ? 'Копіювати аналіз' : 'Скопировать анализ');

  String get docCopiedSnack => isPl
      ? '📋 Skopiowano analizę do schowka'
      : (isUk ? '📋 Аналіз скопійовано в буфер обміну' : '📋 Анализ скопирован в буфер обмена');

  String get docNoRisks => isPl
      ? 'Nie wykryto krytycznych ukrytych ryzyk'
      : (isUk ? 'Критичних прихованих ризиків не виявлено' : 'Критических скрытых рисков не обнаружено');

  String get docNoFinancials => isPl
      ? 'Brak określonych zobowiązań finansowych'
      : (isUk ? 'Фінансові зобов\'язання не вказані' : 'Финансовые обязательства не указаны');

  String get docAnalysisTip => isPl
      ? 'Skieruj aparat na umowę lub pismo urzędowe, aby sprawdzić ryzyka'
      : (isUk
          ? 'Наведіть камеру на договір або лист, щоб перевірити ризики'
          : 'Наведите камеру на договор или письмо, чтобы проверить риски');

  // --- Польское ресторанное меню (Menu Scanner) ---
  String get menuModeTitle => isPl ? '🍽️ Menu' : (isUk ? '🍽️ Меню' : '🍽️ Меню');
  String get menuAnalysisBtn => isPl
      ? '🍽️ Rozpoznaj dania (AI)'
      : (isUk ? '🍽️ Розібрати меню (ШІ)' : '🍽️ Разобрать меню (ИИ)');
  String get menuCheatSheetBtn => isPl
      ? '🗣️ Zwroty z kelnerem'
      : (isUk ? '🗣️ Фрази для офіціанта' : '🗣️ Фразы для официанта');
  String get menuAnalyzing => isPl
      ? 'AI analizuje kartę dań, składniki i alergeny…'
      : (isUk
          ? 'ШІ аналізує меню, страви та алергени…'
          : 'ИИ анализирует меню, блюда и аллергены…');
  String get menuSelectPrompt => isPl
      ? 'Zrób zdjęcie karty dań w restauracji lub wybierz zdjęcie z galerii'
      : (isUk
          ? 'Сфотографуйте меню в ресторані або оберіть фото з галереї'
          : 'Сфотографируйте меню в ресторане или выберите фото из галереи');
  String get menuTakePhotoBtn => isPl
      ? 'Zrób zdjęcie menu'
      : (isUk ? 'Сфотографувати меню' : 'Сфотографировать меню');
  String get menuPickPhotoBtn => isPl
      ? 'Wybierz zdjęcie z galerii'
      : (isUk ? 'Обрати фото з галереї' : 'Выбрать фото из галереи');

  // --- Мой польский за месяц (Monthly Progress Wrapped) ---
  String get monthlyWrappedTitle => isPl
      ? 'Mój polski w tym miesiącu'
      : (isUk ? 'Мій польський за місяць' : 'Мой польский за месяц');

  String get monthlyWrappedTooltip => isPl
      ? 'Mój polski w tym miesiącu'
      : (isUk ? 'Мій польський за місяць' : 'Мой польский за месяц');

  // --- Режим «Диктант» (Active Recall Speller) ---
  String get dictationListenHint => isPl
      ? 'Posłuchaj i wpisz usłyszane słowo:'
      : (isUk ? 'Послухайте та введіть почуте слово:' : 'Послушайте и введите услышанное слово:');
  String get dictationInputPlaceholder => isPl
      ? 'Wpisz po polsku...'
      : (isUk ? 'Введіть польською...' : 'Введите по-польски...');
  String get dictationCheckBtn => isPl
      ? 'Sprawdź'
      : (isUk ? 'Перевірити' : 'Проверить');
  String get dictationNextBtn => isPl
      ? 'Następne słowo →'
      : (isUk ? 'Наступне слово →' : 'Следующее слово →');
  String get dictationSlowBtn => isPl
      ? 'Wolniej (0.3x)'
      : (isUk ? 'Повільніше (0.3x)' : 'Медленнее (0.3x)');
  String get dictationNormalBtn => isPl
      ? 'Normalnie'
      : (isUk ? 'Звичайно' : 'Обычная');
  String get dictationCorrectTitle => isPl
      ? '🎉 Brawo! Idealnie!'
      : (isUk ? '🎉 Чудово! Ідеально!' : '🎉 Отлично! Идеально!');
  String get dictationIncorrectTitle => isPl
      ? '⚠️ Prawie! Zwróć uwagę na pisownię:'
      : (isUk ? '⚠️ Майже! Зверніть увагу на написання:' : '⚠️ Почти! Обратите внимание на написание:');
  String get dictationYourInputLabel => isPl
      ? 'Twój zapis:'
      : (isUk ? 'Ваш варіант:' : 'Ваш вариант:');
  String get dictationCorrectWordLabel => isPl
      ? 'Prawidłowo:'
      : (isUk ? 'Правильно:' : 'Правильно:');
  String get dictationRuleTipLabel => isPl
      ? '💡 Reguła ortograficzna:'
      : (isUk ? '💡 Правило орфографії:' : '💡 Правило орфографии:');
  String get dictationMeaningLabel => isPl
      ? 'Znaczenie:'
      : (isUk ? 'Значення:' : 'Значение:');
  String get dictationExampleLabel => isPl
      ? 'Przykład w zdaniu:'
      : (isUk ? 'Приклад у реченні:' : 'Пример в предложении:');
  String get dictationModeTraps => isPl
      ? '🎯 Pułapki ortograficzne (rz/ż, ch/h, ó/u)'
      : (isUk ? '🎯 Пастки орфографії (rz/ż, ch/h, ó/u)' : '🎯 Ловушки орфографии (rz/ż, ch/h, ó/u)');
  String get dictationModeDeck => isPl
      ? '📚 Słowa z mojego słownika'
      : (isUk ? '📚 Слова з мого словника' : '📚 Слова из моего словаря');
  String get dictationEmptyDeckNotice => isPl
      ? 'Brak słów w Twoim słowniku. Dodaj słowa przez skaner lub wpis ręczny!'
      : (isUk
          ? 'У вашому словнику ще немає слів. Додайте слова через сканер або вручну!'
          : 'В вашем словаре пока нет слов. Добавьте слова через сканер или вручную!');
  String get dictationLetterBankLabel => isPl
      ? 'Wybierz litery do słowa:'
      : (isUk ? 'Літери для складання слова:' : 'Буквы для составления слова:');
  String get dictationDiacriticsLabel => isPl
      ? 'Polskie znaki:'
      : (isUk ? 'Польські діакритики:' : 'Польская диакритика:');
  String get dictationBackspace => isPl
      ? 'Cofnij'
      : (isUk ? 'Стерти' : 'Стереть');

  String dictationProgress(int cur, int total) => isPl
      ? 'Słowo $cur z $total'
      : (isUk ? 'Слово $cur з $total' : 'Слово $cur из $total');
  String get dictationFinishedTitle => isPl
      ? '🏆 Runda dyktanda ukończona!'
      : (isUk ? '🏆 Раунд диктанту завершено!' : '🏆 Раунд диктанта завершен!');
  String get dictationNewRoundBtn => isPl
      ? 'Kolejna runda'
      : (isUk ? 'Наступний раунд' : 'Следующий раунд');

  // Onboarding & Profile
  String get onboardingSkip => isPl ? 'Pomiń' : (isUk ? 'Пропустити' : 'Пропустить');
  String get onboardingNext => isPl ? 'Dalej' : (isUk ? 'Далі' : 'Далее');
  String get onboardingFinish => isPl ? 'Rozpocznij naukę 🚀' : (isUk ? 'Почати навчання 🚀' : 'Начать обучение 🚀');
  String get onboardingStep1Title => isPl ? 'Poznajmy się' : (isUk ? 'Знайомство' : 'Знакомство');
  String get onboardingStep1Prompt => isPl
      ? 'Cześć! Jestem Kasia — Twój osobisty nauczyciel języka polskiego 🇵🇱. Jak masz na imię?'
      : (isUk
          ? 'Привіт! Я Kasia — твій особистий тьютор польської мови 🇵🇱. Як тебе звати?'
          : 'Привет! Я Kasia — твой личный тьютор польского языка 🇵🇱. Как тебя зовут?');
  String get onboardingStep1Hint => isPl ? 'Wpisz swoje imię…' : (isUk ? 'Введіть ваше ім\'я…' : 'Введите ваше имя…');
  String get onboardingStep1QuickName => isPl ? 'Przyjaciel' : (isUk ? 'Друг' : 'Друг');
  String get onboardingStep2Title => isPl ? 'Twój poziom' : (isUk ? 'Твій рівень' : 'Твой уровень');
  String get onboardingStep2Prompt => isPl
      ? 'Na jakim poziomie jest teraz Twój polski?'
      : (isUk ? 'На якому рівні зараз ваша польська?' : 'На каком уровне сейчас ваш польский?');
  String get onboardingLevelStarterTitle => isPl ? 'Dopiero zaczynam' : (isUk ? 'Тільки починаю' : 'Только начинаю');
  String get onboardingLevelStarterDesc => isPl
      ? 'Znam pojedyncze słowa lub zaczynam od zera'
      : (isUk ? 'Знаю окремі слова або починаю з нуля' : 'Знаю отдельные слова или начинаю с нуля');
  String get onboardingLevelBasicTitle => isPl ? 'Znam podstawy (A1–A2)' : (isUk ? 'Знаю основи (A1–A2)' : 'Знаю основы (A1–A2)');
  String get onboardingLevelBasicDesc => isPl
      ? 'Rozumiem proste zdania, ale chcę pewnie mówić'
      : (isUk ? 'Розумію прості речення, але хочу впевнено говорити' : 'Понимаю простые фразы, но хочу уверенно говорить');
  String get onboardingLevelInterTitle => isPl ? 'Średniozaawansowany (B1+)' : (isUk ? 'Середній рівень (B1+)' : 'Средний уровень (B1+)');
  String get onboardingLevelInterDesc => isPl
      ? 'Szlifuję gramatykę, przygotowuję się do egzaminu lub pracy'
      : (isUk ? 'Шліфую граматику, готуюся до іспиту чи роботи' : 'Шлифую грамматику, готовлюсь к экзамену или работе');
  String get onboardingStep3Title => isPl ? 'Twój cel' : (isUk ? 'Твоя мета' : 'Твоя цель');
  String get onboardingStep3Prompt => isPl
      ? 'Jaki jest Twój główny cel nauki w Polsce?'
      : (isUk ? 'Яка ваша головна мета навчання в Польщі?' : 'Какая ваша главная цель обучения в Польше?');
  String get onboardingGoalDailyTitle => isPl ? 'Życie i zakupy' : (isUk ? 'Життя та побут' : 'Жизнь и быт');
  String get onboardingGoalDailyDesc => isPl
      ? 'Sklepy, kawiarnie, transport, codzienne rozmowy'
      : (isUk ? 'Магазини, кав\'ярні, транспорт, щоденні розмови' : 'Магазины, кафе, транспорт, повседневные разговоры');
  String get onboardingGoalDocsTitle => isPl ? 'Urząd i dokumenty' : (isUk ? 'Ужонд і документи' : 'Ужонд и документы');
  String get onboardingGoalDocsDesc => isPl
      ? 'PESEL, karta pobytu, bank, umowy, urzędy'
      : (isUk ? 'PESEL, карта побиту, банк, договори, держустанови' : 'PESEL, карта побыту, банк, договоры, госорганы');
  String get onboardingGoalWorkTitle => isPl ? 'Praca w Polsce' : (isUk ? 'Робота в Польщі' : 'Работа в Польше');
  String get onboardingGoalWorkDesc => isPl
      ? 'Rozmowa rekrutacyjna, kontakt ze współpracownikami'
      : (isUk ? 'Співбесіди, контакт із колегами та керівництвом' : 'Собеседование, общение с коллегами и начальством');
  String get onboardingGoalExamTitle => isPl ? 'Egzamin B1 / Obywatelstwo' : (isUk ? 'Іспит B1 / Громадянство' : 'Экзамен B1 / Гражданство');
  String get onboardingGoalExamDesc => isPl
      ? 'Certyfikat państwowy, ortografia, pisanie'
      : (isUk ? 'Державний сертифікат, орфографія, правопис' : 'Госсертификат, орфография, правописание');
  String get onboardingStep4Title => isPl ? 'Pierwsza fraza' : (isUk ? 'Перша фраза' : 'Первая фраза');
  String get onboardingStep4Prompt => isPl
      ? 'Nauczmy się Twojej pierwszej frazy z poprawną wymową:'
      : (isUk ? 'Вивчимо твою першу польську фразу з правильною вимовою:' : 'Выучим твою первую польскую фразу с правильным произношением:');
  String get onboardingStep4Action => 'Miło mi Cię poznać! 🤝';
  String get onboardingStep4Success => isPl
      ? 'Świetnie! Pierwsza pieczątka w Polskim Paszporcie odblokowana! 🇵🇱'
      : (isUk
          ? 'Чудово! Перша печатка у Польському паспорті розблокована! 🇵🇱'
          : 'Отлично! Первая печать в Польском паспорте разблокирована! 🇵🇱');
  String get profileSectionTitle => isPl ? 'Mój profil i cel' : (isUk ? 'Мій профіль і мета' : 'Мой профиль и цель');
  String get profileRestartOnboarding => isPl
      ? 'Przejdź powitanie z Kasią ponownie'
      : (isUk ? 'Пройти знайомство з Kasią знову' : 'Пройти знакомство с Kasią заново');
  String get profileGoalLabel => isPl ? 'Cel:' : (isUk ? 'Мета:' : 'Цель:');
  String get profileLevelLabel => isPl ? 'Poziom:' : (isUk ? 'Рівень:' : 'Уровень:');

  // Professions
  String get professionsTitle => isPl
      ? 'Polski dla profesji'
      : (isUk ? 'Польська для професій' : 'Польский для профессий');
  String get professionsBannerSub => isPl
      ? 'Logistyka, budowa, gastronomia, sprzątanie, IT i biuro'
      : (isUk
          ? 'Логістика, будівництво, кухня, клінінг, IT та офіс'
          : 'Логистика, стройка, кухня, клининг, IT и офис');
  String get professionsTabVocab => isPl
      ? 'Słownik i zwroty'
      : (isUk ? 'Словник і фрази' : 'Словарь и фразы');
  String get professionsTabDialogs => isPl
      ? 'Dialogi z AI'
      : (isUk ? 'Діалоги з ШІ' : 'Диалоги с ИИ');
  String get professionsAddAllTooltip => isPl
      ? 'Dodaj wszystkie słowa z tej kategorii do słownika'
      : (isUk
          ? 'Додати всі слова цієї категорії до словника'
          : 'Добавить все слова этой категории в словарь');
  String get professionsStartRoleplayBtn => isPl
      ? 'Rozpocznij dialog sytuacyjny'
      : (isUk ? 'Почати ситуаційний діалог' : 'Начать ситуационный диалог');
  String get professionsCategoryLife => isPl
      ? 'Życie codzienne'
      : (isUk ? 'Повсякденне життя' : 'Повседневная жизнь');
  String get professionsCategoryWork => isPl
      ? 'Praca i zawody'
      : (isUk ? 'Робота та професії' : 'Работа и профессии');

  // --- Живые эпизоды (Story Mode / Сериал) ---
  String get episodesTitle => isPl
      ? 'Żywe odcinki'
      : (isUk ? 'Живі епізоди' : 'Живые эпизоды');
  String get episodesSubtitle => isPl
      ? 'Serial interaktywny: Życie w Polsce'
      : (isUk
          ? 'Інтерактивний серіал: Життя в Польщі'
          : 'Интерактивный сериал: Жизнь в Польше');
  String get episodesBannerSub => isPl
      ? '5 odcinków: od wynajmu mieszkania do pierwszej wypłaty'
      : (isUk
          ? '5 серій: від оренди житла до першої зарплати'
          : '5 серий: от аренды жилья до первой зарплаты');
  String get episodesSeason1 => isPl
      ? 'Sezon 1: Pierwszy miesiąc w Polsce'
      : (isUk ? 'Сезон 1: Перший місяць у Польщі' : 'Сезон 1: Первый месяц в Польше');
  String get episodesVocabTitle => isPl
      ? 'Słownik przetrwania w odcinku'
      : (isUk ? 'Словник виживання в серії' : 'Словарь выживания в серии');
  String get episodesScenesTitle => isPl
      ? 'Sceny fabularne odcinka'
      : (isUk ? 'Сюжетні сцени серії' : 'Сюжетные сцены серии');
  String get episodesAddVocabAll => isPl
      ? 'Dodaj słowa odcinka do słownika'
      : (isUk
          ? 'Додати слова серії до словника'
          : 'Добавить слова серии в словарь');

  // --- Экзаменационный Boss Fight (CEFR Assessment) ---
  String get examBossTitle => isPl
      ? 'Egzamin Ustny CEFR'
      : (isUk ? 'Екзаменаційний Boss Fight' : 'Экзаменационный Boss Fight');
  String get examBossSubtitle => isPl
      ? 'Państwowa Komisja Egzaminacyjna'
      : (isUk
          ? 'Суворий 5-хвилинний іспит без підказок'
          : 'Строгий 5-минутный экзамен без подсказок');
  String get examBossBannerSub => isPl
      ? 'Sprawdź swój poziom (A1–B2) i odbierz oficjalny certyfikat'
      : (isUk
          ? '5-хвилинна перевірка без підказок та сертифікат рівня'
          : '5-минутная проверка без подсказок и сертификат уровня');
  String get examBossBadge => 'CEFR A1–B2';
  String get examStage1 => isPl
      ? '1. Kim jesteś i plany w Polsce'
      : (isUk ? '1. Хто ви та плани в Польщі' : '1. Кто вы и планы в Польше');
  String get examStage2 => isPl
      ? '2. Rozwiązanie sytuacji życiowej'
      : (isUk ? '2. Вирішення життєвої ситуації' : '2. Решение жизненной ситуации');
  String get examStage3 => isPl
      ? '3. Opinia i argumentacja'
      : (isUk ? '3. Думка та аргументація' : '3. Мнение и аргументация');
  String get examTimerLabel => isPl
      ? 'Czas egzaminu'
      : (isUk ? 'Час іспиту' : 'Время экзамена');
  String get examFinishButton => isPl
      ? 'Zakończ i odbierz ocenę'
      : (isUk ? 'Завершити та отримати оцінку' : 'Завершить и получить оценку');
  String get examCertificateTitle => isPl
      ? 'Certyfikat Biegłości Językowej'
      : (isUk
          ? 'Сертифікат знання польської мови'
          : 'Сертификат владения польским языком');
  String get examCriteriaVocab => isPl
      ? 'Zasób słownictwa'
      : (isUk ? 'Словниковий запас' : 'Словарный запас');
  String get examCriteriaGrammar => isPl
      ? 'Gramatyka i odmiana'
      : (isUk ? 'Граматика та відмінювання' : 'Грамматика и формы слов');
  String get examCriteriaFluency => isPl
      ? 'Płynność i spójność'
      : (isUk ? 'Плинність та зв’язність' : 'Беглость и связность');
  String get examCriteriaInteraction => isPl
      ? 'Reakcja i zrozumienie'
      : (isUk ? 'Реакція та розуміння' : 'Реакция и понимание темы');
  String get examPassed => isPl
      ? 'EGZAMIN ZDANY'
      : (isUk ? 'ІСПИТ СКЛАДЕНО' : 'ЭКЗАМЕН СДАН');
  String get examNotPassed => isPl
      ? 'WYMAGA POPRAWY'
      : (isUk ? 'ПОТРЕБУЄ ПОВТОРЕННЯ' : 'ТРЕБУЕТСЯ ПОВТОРЕНИЕ');
  String get examHistoryTitle => isPl
      ? 'Historia egzaminów'
      : (isUk ? 'Історія іспитів' : 'История экзаменов');

  // --- Руководство пользователя (User Guide) ---
  String get userGuideTitle => isPl
      ? 'Podręcznik użytkownika'
      : (isUk ? 'Керівництво користувача' : 'Руководство пользователя');
  String get userGuideSubtitle => isPl
      ? 'Kompletny przewodnik po wszystkich funkcjach aplikacji'
      : (isUk
          ? 'Повний довідник по всіх функціях додатку'
          : 'Полный справочник по всем функциям приложения');
  String get userGuideSearchHint => isPl
      ? 'Szukaj w podręczniku…'
      : (isUk ? 'Пошук по посібнику…' : 'Поиск по руководству…');
  String get userGuideOpenSection => isPl
      ? 'Otwórz funkcję w aplikacji'
      : (isUk ? 'Відкрити у додатку' : 'Перейти в приложении');

  String get primerTitle => isPl
      ? 'Polski Elementarz (A0)'
      : (isUk ? 'Польський Буквар (A0)' : 'Польский Букварь (A0)');
  String get primerSubtitle => isPl
      ? 'Dźwięki, liczby 0-1000 i 250 pierwszych słów'
      : (isUk
          ? 'Звуки, числа 0-1000 та 250 перших слів'
          : 'Звуки, числа 0-1000 и 250 первых слов');
  String get primerBadge => isPl
      ? 'KROK ZEROWY • OD ZERA'
      : (isUk ? 'КРОК НУЛЬОВИЙ • ВІД ЗЕРО' : 'ШАГ НУЛЕВОЙ • С НУЛЯ');

  // --- Резервное копирование (Backup & Restore) ---
  String get backupSectionTitle => isPl
      ? 'Kopia zapasowa i przywracanie'
      : (isUk ? 'Резервне копіювання та відновлення' : 'Резервное копирование и восстановление');
  String get backupSectionSub => isPl
      ? 'Zapisz całą bazę słów, osiągnięć i ustawień do pliku lub przywróć ją na nowym telefonie.'
      : (isUk
          ? 'Збережіть базу слів, досягнень та налаштувань у файл або відновіть її на новому телефоні.'
          : 'Сохраните базу слов, достижений и настроек в файл или восстановите её на новом телефоне.');
  String get exportBackupBtn => isPl
      ? 'Utwórz kopię zapasową (.json)'
      : (isUk ? 'Створити резервну копію (.json)' : 'Создать резервную копию (.json)');
  String get importBackupBtn => isPl
      ? 'Przywróć z kopii (.json)'
      : (isUk ? 'Відновити з копії (.json)' : 'Восстановить из копии (.json)');
  String get backupExportSuccess => isPl
      ? 'Kopia zapasowa została pomyślnie utworzona!'
      : (isUk ? 'Резервну копію успішно створено!' : 'Резервная копия успешно создана!');
  String backupImportSuccess(int words, int prefs) => isPl
      ? 'Przywrócono $words słów oraz $prefs ustawień!'
      : (isUk
          ? 'Успішно відновлено $words слів та $prefs налаштувань!'
          : 'Успешно восстановлено $words слов и $prefs параметров!');
  String get confirmRestoreTitle => isPl
      ? 'Przywrócić dane z pliku?'
      : (isUk ? 'Відновити дані з файлу?' : 'Восстановить данные из файла?');
  String get confirmRestoreBody => isPl
      ? 'Wszystkie słowa i postępy z pliku kopii zostaną zsynchronizowane z Twoją aplikacją.'
      : (isUk
          ? 'Усі слова та прогрес із файлу копії будуть синхронізовані з вашим додатком.'
          : 'Все слова и прогресс из файла копии будут синхронизированы с вашим приложением.');

  // --- Сквозные мостики (Deep Cross-Linking) ---
  String get addMistakesToDict => isPl
      ? 'Dodaj błędy do słownika'
      : (isUk ? 'Додати помилки до словника' : 'Добавить ошибки в словарь');
  String get trainInDictation => isPl
      ? 'Poćwicz w dyktandzie'
      : (isUk ? 'Потренувати в диктанті' : 'Потренировать в диктанте');
  String get goToTask => isPl
      ? 'Przejdź do zadania'
      : (isUk ? 'Перейти до завдання' : 'Перейти к заданию');
  String get startSm2Session => isPl
      ? 'Powtórz słowa (SM-2)'
      : (isUk ? 'Повторити слова (SM-2)' : 'Повторить слова (SM-2)');

  // --- Локальные напоминания (Daily Push Notifications) ---
  String get notificationsCardTitle => isPl
      ? '🔔 Codzienne przypomnienia'
      : (isUk ? '🔔 Щоденні нагадування' : '🔔 Ежедневные напоминания');
  String get notificationsCardDesc => isPl
      ? 'Przypomnienia o powtórkach słówek SM-2 i utrzymaniu serii nauki.'
      : (isUk
          ? 'Нагадування про повторення слів SM-2 та збереження ударного режиму.'
          : 'Напоминания о повторении слов SM-2 и сохранении ударного режима.');
  String get notificationsToggleLabel => isPl
      ? 'Włącz przypomnienia'
      : (isUk ? 'Увімкнути нагадування' : 'Включить напоминания');
  String get notificationsTimeLabel => isPl
      ? 'Godzina przypomnienia'
      : (isUk ? 'Час нагадування' : 'Время напоминания');
  String get notificationsTestBtn => isPl
      ? 'Wyślij testowe powiadomienie'
      : (isUk ? 'Надіслати тестове сповіщення' : 'Отправить тестовое уведомление');
  String get notificationsTestSentSnack => isPl
      ? '🔔 Powiadomienie zostało wysłane!'
      : (isUk ? '🔔 Сповіщення надіслано!' : '🔔 Уведомление отправлено!');
  String get notificationsPermissionDenied => isPl
      ? 'Brak uprawnień do powiadomień. Zezwól na nie w ustawieniach systemu.'
      : (isUk
          ? 'Немає дозволу на сповіщення. Дозвольте їх у налаштуваннях системи.'
          : 'Нет разрешения на уведомления. Разрешите их в настройках системы.');
}


final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(settingsProvider.select((s) => s.lang));
  return AppStrings(lang);
});

