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

  // --- Мой польский за месяц (Monthly Progress Wrapped) ---
  String get monthlyWrappedTitle => isPl
      ? 'Mój polski w tym miesiącu'
      : (isUk ? 'Мій польський за місяць' : 'Мой польский за месяц');

  String get monthlyWrappedTooltip => isPl
      ? 'Mój polski w tym miesiącu'
      : (isUk ? 'Мій польський за місяць' : 'Мой польский за месяц');
}


final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(settingsProvider.select((s) => s.lang));
  return AppStrings(lang);
});

