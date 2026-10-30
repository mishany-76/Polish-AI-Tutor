import '../scanner/translation_service.dart' show UiLang;

class GuideSectionItem {
  const GuideSectionItem({
    required this.id,
    required this.emoji,
    required this.titlePl,
    required this.titleUk,
    required this.titleRu,
    required this.summaryPl,
    required this.summaryUk,
    required this.summaryRu,
    required this.contentPl,
    required this.contentUk,
    required this.contentRu,
    this.routeAction,
  });

  final String id;
  final String emoji;
  final String titlePl;
  final String titleUk;
  final String titleRu;
  final String summaryPl;
  final String summaryUk;
  final String summaryRu;
  final String contentPl;
  final String contentUk;
  final String contentRu;
  final String? routeAction;

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

  String summary(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return summaryUk;
      case UiLang.ru:
        return summaryRu;
      case UiLang.pl:
        return summaryPl;
    }
  }

  String content(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return contentUk;
      case UiLang.ru:
        return contentRu;
      case UiLang.pl:
        return contentPl;
    }
  }
}

/// База данных подробного руководства пользователя на трех языках
const List<GuideSectionItem> kAllGuideSections = [
  // 1. Онбординг
  GuideSectionItem(
    id: 'onboarding',
    emoji: '🚀',
    titlePl: '1. Szybki start i powitanie z Kasią',
    titleUk: '1. Швидкий старт та знайомство з Kasią',
    titleRu: '1. Быстрый старт и знакомство с Kasią',
    summaryPl: 'Pierwsze 60 sekund w aplikacji, wybór poziomu CEFR i celów.',
    summaryUk: 'Перші 60 секунд у додатку, вибір рівня CEFR та цілей.',
    summaryRu: 'Первые 60 секунд в приложении, выбор уровня CEFR и целей.',
    contentPl: '''### 🎯 Czym jest Onboarding z Kasią?
To interaktywna rozmowa wprowadzająca, która trwa zaledwie 60 sekund. Zamiast wypełniania nudnych formularzy, witasz się ze swoją osobistą polską tutorką Kasią.

### 📋 Co ustala system:
1. **Twój początkowy poziom znajomości języka:**
   - *Początkujący (A0/A1)* — nigdy wcześniej nie uczyłeś się polskiego.
   - *Podstawowy (A1–A2)* — rozumiesz proste zwroty, znasz podstawy.
   - *Średniozaawansowany (B1+)* — swobodnie rozmawiasz, szlifujesz fleksję i niuanse.
2. **Główny cel nauki:**
   - *Życie codzienne* (zakupy, wynajem, transport, kawiarnie).
   - *Załatwianie spraw urzędowych* (PESEL, ZUS, Urząd Skarbowy).
   - *Praca i kariera* (rozmowy z brygadzistą, klientami, zespołem).
   - *Egzamin państwowy B1* (certyfikat państwowy).

### 💡 Pierwsze osiągnięcie:
Już podczas onboardingu odsłuchujesz swoją pierwszą praktyczną frazę z syntezatorem mowy (TTS) i odblokowujesz pierwszą pieczęć w Polskim Paszporcie!

*Wskazówka: Możesz w każdej chwili zrestartować onboarding w zakładce „Ustawienia”.*''',
    contentUk: '''### 🎯 Що таке Онбординг з Kasią?
Це інтерактивна розмова-знайомство, яка триває лише 60 секунд. Замість заповнення нудних анкет, ви вітаєтеся зі своєю особистою польською викладачкою Касею.

### 📋 Що визначає система:
1. **Ваш стартовий рівень володіння мовою:**
   - *Початківець (A0/A1)* — раніше ніколи не вчили польську.
   - *Базовий (A1–A2)* — розумієте прості фрази, знаєте основи.
   - *Впевнений (B1+)* — вільно спілкуєтеся, шліфуєте відмінювання та граматику.
2. **Головна мета навчання:**
   - *Побут і життя* (магазини, оренда житла, транспорт, кафе).
   - *Ужонд і документи* (PESEL, ZUS, податкова Urząd Skarbowy).
   - *Робота та професія* (спілкування з керівництвом, колегами, клієнтами).
   - *Державний іспит B1* (сертифікат для карти побиту).

### 💡 Перша перемога:
Вже під час знайомства ви прослуховуєте першу польську фразу через озвучку Google TTS та автоматично відкриваєте першу печатку в Польському паспорті!

*Порада: Ви можете повторно пройти онбординг у будь-який момент у меню «Налаштування».*''',
    contentRu: '''### 🎯 Что такое Онбординг с Kasią?
Это интерактивный диалог-знакомство, который занимает всего 60 секунд. Вместо заполнения сухих анкет вы знакомитесь со своим личным польским тьютором Касей.

### 📋 Что настраивает система:
1. **Ваш стартовый уровень владения языком:**
   - *С нуля (A0/A1)* — никогда ранее не учили польский язык.
   - *Базовый (A1–A2)* — понимаете простые фразы, ориентируетесь в основах.
   - *Уверенный (B1+)* — свободно общаетесь, шлифуете падежные формы и беглость.
2. **Главная цель обучения:**
   - *Быт и повседневность* (магазины, аренда жилья, транспорт, кафе).
   - *Ужонд и документы* (PESEL, ZUS, налоговая Urząd Skarbowy).
   - *Работа и профессия* (диалоги с бригадиром, коллегами, клиентами).
   - *Государственный экзамен B1* (сертификат для карты резидента).

### 💡 Первая победа:
Уже во время онбординга вы прослушиваете свою первую полезную фразу через озвучку Google TTS и автоматически открываете первый гербовый штамп в Польском паспорте!

*Совет: Онбординг можно перезапустить в любой момент в разделе «Настройки».*''',
    routeAction: 'onboarding',
  ),

  // 2. Тренажеры
  GuideSectionItem(
    id: 'drills',
    emoji: '🎯',
    titlePl: '2. Treningi i quizy adaptacyjne',
    titleUk: '2. Тренажери та адаптивні вікторини',
    titleRu: '2. Тренажеры и адаптивные викторины',
    summaryPl: '4 klasyczne tryby: Końcówki, Audio, Fałszywi przyjaciele, Liczby i ceny.',
    summaryUk: '4 класичні режими: Закінчення, Аудіо, Хибні друзі, Числа та ціни.',
    summaryRu: '4 классических режима: Окончания, Аудио, Ложные друзья, Числа и цены.',
    contentPl: '''### 🏋️ Główne tryby treningowe:
Na ekranie głównym dostępne są 4 wyspecjalizowane moduły do budowania nawyku językowego:

1. **📝 Końcówki i odmiana (Fleksja):**
   - *Co ćwiczy:* Wszystkie 7 polskich przypadków (Mianownik, Dopełniacz, Celownik, Biernik, Narzędnik, Miejscownik, Wołacz).
   - *Jak działa:* Zdanie z luką (*«Mieszkam w dużym ___»*). Wybierasz poprawną końcówkę spośród 4 wariantów. Po odpowiedzi widzisz regułę gramatyczną i możesz odsłuchać całe zdanie.
   - *Baza:* 1 850 autentycznych zdań.

2. **🎧 Audiotrener z dwujęzycznym dubbingiem:**
   - *Co ćwiczy:* Rozumienie ze słuchu i wymowę.
   - *Jak działa:* Odsłuchujesz naturalną kwestię po polsku i wybierasz właściwe znaczenie. Obie opcje są dubbingowane głosem.
   - *Baza:* 1 850 zdań codziennych.

3. **🪤 Fałszywi przyjaciele (Pułapki językowe):**
   - *Co ćwiczy:* Słowa brzmiące znajomo, ale oznaczające co innego.
   - *Przykład:* *«dywan»* = килим / ковер (a nie kanapa!), *«zakaz»* = заборона / запрет.
   - *Baza:* 1 225 par słów-pułapek.

4. **🔢 Liczby, ceny i płatności BLIK:**
   - *Co ćwiczy:* Kwoty, grosze, godziny, daty i kody płatności.
   - *Przykład:* *«czterdzieści siedem złotych osiemdziesiąt groszy»* = 47,80 zł.

### 🧠 Inteligentny algorytm powtórek błędów:
- Błędne odpowiedzi trafiają do kolejki priorytetowej i wracają natychmiast.
- Aby usunąć słowo z problematycznych, musisz poprawnie odpowiedzieć 2 razy z rzędu.''',
    contentUk: '''### 🏋️ Основні режими тренувань:
На головному екрані доступні 4 спеціалізовані модулі для відпрацювання автоматизму:

1. **📝 Закінчення (Відмінювання):**
   - *Що тренує:* Всі 7 відмінків польської мови (Nominatyw, Dopełniacz, Celownik, Biernik, Narzędnik, Miejscownik, Wołacz).
   - *Як працює:* Речення з пропуском (*«Mieszkam w dużym ___»*). Ви обираєте правильне закінчення з 4 варіантів. Після відповіді бачите граматичне правило та кнопку прослуховування 🔊.
   - *Банк:* 1 850 речень.

2. **🎧 Аудіотренажер з дубляжем:**
   - *Що тренує:* Сприйняття живої польської мови на слух.
   - *Як працює:* Слухаєте фразу польською, обираєте переклад. Кожна картка озвучена природним голосом.
   - *Банк:* 1 850 розмовних речень.

3. **🪤 Хибні друзі (Fałszywi przyjaciele):**
   - *Що тренує:* Слова, які звучать схоже на українські, але мають геть інше значення.
   - *Приклад:* *«dywan»* = килим (а не диван!), *«kawalerka»* = 1-кімнатна квартира, *«czasopismo»* = журнал.
   - *Банк:* 1 225 пар слів-пасток.

4. **🔢 Числа, ціни та рахунки:**
   - *Що тренує:* Суми в злотих і грошах, час, години та операції BLIK на касі.
   - *Банк:* 1 230 завдань.

### 🧠 Алгоритм адаптивної пам'яті:
- Помилкові відповіді потрапляють у список проблемних і показуються в першу чергу.
- Щоб питання вважалося засвоєним, треба двічі поспіль відповісти правильно.''',
    contentRu: '''### 🏋️ Основные режимы тренировок:
На главном экране находятся 4 специализированных модуля для выработки языкового автоматизма:

1. **📝 Окончания (Спряжение и склонение):**
   - *Что тренирует:* Все 7 польских падежей (Nominatyw, Dopełniacz, Celownik, Biernik, Narzędnik, Miejscownik, Wołacz).
   - *Как работает:* Предложение с пропуском (*«Mieszkam w dużym ___»*). Вы выбираете верное окончание из 4 вариантов. После ответа появляется грамматическое правило и кнопка озвучки 🔊.
   - *База:* 1 850 живых предложений.

2. **🎧 Аудиотренажер с двуязычным дубляжем:**
   - *Что тренирует:* Восприятие польской речи на слух и произношение.
   - *Как работает:* Слушаете реплику на польском и находите точный перевод.
   - *База:* 1 850 фраз.

3. **🪤 Ложные друзья переводчика (Fałszywi przyjaciele):**
   - *Что тренирует:* Слова, созвучные с русскими, но имеющие совершенно иной смысл.
   - *Пример:* *«dywan»* = ковер (а не диван!), *«zakaz»* = запрет (а не заказ!), *«owoce»* = фрукты (а не овощи!).
   - *База:* 1 225 пар слов-ловушек.

4. **🔢 Числа, цены и счета:**
   - *Что тренирует:* Цены в магазинах, злотые и гроши, время, расписания и платежи BLIK.
   - *База:* 1 230 практических задач.

### 🧠 Адаптивный алгоритм запоминания:
- Ошибочные ответы автоматически маркируются как проблемные и повторяются в первую очередь.
- Закрепление происходит после 2 верных ответов подряд.''',
    routeAction: 'drills',
  ),

  // 3. Диктант
  GuideSectionItem(
    id: 'dictation',
    emoji: '✍️',
    titlePl: '3. Tryb «Dyktando» (Trener pisowni)',
    titleUk: '3. Режим «Диктант» (Тренер правопису)',
    titleRu: '3. Режим «Диктант» (Тренер правописания)',
    summaryPl: 'Aktywny speller, prędkości 1.0x / 0.3x, pułapki rz/ż, ch/h, ó/u, ą/ę.',
    summaryUk: 'Активний спеллер, швидкості 1.0x / 0.3x, пастки rz/ż, ch/h, ó/u, ą/ę.',
    summaryRu: 'Активный спеллер, скорости 1.0x / 0.3x, ловушки rz/ż, ch/h, ó/u, ą/ę.',
    contentPl: '''### 🎯 Cel trybu:
Polski język pisany słynie ze skomplikowanej ortografii. Tryb „Dyktando” trenuje bezbłędne pisanie słów pod dyktando z syntezatorem mowy.

### ⚙️ Kluczowe możliwości:
1. **Regulacja tempa odsłuchu:**
   - Przycisk 🔊 1.0x — naturalna mowa w normalnym tempie.
   - Przycisk 🐢 0.3x — zwolniona, wyraźna wymowa każdej głoski.
2. **Klawiatura znaków diakrytycznych:**
   - Szybkie wprowadzanie polskich liter: `ą, ć, ę, ł, ń, ó, ś, ź, ż`.
3. **Analiza pułapek ortograficznych:**
   - Aplikacja inteligentnie wyłapuje błędy fonetyczne:
     * `rz` kontra `ż`
     * `u` kontra `ó`
     * `ch` kontra `h`
     * `ą/ę` kontra `om/em`
   - Wyświetla regułę pamięciową (np. *„morze” bo morski, „może” od móc*).
4. **Wybór bazy słów:**
   - Słowa z bazy systemowej lub Twój własny słownik dodanych zwrotów!''',
    contentUk: '''### 🎯 Мета режиму:
Польська орфографія має безліч фонетичних двійників. Режим «Диктант» тренує безпомилкове написання слів під диктовку.

### ⚙️ Головні фішки:
1. **Дві швидкості диктування:**
   - 🔊 1.0x — звичайна розмовна швидкість.
   - 🐢 0.3x — повільне розбірливе читання по звуках.
2. **Панель польської диакритики:**
   - Зручні клавіші для швидкого вводу: `ą, ć, ę, ł, ń, ó, ś, ź, ż`.
3. **Діагностика орфографічних пасток:**
   - Автоматично розпізнає сплутані літери:
     * `rz` / `ż`
     * `u` / `ó`
     * `ch` / `h`
     * `ą/ę` замість сполучень `om/em`
   - Надає мнемонічне правило (наприклад, *morze* через rz, бо чергується з *morski*).
4. **Слова з власної пам'яті:**
   - Можна тренувати як вбудовану базу, так і слова, які ви особисто зберегли зі сканера чи уроків!''',
    contentRu: '''### 🎯 Назначение режима:
Польская орфография славится парами одинаково звучащих букв. Режим «Диктант» тренирует грамотное написание слов на слух.

### ⚙️ Ключевые возможности:
1. **Управление скоростью диктовки:**
   - 🔊 1.0x — естественный живой темп речи.
   - 🐢 0.3x — замедленная четкая артикуляция каждого звука.
2. **Быстрая панель польских букв:**
   - Кнопки мгновенного ввода: `ą, ć, ę, ł, ń, ó, ś, ź, ż`.
3. **Диагностика фонетических ловушек:**
   - Алгоритм точно определяет путаницу:
     * `rz` и `ż`
     * `ó` и `u`
     * `ch` и `h`
     * носовые `ą/ę`
   - Показывает проверочное правило чередования.
4. **Тренировка своего словаря:**
   - Возможность диктовать слова из личной колоды, накопленной в процессе учебы!''',
    routeAction: 'dictation',
  ),

  // 4. Польский паспорт
  GuideSectionItem(
    id: 'passport',
    emoji: '🧳',
    titlePl: '4. Polski Paszport i pieczęcie',
    titleUk: '4. Польський паспорт та гербові печатки',
    titleRu: '4. Польский паспорт и гербовые штампы',
    summaryPl: '15 heraldycznych pieczęci za postępy, serie dni i aktywność.',
    summaryUk: '15 геральдичних печаток за прогрес, серії днів та активність.',
    summaryRu: '15 геральдических штампов за прогресс, серии дней и активность.',
    contentPl: '''### 🇵🇱 Co to jest Polski Paszport?
To interaktywna książeczka osiągnięć stylizowana na oficjalny dokument w estetyce „Warszawskiego Modernizmu”. 

### 🛡️ 15 Pieczęci do zdobycia:
- **Pierwsze kroki:** Pierwsze dodane słowo, pierwsze skanowanie tekstu, pierwszy dialog z Kasią.
- **Słownictwo:** 10, 50, 100 słów w słowniku.
- **Mistrzostwo pamięci:** 10 i 50 słów zapamiętanych na stałe według algorytmu SM-2.
- **Dyscyplina (Streak):** 3 dni z rzędu, 7 dni z rzędu (tydzień!), 30 dni bez przerw (Legenda).
- **Wszechstronność:** Rozegranie wszystkich trybów treningowych.
- **Złota pieczęć:** Komplet wszystkich 14 pieczęci — pełna integracja językowa w Polsce!

Każda pieczęć posiada haptyczną animację przybicia stempla i przycisk do podzielenia się sukcesem w mediach społecznościowych.''',
    contentUk: '''### 🇵🇱 Що таке Польський паспорт?
Це інтерактивна книжечка досягнень у стилі «Варшавського Модерну», оформлена як справжній закордонний паспорт з гербовими візами.

### 🛡️ 15 Геральдичних печаток:
- **Перші кроки:** Перше додане слово, перший скан документа, перший діалог з Касею.
- **Словниковий запас:** 10, 50, 100 слів у словнику.
- **Довготривала пам'ять:** 10 та 50 слів, підтверджених інтервальним алгоритмом SM-2.
- **Серія навчання (Streak):** 3 дні поспіль, 7 днів (тижневий ударний режим), 30 днів без пауз (Легенда).
- **Універсальність:** Спроба всіх 4 тренажерів.
- **Головна Золота печатка:** Зібрати всі попередні 14 печаток — повна адаптація в польському середовищі!

Кожна відкрита печатка вібрує при отриманні та має кнопку шерингу в Instagram / Telegram.''',
    contentRu: '''### 🇵🇱 Что такое Польский паспорт?
Это интерактивная книжка достижений в эстетике «Варшавского Модерна», оформленная в виде настоящего паспорта с гербовыми визами.

### 🛡️ 15 Гербовых штампов:
- **Первые шаги:** Первое добавленное слово, первый скан через камеру, первый диалог с Касей.
- **Словарный запас:** 10, 50, 100 слов в личной колоде.
- **Долгосрочная память:** 10 и 50 слов, переведенных алгоритмом SM-2 в статус усвоенных.
- **Серии дней (Streak):** 3 дня подряд, 7 дней (недельный страйк), 30 дней непрерывных занятий (Легенда).
- **Всесторонность:** Использование всех режимов тренажера.
- **Главный гербовый штамп:** Получение всех 14 печатей — символ уверенной языковой самостоятельности в Польше!

Штампы сопровождаются тактильным вибро-откликом и кнопкой публикации в соцсетях.''',
    routeAction: 'passport',
  ),

  // 5. Месячный Wrapped
  GuideSectionItem(
    id: 'wrapped',
    emoji: '📊',
    titlePl: '5. Raport «Mój polski w miesiąc» (Wrapped)',
    titleUk: '5. Звіт «Мій польський за місяць» (Wrapped)',
    titleRu: '5. Отчет «Мой польский за месяц» (Wrapped)',
    summaryPl: 'Lokalna analityka SQLite, procent poziomu CEFR i miesięczny tytuł.',
    summaryUk: 'Локальна аналітика SQLite, відсоток рівня CEFR та місячний титул.',
    summaryRu: 'Локальная аналитика SQLite, процент уровня CEFR и титул месяца.',
    contentPl: '''### 📈 Wizualne podsumowanie postępów:
Wzorowane na Spotify Wrapped podsumowanie miesiąca, wyliczane w 100% lokalnie w bazie SQLite urządzenia bez wysyłania Twoich danych na zewnętrzne serwery.

### 🔍 Co pokazuje raport:
1. **Liczba nowych słów:** Ile haseł wzbogaciło Twój słownik w danym miesiącu.
2. **Wykonane treningi i dialogi:** Suma odbytych konwersacji z Kasią i ukończonych quizów.
3. **Progres poziomu CEFR:** Szacowany procent opanowania poziomu A1, A2 lub B1.
4. **Miesięczny tytuł:** Unikalna ranga (np. *„Warszawski Strateg”*, *„Krakowski Poliglota”*, *„Mistrz Deklinacji”*).
5. **Karta do udostępnienia:** Estetyczna infografika gotowa do publikacji na Stories lub przesłania znajomym.''',
    contentUk: '''### 📈 Візуальний підсумок місяця:
Аналітичний звіт у стилі Spotify Wrapped, що розраховується на 100% локально у базі SQLite вашого смартфона без передачі персональних даних у мережу.

### 🔍 Що містить звіт:
1. **Кількість вивчених слів:** Скільки нових польських слів додано до пам'яті за місяць.
2. **Пройдені діалоги та тренування:** Загальна кількість проведених розмов та вікторин.
3. **Прогрес за шкалою CEFR:** Оцінка у відсотках закриття рівнів A1, A2 чи B1.
4. **Титул місяця:** Персональне звання (наприклад, *«Варшавський Стратег»*, *«Краківський Поліглот»*, *«Майстер Відмінків»*).
5. **Картка для шерингу:** Красива інфографіка для публікації в соцмережах чи відправки друзям.''',
    contentRu: '''### 📈 Визуальный итог месяца:
Аналитический отчет в стиле Spotify Wrapped, рассчитываемый полностью локально в базе данных SQLite на устройстве без передачи личной информации на сторонние сервера.

### 🔍 Что показывает отчет:
1. **Число новых слов:** Сколько польских слов добавлено в память за месяц.
2. **Пройденные тренировки и диалоги:** Суммарное число бесед и раундов викторин.
3. **Прогресс шкалы CEFR:** Оценка в процентах закрытия ступеней A1, A2 или B1.
4. **Титул месяца:** Персональный ранг (например, *«Варшавский Стратег»*, *«Краковский Полиглот»*, *«Магистр Окончаний»*).
5. **Инфографика для шеринга:** Готовая картинка для сторис и мессенджеров.''',
    routeAction: 'wrapped',
  ),

  // 6. Профессии
  GuideSectionItem(
    id: 'professions',
    emoji: '💼',
    titlePl: '6. Hub «Polski w pracy i zawodzie»',
    titleUk: '6. Хаб «Польська для професій»',
    titleRu: '6. Хаб «Польский для профессий»',
    summaryPl: '5 branż: Logistyka, Budownictwo, Gastronomia, Hotel/Opieka, IT/Biuro.',
    summaryUk: '5 сфер: Логістика, Будівництво, Гастрономія, Готель/Догляд, IT/Офіс.',
    summaryRu: '5 сфер: Логистика, Стройка, Гастрономия, Отель/Клининг, IT/Офис.',
    contentPl: '''### 🏢 Profesjonalne moduły językowe:
Sekcja stworzona z myślą o osobach pracujących lub planujących podjęcie pracy w Polsce. Obejmuje 5 wiodących sektorów:

1. **🚚 Logistyka, Kierowcy i Magazyn:**
   - Listy przewozowe CMR, rampa załadunkowa, wózki widłowe, tachograf, awizacja i kontrole ITD.
2. **🏗️ Budownictwo i Wykończenia:**
   - Instruktaż BHP, rusztowania, szlifierki, gładź, wylewki, odbiór robót i zakupy w hurtowni budowlanej.
3. **👩‍🍳 Gastronomia i Kuchnia:**
   - Wydawka dań, stoliki, kasy fiskalne, alergeny w menu, sanepid, obsługa gości restauracji.
4. **🧹 Serwis Hotelowy, Pokoje i Opieka:**
   - Środki czystości, pościel, odkurzacze przemysłowe, dyżury, leki i opieka nad seniorami.
5. **💻 IT i Praca Biurowa:**
   - Widełki płacowe, umowy B2B, sprinty, daily, zgłaszanie zwolnień L4 i urlopów.

### 🛠️ Możliwości modułu:
- Specjalistyczny słowniczek z transkrypcją i lektorem TTS.
- Przycisk hurtowego dodania całej branży do osobistej talii słownika.
- 15 dedykowanych scenariuszy dialogowych z symulacją rozmów z przełożonym lub współpracownikiem.''',
    contentUk: '''### 🏢 Професійні мовні модулі:
Розділ створений для українців та експатів, які працюють або влаштовуються на роботу в Польщі. Охоплює 5 ключових галузей:

1. **🚚 Логістика, водії та склад:**
   - Накладні CMR, вантажні рампи, вилкові навантажувачі, тахографи, авізація та дорожній контроль інспекції ITD.
2. **🏗️ Будівництво та ремонти:**
   - Інструктажі BHP (техніка безпеки), риштування, болгарки, шпаклівка, стяжки, прийом робіт бригадиром.
3. **👩‍🍳 Гастрономія, ресторан та кухня:**
   - Видача страв, столики, касові чеки, алергени в меню, санепід, спілкування з гостями та кельнерами.
4. **🧹 Готельний сервіс, клінінг та догляд:**
   - Засоби дезінфекції, постіль, графіки прибирання, ліки, тиск та чергування доглядальниці.
5. **💻 IT та офісна робота:**
   - Зарплатні вилки, контракти B2B, планування спринтів, дейлі, оформлення лікарняних L4 та відпусток.

### 🛠️ Що можна робити:
- Вивчати терміни з прикладами та прослуховуванням Google TTS.
- Додавати всі слова професії до особистого словника в один дотик.
- Проходити 15 вузькопрофільних ролевих діалогів з робочими NPC.''',
    contentRu: '''### 🏢 Профессиональные языковые модули:
Раздел разработан специально для экспатов, работающих или устраивающихся на работу в Польше. Охватывает 5 направлений:

1. **🚚 Логистика, водители и склад:**
   - Накладные CMR, погрузочные рампы, вилочные погрузчики, тахограф, авизация и дорожная инспекция ITD.
2. **🏗️ Стройка и отделочные работы:**
   - Инструктаж техники безопасности BHP, строительные леса, шлифмашинки, шпатлевка, стяжка, сдача объекта бригадиру.
3. **👩‍🍳 Гастрономия, рестораны и кухня:**
   - Раздача заказов, чеки, кассы, аллергены в блюдах, санэпид, взаимодействие зала и кухни.
4. **🧹 Отели, клининг и уход за пожилыми:**
   - Профессиональная химия, смена белья, графики смен, приём лекарств, дежурства опекуна.
5. **💻 IT и офисная деятельность:**
   - Вилки зарплат, контракты B2B, спринты, дейли, оформление электронных больничных L4 и отпусков.

### 🛠️ Функционал:
- Словарные базы с реальными рабочими примерами и озвучкой TTS.
- Пакетный импорт всей профессиональной лексики в личный словарь.
- 15 специализированных диалогов с польскими коллегами и начальством.''',
    routeAction: 'professions',
  ),

  // 7. Живые эпизоды (Story Mode)
  GuideSectionItem(
    id: 'episodes',
    emoji: '🎬',
    titlePl: '7. Serial interaktywny «Żywe odcinki»',
    titleUk: '7. Інтерактивний серіал «Живі епізоди»',
    titleRu: '7. Интерактивный сериал «Живые эпизоды»',
    summaryPl: 'Story Mode w 5 odcinkach: Wynajem, Urząd, Bank, Lekarz, Transport.',
    summaryUk: 'Story Mode у 5 серіях: Оренда, Ужонд, Банк, Лікар, Транспорт.',
    summaryRu: 'Story Mode в 5 сериях: Аренда, Ужонд, Банк, Врач, Транспорт.',
    contentPl: '''### 🍿 Prawdziwy serial edukacyjny:
Zamiast pojedynczych suchych ćwiczeń przeżywasz spójną fabularną historię adaptacji w Polsce w Sezonie 1 („Pierwszy miesiąc w Polsce”).

### 🎞️ 5 Kluczowych odcinków:
1. **🏡 Przyjazd i wynajem mieszkania:** Spotkanie z panem Krzysztofem, inspekcja kawalerki, kaucja zwrotna, opłaty za media, protokół zdawczo-odbiorczy.
2. **🏛️ Legalizacja i Urząd:** Terminal z biletami, wniosek o PESEL, zameldowanie czasowe i aktywacja Profilu Zaufanego u pani Barbary.
3. **💳 Bank i finanse:** Otwarcie rachunku ROR, płatności kodem BLIK, analiza paska wynagrodzenia (brutto vs netto, potrącenia ZUS i podatek PIT).
4. **🩺 Zdrowie i przychodnia POZ:** Wizyta u lekarza NFZ, opis objawów, 4-cyfrowy kod e-recepty i zwolnienie lekarskie e-ZLA (L4).
5. **🚆 Podróż i transport miejski:** Zakup biletu w biletomacie, kasowniki w tramwaju, kontrola biletów bez mandatu i perony PKP.

### 🎮 Dwa tryby każdej sceny:
- **Dialog z AI:** Prawdziwa improwizowana rozmowa z postacią odcinka.
- **Symulacja wyboru:** Quiz sytuacyjny z natychmiastowym feedbackiem edukacyjnym.''',
    contentUk: '''### 🍿 Справжній сюжетний серіал:
Замість розрізнених вправ ви проходите цілісну життєву історію першого місяця в Польщі в Сезоні 1.

### 🎞️ 5 Серій першого сезону:
1. **🏡 Приїзд та оренда житла:** Зустріч із власником паном Кшиштофом, огляд квартири, повернення кауції, комунальні лічильники та акт прийому.
2. **🏛️ Легалізація та Ужонд:** Талончики в терміналі, заява на номер PESEL, прописка (мельдунек) та активація Profilu Zaufanego в інспекторки пані Барбари.
3. **💳 Банк та фінанси:** Відкриття рахунку ROR, оплати кодом BLIK, розрахунковий лист зарплати (брутто/нетто, податки PIT та відрахування ZUS).
4. **🩺 Здоров'я та лікар POZ (NFZ):** Реєстрація в поліклініці, симптоми, отримання 4-значного коду e-рецепта та лікарняного e-ZLA (L4).
5. **🚆 Місто та транспорт:** Квиткомати, валідація квитків у трамваї, спокійний прохід контролерів та пошук перону PKP.

### 🎮 Два формати кожної сцени:
- **Живий діалог з ШІ:** Розмова голосом або текстом з польським героєм серії.
- **Сюжетна симуляція:** Квест із вибором оптимальної репліки з поясненням культурних нюансів.''',
    contentRu: '''### 🍿 Настоящий сюжетный сериал:
Вместо изолированных упражнений вы проходите связанную историю адаптации экспата в Польше в Сезоне 1 («Первый месяц в Польше»).

### 🎞️ 5 Серий первого сезона:
1. **🏡 Приезд и аренда жилья:** Встреча с паном Кшиштофом, осмотр квартиры, возвратный залог (kaucja), коммуналка по счетчикам и акт приёмки.
2. **🏛️ Легализация и уженд:** Электронная очередь, получение номера PESEL, временная прописка (meldunek) и подтверждение Profil Zaufany у пани Барбары.
3. **💳 Банк и первая зарплата:** Открытие счета ROR, платежи кодом BLIK, разбор зарплатного листка (brutto vs netto, взносы ZUS и налог PIT).
4. **🩺 Поликлиника и врач POZ (NFZ):** Описание симптомов доктору, получение 4-значного кода e-recepty и электронный больничный лист L4.
5. **🚆 Город и транспорт:** Покупка билетов в автомате, компостирование в трамвае, проверка билетов контролером без штрафа, посадка на поезд PKP.

### 🎮 Два режима прохождения:
- **Диалог с ИИ:** Полноценный разговор с персонажем эпизода голосом или текстом.
- **Симуляция выбора:** Тест-квест на выбор правильной тактичной фразы с мгновенным разбором.''',
    routeAction: 'episodes',
  ),

  // 8. Экзаменационный босс
  GuideSectionItem(
    id: 'exam',
    emoji: '🏆',
    titlePl: '8. «Egzaminacyjny Boss Fight» (Ocena CEFR)',
    titleUk: '8. «Екзаменаційний Boss Fight» (Оцінка CEFR)',
    titleRu: '8. «Экзаменационный Boss Fight» (Оценка CEFR)',
    summaryPl: '5-minutowy egzamin państwowy bez podpowiedzi, 4 kryteria, certyfikat.',
    summaryUk: '5-хвилинний державний іспит без підказок, 4 критерії, сертифікат.',
    summaryRu: '5-минутный строгий экзамен без подсказок, 4 критерия, сертификат.',
    contentPl: '''### 🏛️ Egzamin państwowy w Twoim telefonie:
„Boss Fight” to cotygodniowa symulacja oficjalnego ustnego egzaminu certyfikatowego przed Państwową Komisją Egzaminacyjną.

### ⏱️ Warunki egzaminacyjne:
- **Czas trwania:** Dokładnie 5 minut (licznik czasu na żywo).
- **Zero podpowiedzi:** Brak tłumaczeń i gotowych wskazówek podczas egzaminu — liczy się Twoja autentyczna reakcja!
- **Wybór egzaminatora:** *Prof. Ewa Wiśniewska* lub *Dr Janusz Kowalczyk*.

### 📊 3 Etapy egzaminu:
1. *Autoprezentacja:* Kim jesteś, skąd pochodzisz, Twoje plany i motywacja.
2. *Sytuacja życiowa:* Rozwiązanie niespodziewanego problemu w banku, urzędzie, pracy lub u lekarza.
3. *Opinia i argumentacja:* Wyrażenie zdania na temat życia i adaptacji w Polsce.

### 📜 Certyfikat Biegłości Językowej:
Po zakończeniu egzaminu otrzymujesz oficjalny elektroniczny certyfikat z określeniem poziomu (**A1, A2, B1, B2**) i rozbiciem 100 punktów na 4 kryteria:
- Słownictwo (0-25)
- Poprawność gramatyczna (0-25)
- Płynność i spójność (0-25)
- Reakcja i zrozumienie (0-25)
Zawiera szczegółową opinię egzaminatora z mocnymi stronami i zaleceniami do poprawy.''',
    contentUk: '''### 🏛️ Державний іспит у вашій кишені:
«Boss Fight» — це щотижнева симуляція офіційного усного сертифікаційного іспиту перед Державною екзаменаційною комісією.

### ⏱️ Умови тестування:
- **Тривалість:** Рівно 5 хвилин (таймер зворотного відліку).
- **Жодних підказок:** Під час розмови вимкнено переклади та шаблони — перевіряється ваша справжня мовна реакція!
- **Вибір екзаменатора:** *Проф. Ева Вишнєвська* або *Д-р Януш Ковальчик*.

### 📊 3 Етапи іспиту:
1. *Автопрезентація:* Хто ви, звідки приїхали, ваша робота та плани.
2. *Життєва ситуація:* Вирішення побутової проблеми на вибір екзаменатора.
3. *Думка та аргументація:* Відповідь на проблемне запитання про життя в Польщі.

### 📜 Сертифікат володіння мовою:
Після завершення система генерує детальний електронний сертифікат з визначенням рівня (**A1, A2, B1, B2**) та розбивки 100 балів за 4 критеріями:
- Словниковий запас (0-25)
- Граматична точність (0-25)
- Плинність та зв'язність (0-25)
- Реакція та розуміння запитань (0-25)
Включає висновок екзаменатора та рекомендації для покращення.''',
    contentRu: '''### 🏛️ Государственный экзамен в смартфоне:
«Boss Fight» — это еженедельная симуляция официального устного экзамена перед Государственной экзаменационной комиссией.

### ⏱️ Экзаменационные условия:
- **Время:** Ровно 5 минут (таймер в реальном времени).
- **Без подсказок:** Полное отсутствие подсказок и подглядывания в перевод во время диалога — проверяется ваша реальная готовность!
- **Выбор экзаменатора:** *Проф. Эва Вишневская* или *Д-р Януш Ковальчик*.

### 📊 3 Этапа экзамена:
1. *Самопрезентация:* Кто вы, откуда приехали, ваша профессия и цели в Польше.
2. *Жизненная ситуация:* Быстрое решение практической проблемы на польском.
3. *Мнение и аргументация:* Ответ на открытый вопрос об интеграции и культуре.

### 📜 Сертификат владения языком (CEFR):
В финале формируется официальный электронный сертификат с фиксацией уровня (**A1, A2, B1, B2**) и разбивкой 100 баллов по 4 компетенциям:
- Словарный запас (0-25)
- Грамматическая точность (0-25)
- Беглость и связность (0-25)
- Понимание и реакция (0-25)
Прилагается рецензия экзаменатора с сильными сторонами и советами для практики.''',
    routeAction: 'exam',
  ),

  // 9. Ролевые диалоги
  GuideSectionItem(
    id: 'roleplay',
    emoji: '💬',
    titlePl: '9. Dialogi sytuacyjne z Kasią',
    titleUk: '9. Ситуаційні діалоги з Kasią',
    titleRu: '9. Ситуационные диалоги с Kasią',
    summaryPl: '30 scenariuszy (życie + praca), 4 poziomy trudności, losowe zwroty akcji.',
    summaryUk: '30 сценаріїв (побут + робота), 4 рівні складності, випадкові сюжетні твісти.',
    summaryRu: '30 сценариев (быт + работа), 4 уровня сложности, процедурные сюжетные твисты.',
    contentPl: '''### 🗣️ Swobodny trening mówienia:
Sekcja roleplay pozwala przećwiczyć ponad 30 realistycznych sytuacji z życia w Polsce z interaktywnym tutorem AI.

### 🎭 4 Poziomy trudności:
1. 🟢 **Spokojny:** Życzliwy rozmówca, mówi powoli, cierpliwie czeka i pomaga.
2. 🟡 **Życiowy:** Realistyczna rozmowa z życia codziennego w Polsce.
3. 🔴 **Wyzwanie:** Rozmówca spieszy się, mówi potocznie, wymaga precyzji i stanowczości.
4. 🎲 **Losowy:** Dynamiczny generator nieprzewidywalnych sytuacji i zwrotów akcji (ponad 100 unikalnych twistów fabularnych!).

### 🎤 Funkcje ułatwiające:
- Głosowy mikrofon STT — mów po polsku prosto do telefonu.
- Wbudowana klawiatura diakrytyki (`ą, ć, ę, ł...`).
- Opcjonalne tłumaczenie kwestii rozmówcy i podpowiedzi odpowiedzi na żądanie.''',
    contentUk: '''### 🗣️ Вільне тренування розмовної мови:
Розділ рольових діалогів містить понад 30 життєвих сценаріїв адаптації в Польщі з персональним ШІ-тьютором.

### 🎭 4 Рівні складності:
1. 🟢 **Спокійний:** Співрозмовник доброзичливий, говорить неквапливо і терпляче допомагає.
2. 🟡 **Життєвий:** Звичайний реалістичний діалог у польському магазині чи установі.
3. 🔴 **Виклик:** Співрозмовник поспішає, вживає сленг або вимагає чіткої аргументації.
4. 🎲 **Випадковий:** Процедурний генератор архетипів персонажів та понад 100 несподіваних сюжетних поворотів!

### 🎤 Допоміжні інструменти:
- Голосовий мікрофон STT — промовляйте відповіді вголос.
- Швидка панель діакритики для польських літер.
- Підказки та переклад за бажанням без переривання бесіди.''',
    contentRu: '''### 🗣️ Свободная разговорная практика:
Раздел ролевых диалогов позволяет отрепетировать более 30 реальных жизненных ситуаций в Польше с персональным ИИ-тьютором.

### 🎭 4 Уровня сложности:
1. 🟢 **Спокойный:** Доброжелательный собеседник, говорит размеренно и помогает формулировать мысли.
2. 🟡 **Жизненный:** Стандартный реалистичный диалог в польском банке, магазине или у врача.
3. 🔴 **Вызов:** Собеседник спешит, использует разговорные фразеологизмы, требует четкости.
4. 🎲 **Случайный:** Процедурный генератор неожиданных поворотов сюжета (более 100 уникальных твистов!).

### 🎤 Удобство взаимодействия:
- Голосовой микрофон STT для ответов вслух.
- Быстрая панель ввода польских букв с диакритикой.
- Мгновенные подсказки и подстрочный перевод реплик по клику.''',
    routeAction: 'roleplay',
  ),

  // 10. Переводчик и сканер
  GuideSectionItem(
    id: 'translator',
    emoji: '📷',
    titlePl: '10. Tłumacz i Skaner dokumentów (Pinch-to-zoom)',
    titleUk: '10. Перекладач та Смарт-Сканер (Pinch-to-zoom)',
    titleRu: '10. Переводчик и Смарт-Сканер (Pinch-to-zoom)',
    summaryPl: '4 tryby: Aparat, Dokumenty (PDF/foto), Menu restauracji, Tekst.',
    summaryUk: '4 режими: Камера, Документи (PDF/фото), Меню ресторану, Текст.',
    summaryRu: '4 режима: Камера, Документы (PDF/фото), Меню ресторана, Текст.',
    contentPl: '''### 🔍 Wielofunkcyjny skaner optyczny:
Aplikacja zawiera zaawansowany moduł OCR w estetyce „Warszawskiego Modernizmu” z 4 wyspecjalizowanymi trybami:

1. **📷 Aparat (Na żywo):**
   - Natychmiastowe rozpoznawanie i tłumaczenie szyldów, etykiet, rachunków i cenówek w sklepach.
2. **📄 Dokumenty (PDF i zdjęcia):**
   - Specjalistyczna analiza oficjalnych pism: *Umowa o pracę, Umowa najmu, pisma z ZUS i Urzędu Skarbowego*.
   - Sztuczna inteligencja wyciąga: daty, kwoty, ukryte ryzyka prawne i tworzy zwięzłe podsumowanie.
3. **🍽️ Menu restauracji (Food Explorer):**
   - Rozpoznawanie tradycyjnych dań kuchni polskiej (*żurek, flaki, pierogi, schabowy*).
   - Oznaczenie alergenów, składu i gotowe zwroty z lektorem do zamówienia potrawy u kelnera.
4. **✍️ Wprowadzanie tekstu:**
   - Wklejanie i tłumaczenie dowolnego tekstu z symetrycznymi przyciskami do analizy prawnej i kulinarnej.

### 🔎 Zoom gestem (Pinch-to-zoom):
Możesz powiększać zeskanowane dokumenty dwoma palcami aż do 6.0x lub podwójnym stuknięciem, aby dokładnie przeczytać nawet najdrobniejszy druczek!''',
    contentUk: '''### 🔍 Багатофункціональний оптичний сканер:
Додаток містить потужний OCR-модуль у світлій темі «Варшавського Модерну» з 4 режимами роботи:

1. **📷 Камера (Живий скан):**
   - Миттєве розпізнавання вивісок, цінників, чеків та написів навколо вас.
2. **📄 Документи (PDF та фото з галереї):**
   - Експертний розбір офіційних паперів: *Umowa o pracę, Umowa zlecenie, договір оренди, листи з ZUS та податкової*.
   - ШІ аналізує суми, дати, приховані ризики та надає покроковий план дій українською мовою.
3. **🍽️ Меню ресторанів (Польська кухня):**
   - Розшифровка автентичних страв (*żurek, barszcz biały, flaki, pierogi z mięsem, bigos*).
   - Визначення алергенів, складу та готові фрази з озвучкою для замовлення у офіціанта.
4. **✍️ Введення тексту:**
   - Переклад тексту на повну ширину з кнопками швидкої юридичної та ресторанної експертизи.

### 🔎 Інтерактивний зум (Pinch-to-zoom):
Зображення документа можна вільно масштабувати двома пальцями (до 6.0x) або подвійним тапом, щоб розгледіти найдрібніший шрифт у контрактах!''',
    contentRu: '''### 🔍 Многофункциональный оптический сканер:
Приложение включает интеллектуальный OCR-модуль в светлой теме «Варшавского Модерна» с 4 режимами:

1. **📷 Камера (Съемка в реальном времени):**
   - Мгновенное чтение и перевод вывесок, этикеток, ценников и уличных указателей.
2. **📄 Документы (PDF и фото из галереи):**
   - Экспертный анализ официальных бумаг: *Umowa o pracę, Umowa najmu, письма из ZUS и Urząd Skarbowy*.
   - ИИ вычленяет платежи, сроки, скрытые юридические риски и формирует краткий план действий на русском языке.
3. **🍽️ Ресторанное меню (Польская кухня):**
   - Распознавание традиционных блюд (*журек, фляки, вареники, бигос, плацки*).
   - Выделение аллергенов, состава и готовые фразы с озвучкой для общения с официантом.
4. **✍️ Ввод текста:**
   - Полноразмерная кнопка быстрого перевода и симметричные кнопки анализа договоров и ресторанных карт.

### 🔎 Масштабирование жестом (Pinch-to-zoom):
Скан документа легко приближать двумя пальцами до 6.0x или двойным нажатием, чтобы прочесть даже самый мелкий шрифт в сносках договоров!''',
    routeAction: 'translator',
  ),

  // 11. Словарь и SM-2
  GuideSectionItem(
    id: 'dictionary',
    emoji: '📚',
    titlePl: '11. Słownik i algorytm pamięci SM-2',
    titleUk: '11. Словник та пам\'ять SM-2',
    titleRu: '11. Словарь и память SM-2',
    summaryPl: 'Krzywa zapominania, etapy nauki, eksport do Anki (.apkg/.tsv) i Quizlet.',
    summaryUk: 'Крива забування, ступені вивчення, експорт в Anki (.apkg/.tsv) та Quizlet.',
    summaryRu: 'Кривая забывания, ступени изучения, экспорт в Anki (.apkg/.tsv) и Quizlet.',
    contentPl: '''### 🧠 Zasada działania algorytmu SM-2:
Wszystkie słowa dodawane ze skanera, dialogów, serialu czy modułów zawodowych trafiają do Twojego osobistego słownika. Algorytm interwałowego powtarzania SM-2 dba o to, by słowa przeniosły się do pamięci długotrwałej.

### 📊 Statusy słów:
- 🔵 **Nowe:** Dopiero dodane słowo.
- 🟡 **W trakcie nauki:** Słowo powtarzane w interwałach (1 dzień → 6 dni → 14 dni itd.).
- 🟢 **Opanowane:** Słowo utrwalone w pamięci trwałej (odblokowuje pieczęcie w paszporcie!).

### 📤 Eksport do Anki i Quizlet:
Możesz jednym kliknięciem wyeksportować cały swój słownik:
- **Anki (.tsv / .apkg):** Z pełnymi polskimi przykładami, częściami mowy i tagami.
- **Quizlet (.csv):** Gotowy format do importu do popularnych fiszek.
- **Excel (.csv):** Pełny zrzut bazy z datami i interwałami.''',
    contentUk: '''### 🧠 Принцип інтервального повторення SM-2:
Кожне слово, збережене зі сканера, серіалу чи професійного хабу, потрапляє до вашого словника. Науковий алгоритм SuperMemo SM-2 автоматично розраховує точний день наступного повторення, запобігаючи забуванню.

### 📊 Статуси слів у словнику:
- 🔵 **Нові:** Тільки додані слова, що очікують першої перевірки.
- 🟡 **Вивчаються:** Слова на інтервальних циклах (1 день → 6 днів → 14 днів і далі).
- 🟢 **Засвоєні:** Слова, які перейшли в довготривалу пам'ять (за ними нараховуються досягнення в паспорті!).

### 📤 Експорт в Anki, Quizlet та Excel:
Словник можна в будь-який момент експортувати:
- **Anki (.tsv):** Формат з HTML-виділенням прикладів та категорійними тегами.
- **Quizlet (.csv):** Сумісний файл для імпорту в мобільні картки.
- **Таблиця Excel (.csv):** Повна вибірка з усіма відмінюваннями та інтервалами.''',
    contentRu: '''### 🧠 Принцип интервального повторения SM-2:
Каждое слово из сканера, онбординга, диалогов или сериала отправляется в вашу личную память. Алгоритм SuperMemo SM-2 рассчитывает оптимальные дни повторений, побеждая кривую забывания Эббингауза.

### 📊 Стадии запоминания слова:
- 🔵 **Новые:** Недавно добавленные карточки.
- 🟡 **На изучении:** Слова в цикле возрастающих интервалов (1 день → 6 дней → 14 дней и т.д.).
- 🟢 **Освоенные:** Слова, надежно закрепленные в долгосрочной памяти (открывают гербовые штампы паспорта!).

### 📤 Экспорт колоды в Anki и Quizlet:
Всю накопленную базу можно выгрузить в одно нажатие:
- **Anki (.tsv):** С контекстными примерами, частями речи и метками.
- **Quizlet (.csv):** Стандартный формат для тренировки карточек.
- **Excel (.csv):** Полная таблица со всеми датами и интервалами повторений.''',
    routeAction: 'dictionary',
  ),

  // 12. Настройки и ИИ-шлюз
  GuideSectionItem(
    id: 'settings',
    emoji: '⚙️',
    titlePl: '12. Ustawienia, Brama AI i Aktualizacje',
    titleUk: '12. Налаштування, Шлюз ШІ та Оновлення',
    titleRu: '12. Настройки, ИИ-Шлюз и Обновления',
    summaryPl: 'Konfiguracja OmniRoute/Gemini, test połączenia, sprawdzanie wydań GitHub.',
    summaryUk: 'Налаштування OmniRoute/Gemini, тест зв\'язку, перевірка релізів GitHub.',
    summaryRu: 'Настройка OmniRoute/Gemini, тест связи, проверка релизов GitHub.',
    contentPl: '''### 🤖 Brama sztucznej inteligencji:
Aplikacja korzysta z bezpiecznej bramy OpenAI-compatible (OmniRoute / CLIProxyAPI) opartej o model Gemini:
- **Base URL:** Adres Twojej bramy proxy.
- **Klucz API:** Bezpieczny klucz dostępu (przechowywany wyłącznie lokalnie w pamięci urządzenia).
- **Przycisk «Testuj połączenie»:** Sprawdza, czy sztuczna inteligencja odpowiada poprawnie w ułamku sekundy.

### 🔄 Automatyczne aktualizacje:
Przycisk **„Sprawdź aktualizacje”** łączy się bezpośrednio z oficjalnym repozytorium GitHub i informuje o pojawieniu się nowego wydania APK z możliwością pobrania w 1 kliknięcie.''',
    contentUk: '''### 🤖 Шлюз штучного інтелекту:
Додаток працює через швидкий OpenAI-сумісний шлюз (OmniRoute / CLIProxyAPI) на базі моделі Gemini:
- **Base URL:** Адреса вашого проксі-шлюзу.
- **Ключ API:** Персональний ключ доступу (зберігається виключно на вашому пристрої).
- **Кнопка «Перевірити зв'язок»:** Робить тестовий пінг до ШІ та підтверджує готовність системи.

### 🔄 Оновлення версії:
Кнопка **«Перевірити оновлення»** звертається до офіційних релізів на GitHub і дозволяє завантажити найновіший файл APK в один клік.''',
    contentRu: '''### 🤖 Шлюз искусственного интеллекта:
Приложение взаимодействует с надежным OpenAI-совместимым шлюзом (OmniRoute / CLIProxyAPI) на базе модели Gemini:
- **Base URL:** Адрес вашего прокси-сервера.
- **Ключ API:** Личный ключ доступа (хранится строго локально в зашифрованных настройках).
- **Кнопка «Проверить связь»:** Выполняет контрольный запрос к ИИ и подтверждает статус соединения.

### 🔄 Обновление приложения:
Кнопка **«Проверить обновления»** напрямую связывается с официальным репозиторием GitHub Releases и сообщает о выходе новой версии APK.''',
    routeAction: 'settings',
  ),
];
