import 'dart:math';

import '../scanner/translation_service.dart' show UiLang;

enum DialogInitiator {
  userFirst,
  npcFirst,
}

enum RoleplayDifficulty {
  calm,
  life,
  challenge,
  random,
}

class RoleplayDynamicSeed {
  final RoleplayDifficulty effectiveDifficulty;
  final String twist;
  final String npcPersonality;

  const RoleplayDynamicSeed({
    required this.effectiveDifficulty,
    required this.twist,
    required this.npcPersonality,
  });
}

class SubScenario {
  const SubScenario({
    required this.id,
    required this.titleUk,
    required this.titleRu,
    required this.titlePl,
    required this.descUk,
    required this.descRu,
    required this.descPl,
    required this.starterHintPl,
    required this.starterHintUk,
    required this.starterHintRu,
    required this.plotTwist,
    this.vocab = const [],
    this.npcRole,
    this.setting,
    this.npcFirstStarterPl,
    this.npcFirstStarterUk,
    this.npcFirstStarterRu,
    this.npcFirstInstruction,
    this.calmVariations = const [],
    this.lifeVariations = const [],
    this.challengeVariations = const [],
    this.npcPersonalities = const [],
  });

  final String id;
  final String titleUk;
  final String titleRu;
  final String titlePl;
  final String descUk;
  final String descRu;
  final String descPl;
  final String starterHintPl;
  final String starterHintUk;
  final String starterHintRu;
  final String plotTwist;
  final List<String> vocab;
  final String? npcRole;
  final String? setting;
  final String? npcFirstStarterPl;
  final String? npcFirstStarterUk;
  final String? npcFirstStarterRu;
  final String? npcFirstInstruction;
  final List<String> calmVariations;
  final List<String> lifeVariations;
  final List<String> challengeVariations;
  final List<String> npcPersonalities;

  RoleplayDynamicSeed resolveDynamicSeed(RoleplayDifficulty chosenDifficulty) {
    final random = Random();
    RoleplayDifficulty effective = chosenDifficulty;
    if (chosenDifficulty == RoleplayDifficulty.random) {
      final pool = [RoleplayDifficulty.calm, RoleplayDifficulty.life, RoleplayDifficulty.challenge];
      effective = pool[random.nextInt(pool.length)];
    }

    List<String> twists;
    switch (effective) {
      case RoleplayDifficulty.calm:
        twists = calmVariations.isNotEmpty ? calmVariations : [plotTwist];
        break;
      case RoleplayDifficulty.challenge:
        twists = challengeVariations.isNotEmpty ? challengeVariations : [plotTwist];
        break;
      case RoleplayDifficulty.life:
      case RoleplayDifficulty.random:
        twists = lifeVariations.isNotEmpty ? lifeVariations : [plotTwist];
        break;
    }

    final chosenTwist = twists[random.nextInt(twists.length)];

    final personalities = npcPersonalities.isNotEmpty
        ? npcPersonalities
        : [
            'Uprzejmy i pomocny rozmówca, mówiący naturalnym, żywym językiem.',
            'Zajęty i pośpieszny pracownik, mówiący zwięźle i bezpośrednio.',
            'Bardzo dokładny i przestrzegający procedur pracownik.'
          ];
    final chosenPersonality = personalities[random.nextInt(personalities.length)];

    return RoleplayDynamicSeed(
      effectiveDifficulty: effective,
      twist: chosenTwist,
      npcPersonality: chosenPersonality,
    );
  }

  String title(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return titleUk;
      case UiLang.pl:
        return titlePl;
      case UiLang.ru:
        return titleRu;
    }
  }

  String description(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return descUk;
      case UiLang.pl:
        return descPl;
      case UiLang.ru:
        return descRu;
    }
  }

  String starterHint(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return starterHintUk;
      case UiLang.pl:
        return starterHintPl;
      case UiLang.ru:
        return starterHintRu;
    }
  }

  String npcFirstStarter(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return npcFirstStarterUk ?? npcFirstStarterPl ?? '';
      case UiLang.pl:
        return npcFirstStarterPl ?? '';
      case UiLang.ru:
        return npcFirstStarterRu ?? npcFirstStarterPl ?? '';
    }
  }

  // Обратная совместимость с вызовами .title и .description
  String get titleRuCompat => titleRu;
  String get descriptionRuCompat => descRu;
}

class Scenario {
  const Scenario({
    required this.key,
    required this.emoji,
    required this.titleUk,
    required this.titleRu,
    required this.titlePl,
    required this.level,
    required this.npcRole,
    required this.setting,
    required this.vocab,
    this.subScenarios = const [],
  });

  final String key;
  final String emoji;
  final String titleUk;
  final String titleRu;
  final String titlePl;
  final String level;

  /// Кого играет ИИ (по-польски — для системного промпта).
  final String npcRole;

  /// Описание ситуации для ИИ.
  final String setting;

  /// Ключевая лексика сцены (показывается в шапке).
  final List<String> vocab;

  /// Список детализированных под-сценариев.
  final List<SubScenario> subScenarios;

  String title(UiLang lang) {
    switch (lang) {
      case UiLang.uk:
        return titleUk;
      case UiLang.pl:
        return titlePl;
      case UiLang.ru:
        return titleRu;
    }
  }

  // Обратная совместимость
  String get titleRuCompat => titleRu;
}

const scenarios = <Scenario>[
  Scenario(
    key: 'zabka',
    emoji: '🛒',
    titleRu: 'В магазине Żabka / Biedronka',
    titleUk: 'У магазині Żabka / Biedronka',
    titlePl: 'W sklepie Żabka / Biedronka',
    level: 'A1',
    npcRole: 'pracownik sklepu spożywczego Żabka lub Biedronka',
    setting:
        'Rozmowa z pracownikiem w polskim sklepie spożywczym (Żabka / Biedronka). '
        'W zależności od wybranej sytuacji pracownik obsługuje klienta na kasie, pomaga znaleźć towar na sali lub przyjmuje reklamację.',
    vocab: ['gdzie znajdę', 'w promocji', 'ile płacę', 'karta czy BLIK', 'paragon fiskalny', 'reszta'],
    subScenarios: [
      SubScenario(
        id: 'zabka_checkout',
        titleRu: 'На кассе (Żappka, пакет, BLIK)',
        titleUk: 'На касі (Żappka, пакет, BLIK)',
        titlePl: 'Na kasie (Żappka, reklamówka, BLIK)',
        descRu: 'Сканирование покупок, приложение Żappka, вопрос про пакет и оплата BLIK или картой.',
        descUk: 'Сканування покупок, застосунок Żappka, питання про пакет та оплата BLIK або карткою.',
        descPl: 'Skanowanie zakupów, aplikacja Żappka, pytanie o torbę oraz płatność BLIKiem lub kartą.',
        starterHintPl: 'Dzień dobry, mam aplikację Żappka i płacę BLIKiem.',
        starterHintUk: 'Добрий день, у мене є додаток Żappka і я плачу BLIKом.',
        starterHintRu: 'Добрый день, у меня приложение Żappka и я плачу BLIKом.',
        plotTwist: 'Terminal zbliżeniowy chwilowo odrzucił kartę, kasjer uprzejmie prosi o kod BLIK lub gotówkę.',
        vocab: ['Żappka', 'kod BLIK', 'reklamówka', 'paragon fiskalny', 'zbliżeniowo'],
        npcRole: 'kasjer na kasie w sklepie Żabka',
        setting:
            'Klient podszedł do kasy z zakupami. Skanujesz artykuły, pytasz o aplikację Żappka i torbę/reklamówkę. '
            'OBOWIĄZKOWO podajesz realistyczną sumę do zapłaty SŁOWAMI (np. „Do zapłaty dwadzieścia cztery złote i pięćdziesiąt groszy”). '
            'Pytasz: „Płatność kartą, gotówką czy BLIKiem?”, wydajesz resztę i pytasz czy wydać paragon fiskalny.',
        npcFirstStarterPl: 'Dzień dobry! Czy ma pan aplikację Żappka i czy doliczyć torbę do zakupów?',
        npcFirstStarterUk: 'Добрий день! Чи є у вас додаток Żappka і чи додавати торбинку до покупок?',
        npcFirstStarterRu: 'Добрый день! Есть ли у вас приложение Żappka и добавлять ли пакет к покупкам?',
        npcFirstInstruction:
            'Zacznij scenę jako kasjer przy kasie w Żabce. Zeskanowałeś zakupy klienta. Przywitaj się uprzejmie i zapytaj, czy klient ma aplikację Żappka oraz czy doliczyć reklamówkę.',
        calmVariations: [
          'Standardowe, spokojne skanowanie zakupów, kasjer pyta o Żappkę, torbę i proponuje paragon.',
          'Klient kupuje kawę i drożdżówkę, kasjer z uśmiechem proponuje promocyjny zestaw śniadaniowy.',
        ],
        lifeVariations: [
          'Terminal zbliżeniowy chwilowo odrzucił kartę, kasjer uprzejmie prosi o kod BLIK lub gotówkę.',
          'Aplikacja Żappka nie chce się załadować przez brak zasięgu, kasjer proponuje podanie numeru telefonu.',
          'W drukarce fiskalnej skończył się papier na paragon, kasjer szybko wymienia rolkę i przeprasza za chwilkę zwłoki.',
        ],
        challengeVariations: [
          'Za klientem rośnie długa kolejka zniecierpliwionych osób, kasjer spieszy się i prosi o szybką decyzję o płatności.',
          'Na kasie nabiła się wyższa cena niż na półce, klient to zauważa i kasjer musi wezwać kierownika do anulowania pozycji.',
          'Klient płaci banknotem 200 zł za zakupy za 8 zł, kasjer nie ma wydać reszty i nalega na BLIK lub kartę.',
        ],
        npcPersonalities: [
          'Uprzejmy, uśmiechnięty kasjer, który chętnie poleca promocje i żartuje.',
          'Młody, szybki pracownik w biegu, mówiący zwięźle, bo kolejka rośnie.',
          'Starsza, bardzo dokładna kasjerka, która skrupulatnie przelicza każdy grosz.',
        ],
      ),
      SubScenario(
        id: 'zabka_finding',
        titleRu: 'Поиск товара и срок годности',
        titleUk: 'Пошук товару та термін придатності',
        titlePl: 'Szukanie produktu i termin ważności',
        descRu: 'Поиск свежей выпечки или безлактозного молока на полках и проверка акционной цены.',
        descUk: 'Пошук свіжої випічки чи безлактозного молока на полицях та перевірка акційної ціни.',
        descPl: 'Szukanie świeżego pieczywa lub mleka bez laktozy na półkach i sprawdzenie ceny promocyjnej.',
        starterHintPl: 'Przepraszam, gdzie znajdę świeże pieczywo i mleko bez laktozy?',
        starterHintUk: 'Перепрошую, де знайти свіжу випічку та безлактозне молоко?',
        starterHintRu: 'Извините, где найти свежую выпечку и безлактозное молоко?',
        plotTwist: 'Zwykłe mleko się skończyło, jest tylko roślinne owsiane albo dostawa przyjedzie za pół godziny.',
        vocab: ['bez laktozy', 'gdzie znajdę', 'termin ważności', 'gazetka promocyjna'],
        npcRole: 'pracownik na sali sprzedaży sklepu Żabka / Biedronka',
        setting:
            'Klient chodzi po sklepie i szuka konkretnego artykułu (świeżego pieczywa, mleka bez laktozy, jajek lub promocji z gazetki). '
            'Pracownik uprzejmie pomaga, wskazuje właściwą alejkę lub półkę, sprawdza datę ważności lub stan na zapleczu sklepu.',
        npcFirstStarterPl: 'Dzień dobry! Szuka pan konkretnego produktu na półkach? W czym mogę pomóc?',
        npcFirstStarterUk: 'Добрий день! Шукаєте конкретний продукт на полицях? Чим можу допомогти?',
        npcFirstStarterRu: 'Добрый день! Ищете конкретный товар на полках? Чем могу помочь?',
        npcFirstInstruction:
            'Zacznij scenę jako pracownik na sali sprzedaży sklepu. Widzisz, że klient rozgląda się niepewnie po regałach. Przywitaj się uprzejmie i zapytaj, jakiego produktu szuka.',
        calmVariations: [
          'Pracownik od razu prowadzi klienta do lodówki z mlekiem bez laktozy i pokazuje świeżą dostawę.',
          'Klient szuka ciepłych bułek, pracownik z dumą wskazuje piec i mówi, że wyjęto je 5 minut temu.',
        ],
        lifeVariations: [
          'Zwykłe mleko się skończyło, jest tylko roślinne owsiane albo dostawa przyjedzie za pół godziny.',
          'Cena z gazetki nie została zmieniona na półce, pracownik sprawdza kod na skanerze mobilnym.',
          'Wybrany produkt ma termin ważności do dzisiaj, pracownik pomaga znaleźć opakowanie z dłuższą datą.',
        ],
        challengeVariations: [
          'Szukany produkt został całkowicie wycofany ze sprzedaży w tej sieci, pracownik proponuje zamiennik i tłumaczy różnicę.',
          'Alejka jest zablokowana paletami z dostawą, pracownik prosi o ostrożność i sam idzie szukać towaru na zapleczu.',
          'W sklepie jest awaria chłodziarek, pracownik ostrzega, że niektóre nabiały zostały tymczasowo zabezpieczone.',
        ],
        npcPersonalities: [
          'Pomocny, energiczny pracownik, który chętnie oprowadza klienta po alejkach.',
          'Lekko zmęczony pracownik rozładowujący palety, mówiący krótko, ale konkretnie.',
          'Bardzo sumienny doradca, dbający o świeżość i zadowolenie klienta.',
        ],
      ),
      SubScenario(
        id: 'zabka_refund',
        titleRu: 'Возврат или рекламация',
        titleUk: 'Повернення або рекламація',
        titlePl: 'Zwrot lub reklamacja',
        descRu: 'Товар оказался поврежденным или в чеке пробита неверная цена без скидки.',
        descUk: 'Товар виявився пошкодженим або в чеку пробита невірна ціна без знижки.',
        descPl: 'Produkt okazał się uszkodzony lub na paragonie naliczono błędną cenę bez rabatu.',
        starterHintPl: 'Dzień dobry, na paragonie nabiła się inna cena niż na półce. Chciałbym złożyć reklamację i otrzymać zwrot różnicy.',
        starterHintUk: 'Добрий день, у чеку вибило іншу ціну, ніж на полиці. Хотів би подати рекламацію і повернути різницю.',
        starterHintRu: 'Добрый день, в чеке пробилась другая цена, чем на полке. Хотел бы подать рекламацию и вернуть разницу.',
        plotTwist: 'Kasjer prosi o pokazanie paragonu z zakupu i potwierdza błąd promocyjny, oferując zwrot różnicy w gotówce.',
        vocab: ['reklamacja', 'błędna cena', 'paragon fiskalny', 'korekta', 'zwrot różnicy'],
        npcRole: 'kasjer i kierownik zmiany w Żabce rozpatrujący reklamację lub zwrot',
        setting:
            'Klient podchodzi do kasy z zakupionym artykułem i paragonem w celu zwrotu lub reklamacji (błędna cena nabita na kasie bez rabatu lub uszkodzony towar). '
            'Nie jest to rutynowe kasowanie zakupów! Pracownik uprzejmie prosi o okazanie paragonu („Czy ma pan paragon fiskalny?”), weryfikuje pozycję, przeprasza za pomyłkę w systemie i dokonuje korekty lub zwrotu różnicy w gotówce.',
        npcFirstStarterPl: 'Dzień dobry! Widzę, że podchodzi pan z towarem i paragonem. W czym mogę pomóc, chodzi o reklamację czy zwrot towaru?',
        npcFirstStarterUk: 'Добрий день! Бачу, ви підходите з товаром і чеком. Чим можу допомогти, йдеться про рекламацію чи повернення?',
        npcFirstStarterRu: 'Добрый день! Вижу, вы подходите с товаром и чеком. Чем могу помочь, речь идет о рекламации или возврате товара?',
        npcFirstInstruction:
            'Zacznij scenę jako kasjer/kierownik w Żabce. Klient podszedł do kasy z towarem i paragonem w ręku. Przywitaj się uprzejmie i zapytaj, w jakiej sprawie podchodzi: czy chodzi o reklamację złej ceny czy zwrot wadliwego towaru.',
        calmVariations: [
          'Kasjer natychmiast sprawdza paragon, potwierdza błąd rabatu wielosztuki i bez słowa zwraca różnicę w gotówce.',
          'Klient zwraca nienaruszony produkt kupiony przed chwilą, kasjer wymienia go na inny bez żadnych przeszkód.',
        ],
        lifeVariations: [
          'Kasjer prosi o pokazanie paragonu, sprawdza godzinę i wyjaśnia, że promocja wymagała zeskanowania Żappki, ale koryguje kwotę.',
          'Opakowanie jogurtu okazało się pęknięte pod folią, kasjer przeprasza, wymienia produkt i oferuje kupon rabatowy.',
          'Paragon jest lekko zamazany, kasjer musi ręcznie wbić 14-cyfrowy kod wydruku do systemu.',
        ],
        challengeVariations: [
          'Klient nie ma papierowego paragonu, a jedynie potwierdzenie transakcji BLIK w aplikacji; kasjer wzywa kierownika do autoryzacji.',
          'Towar został kupiony w innej Żabce na drugim końcu miasta; kasjer tłumaczy zasady franczyzy, ale szuka kompromisu.',
          'Produkt spożywczy został już w domu otwarty i klient poczuł zepsuty zapach; kasjer początkowo powołuje się na brak zwrotu otwartych artykułów, ale sporządza protokół reklamacji jakościowej.',
        ],
        npcPersonalities: [
          'Kierownik zmiany nastawiony na ugodę i szybkie zadowolenie klienta.',
          'Służbista trzymający się ściśle regulaminu i sprawdzający każdą rubrykę.',
          'Dociekliwy sprzedawca, dokładnie oglądający opakowanie i dopytujący o szczegóły zakupu.',
        ],
      ),
    ],
  ),
  Scenario(
    key: 'bank',
    emoji: '🏦',
    titleRu: 'В банке PKO / IKO (открытие счёта)',
    titleUk: 'У банку PKO / IKO (відкриття рахунку)',
    titlePl: 'W banku PKO / IKO (otwarcie konta)',
    level: 'A2',
    npcRole: 'doradca klienta w oddziale PKO Bank Polski',
    setting:
        'Obsługa klienta w oddziale banku w Polsce (PKO Bank Polski). '
        'W zależności od wybranej sytuacji doradca otwiera nowe konto, pomaga przy zablokowanej karcie w bankomacie lub wydaje urzędowe zaświadczenie z pieczęcią.',
    vocab: [
      'otworzyć konto',
      'karta debetowa',
      'aplikacja IKO',
      'kod BLIK',
      'numer PESEL',
      'wypłata z bankomatu'
    ],
    subScenarios: [
      SubScenario(
        id: 'bank_open_account',
        titleRu: 'Открытие счета и приложение IKO',
        titleUk: 'Відкриття рахунку та додаток IKO',
        titlePl: 'Otwarcie konta i aplikacja IKO',
        descRu: 'Оформление PKO Konto za Zero, получение карты и регистрация приложения IKO с BLIK.',
        descUk: 'Оформлення PKO Konto za Zero, отримання картки та реєстрація додатку IKO з кодом BLIK.',
        descPl: 'Otwarcie PKO Konta za Zero, wydanie karty oraz aktywacja aplikacji IKO z BLIKiem.',
        starterHintPl: 'Dzień dobry, chciałbym założyć konto osobiste i aktywować aplikację IKO.',
        starterHintUk: 'Добрий день, я хотів би відкрити особистий рахунок та активувати додаток IKO.',
        starterHintRu: 'Добрый день, я хотел бы открыть расчетный счет и активировать приложение IKO.',
        plotTwist: 'Doradca bankowy pyta o meldunek oraz prosi o podanie polskiego numeru telefonu do autoryzacji SMS.',
        vocab: ['PKO Konto za Zero', 'karta debetowa', 'aplikacja IKO', 'numer PESEL', 'autoryzacja SMS'],
        npcRole: 'doradca klienta w oddziale PKO Bank Polski',
        setting:
            'Klient przychodzi do oddziału PKO BP założyć pierwsze konto osobiste w Polsce. '
            'Doradca wita serdecznie klienta, zaprasza do biurka, pyta o paszport, numer PESEL i polski numer telefonu. '
            'Proponuje PKO Konto za Zero, darmową kartę wielowalutową i pomaga aktywować aplikację IKO z płatnościami BLIK.',
        npcFirstStarterPl: 'Dzień dobry, zapraszam do stanowiska. W czym mogę pomóc, chciałby pan założyć konto osobiste?',
        npcFirstStarterUk: 'Добрий день, запрошую до робочого місця. Чим можу допомогти, хотіли б відкрити особистий рахунок?',
        npcFirstStarterRu: 'Добрый день, приглашаю к столу. Чем могу помочь, хотели бы открыть личный расчетный счет?',
        npcFirstInstruction:
            'Zacznij scenę jako doradca w oddziale banku PKO BP. Zaproś klienta do biurka, przywitaj się i zapytaj, czy przyszedł otworzyć nowe konto osobiste.',
        calmVariations: [
          'Standardowa procedura: weryfikacja paszportu i PESEL, wybór darmowego konta za zero i konfiguracja IKO.',
          'Klient potrzebuje konta walutowego EUR do pensji, doradca włącza darmowe subkonto i kantor walutowy.',
        ],
        lifeVariations: [
          'Doradca pyta o meldunek oraz prosi o podanie polskiego numeru telefonu do autoryzacji kodów SMS.',
          'Klient nie posiada jeszcze numeru PESEL, doradca zakłada konto na identyfikator tymczasowy TIN na podstawie paszportu.',
          'Fizyczna karta przyjdzie pocztą za 5 dni, ale doradca od razu generuje kartę wirtualną do telefonu.',
        ],
        challengeVariations: [
          'Adres zamieszkania w oświadczeniu podatkowym FATCA nie pokrywa się z umową najmu, doradca prosi o dodatkowy dokument.',
          'System bankowy chwilowo ma problem z weryfikacją paszportu w bazie centralnej, doradca musi dzwonić do centrali weryfikacyjnej.',
          'Klient pyta o możliwość uzyskania debetu lub karty kredytowej, doradca zadaje szczegółowe pytania o typ umowy o pracę i dochody.',
        ],
        npcPersonalities: [
          'Życzliwy doradca, cierpliwie tłumaczący krok po kroku każdą opcję w aplikacji.',
          'Rzeczowy bankowiec operujący profesjonalnym językiem finansowym.',
          'Skrupulatna urzędniczka bankowa dbająca o zgodność każdego podpisu z procedurą KYC.',
        ],
      ),
      SubScenario(
        id: 'bank_atm_blocked',
        titleRu: 'Банкомат заблокировал карту',
        titleUk: 'Банкомат заблокував картку',
        titlePl: 'Bankomat zablokował kartę',
        descRu: 'Банкомат не вернул карту или транзакция заблокирована службой безопасности банка.',
        descUk: 'Банкомат не повернув картку або транзакцію заблоковано системою безпеки банку.',
        descPl: 'Bankomat zatrzymał kartę lub transakcja została zablokowana przez bezpieczeństwo banku.',
        starterHintPl: 'Dzień dobry, przed chwilą bankomat przy wejściu wciągnął moją kartę i jej nie oddał!',
        starterHintUk: 'Добрий день, щойно банкомат біля входу затягнув мою картку і не віддав її!',
        starterHintRu: 'Добрый день, только что банкомат у входа затянул мою карту и не отдал её!',
        plotTwist: 'Karta została zatrzymana ze względów bezpieczeństwa, doradca od ręki blokuje starą i generuje wirtualną w aplikacji IKO.',
        vocab: ['zablokowana karta', 'zatrzymana w bankomacie', 'karta wirtualna', 'zgłoszenie incydentu'],
        npcRole: 'pracownik obsługi klienta i bezpieczeństwa w oddziale banku PKO',
        setting:
            'Klient wchodzi zaniepokojony do oddziału, bo bankomat przed wejściem zatrzymał jego kartę debetową. '
            'Doradca uspokaja klienta, prosi o dokument tożsamości (paszport/PESEL), sprawdza powód zatrzymania, natychmiast blokuje fizyczny plastik dla bezpieczeństwa i pomaga włączyć kartę wirtualną w telefonie lub dokonać natychmiastowej wypłaty BLIKiem.',
        npcFirstStarterPl: 'Dzień dobry! Widzę, że wchodzi pan zaniepokojony od strony bankomatu. Co się stało z kartą?',
        npcFirstStarterUk: 'Добрий день! Бачу, ви заходите стурбований з боку банкомату. Що сталося з карткою?',
        npcFirstStarterRu: 'Добрый день! Вижу, вы заходите обеспокоенный со стороны банкомата. Что случилось с картой?',
        npcFirstInstruction:
            'Zacznij scenę jako doradca bankowy. Klient podszedł pospiesznie od bankomatu. Przywitaj się i zapytaj, co stało się z kartą lub bankomatem.',
        calmVariations: [
          'Doradca od ręki unieważnia starą kartę, włącza kartę wirtualną w IKO i wypłaca potrzebną gotówkę w kasie z paszportu.',
          'Karta została zablokowana przez 3 błędne kody PIN, doradca pomaga zresetować PIN w aplikacji.',
        ],
        lifeVariations: [
          'Karta została wciągnięta z powodu przekroczenia limitu czasu (30 sekund), doradca zamawia darmowy duplikat pocztą.',
          'Bankomat należy do innej sieci (Euronet), doradca przyjmuje zgłoszenie awarii i instruuje jak wypłacać BLIKiem bez opłat.',
          'Klient potrzebuje pilnie zrobić zakupy, doradca uczy go generowania 6-cyfrowego kodu BLIK bez użycia plastiku.',
        ],
        challengeVariations: [
          'Karta została zatrzymana przez system bezpieczeństwa po podejrzanej próbie wypłaty za granicą; doradca weryfikuje historię transakcji pytaniami kontrolnymi.',
          'Klient zapomniał paszportu i ma tylko zdjęcie w telefonie; doradca tłumaczy rygorystyczne przepisy prawa bankowego i proponuje autoryzację przez aplikację IKO.',
          'Bankomat nie wydał 1000 zł, ale konto zostało obciążone; doradca sporządza oficjalną reklamację bankomatową.',
        ],
        npcPersonalities: [
          'Empatyczny doradca, który potrafi uspokoić klienta i szybko znajduje alternatywne rozwiązanie.',
          'Ściśle procedurowy pracownik działu bezpieczeństwa bankowego.',
          'Spokojny specjalista bankowości mobilnej uczący nowoczesnych funkcji IKO.',
        ],
      ),
      SubScenario(
        id: 'bank_statement_urzad',
        titleRu: 'Выписка с печатью для Urząd (Карта Побыту)',
        titleUk: 'Виписка з печаткою для Urząd (Карта Побиту)',
        titlePl: 'Wyciąg z pieczęcią do Urzędu (Karta Pobytu)',
        descRu: 'Получение официальной выписки о балансе и движении средств с мокрой печатью для воеводства.',
        descUk: 'Отримання офіційної виписки про стан рахунку та рух коштів з мокрою печаткою для відділу іноземців.',
        descPl: 'Uzyskanie oficjalnego zaświadczenia o saldzie i historii z pieczęcią dla urzędu wojewódzkiego.',
        starterHintPl: 'Dzień dobry, potrzebuję oficjalne zaświadczenie o stanie konta z pieczęcią banku do karty pobytu w urzędzie wojewódzkim.',
        starterHintUk: 'Добрий день, мені потрібна офіційна виписка з рахунку з печаткою банку для карти побиту в ужонді.',
        starterHintRu: 'Добрый день, мне нужна официальная выписка со счета с печатью банка для карты побыту в уженде.',
        plotTwist: 'Zwykły wydruk z bankowości internetowej nie wystarczy, urzędnik generuje papierowe zaświadczenie z pieczęcią z opłatą manipulacyjną.',
        vocab: ['wyciąg z konta', 'zaświadczenie o saldzie', 'pieczęć bankowa', 'karta pobytu', 'opłata manipulacyjna'],
        npcRole: 'doradca bankowy wystawiający oficjalne zaświadczenia',
        setting:
            'Klient potrzebuje urzędowego zaświadczenia o saldzie i historii operacji na koncie z fizyczną „mokrą” pieczęcią i podpisem do Urzędu Wojewódzkiego na kartę pobytu. '
            'Doradca weryfikuje dowód tożsamości, ustala okres wyciągu (np. 3 lub 6 miesięcy), informuje o opłacie manipulacyjnej, drukuje zaświadczenie z pieczątką i podpisem.',
        npcFirstStarterPl: 'Dzień dobry! W czym mogę dziś pomóc? Potrzebuje pan zaświadczenia z pieczęcią czy wyciągu z konta?',
        npcFirstStarterUk: 'Добрий день! Чим можу сьогодні допомогти? Потрібна довідка з печаткою чи виписка з рахунку?',
        npcFirstStarterRu: 'Добрый день! Чем могу сегодня помочь? Вам нужна справка с печатью или выписка со счета?',
        npcFirstInstruction:
            'Zacznij scenę jako doradca w banku. Przywitaj klienta serdecznie i zapytaj, jakiego zaświadczenia urzędowego lub wyciągu z pieczęcią banku potrzebuje.',
        calmVariations: [
          'Doradca od ręki generuje zaświadczenie o saldzie za ostatnie 3 miesiące z pieczęcią i podpisem.',
          'Klient potrzebuje wyciągu dwujęzycznego (polsko-angielskiego), doradca drukuje odpowiedni wzór.',
        ],
        lifeVariations: [
          'Urzędnik informuje, że zaświadczenie papierowe z pieczęcią wiąże się z opłatą manipulacyjną (np. 15 zł).',
          'Urząd wymaga wyciągu za 6 miesięcy z wyodrębnionymi wpływami od pracodawcy; doradca filtruje historię.',
          'Klient ma środki w PLN i EUR, doradca wystawia zaświadczenie zbiorcze z przeliczeniem po kursie NBP.',
        ],
        challengeVariations: [
          'Na wyciągu widnieje debet lub blokada skarbowa, doradca wyjaśnia konsekwencje formalne przed urzędem wojewódzkim.',
          'Urząd wymaga pieczęci okrągłej centrali, doradca tłumaczy procedurę zamówienia dokumentu centralnego.',
          'Opłata za zaświadczenie w trybie pilnym wynosi 35 zł i musi być pobrana bezpośrednio z konta.',
        ],
        npcPersonalities: [
          'Doświadczony doradca doskonale zorientowany w wymogach urzędów wojewódzkich.',
          'Formalny urzędnik bankowy dbający o precyzyjną poprawność pieczęci.',
          'Cierpliwy doradca szukający najtańszej i najwygodniejszej ścieżki dla klienta.',
        ],
      ),
    ],
  ),
  Scenario(
    key: 'cafe',
    emoji: '☕',
    titleRu: 'Заказ в кафе',
    titleUk: 'Замовлення в кафе',
    titlePl: 'Zamówienie w kawiarni',
    level: 'A1',
    npcRole: 'kelner/kelnerka lub barista w kawiarni',
    setting:
        'Obsługa gości w klimatycznej polskiej kawiarni. '
        'W zależności od podscenariusza kelner przyjmuje zamówienie na kawę i ciasto, odpowiada na pytania o alergeny lub rozlicza osobne rachunki.',
    vocab: ['na wynos', 'na miejscu', 'poproszę rachunek', 'płacimy osobno', 'doliczyć napiwek'],
    subScenarios: [
      SubScenario(
        id: 'cafe_order',
        titleRu: 'Заказ кофе и десерта',
        titleUk: 'Замовлення кави та десерту',
        titlePl: 'Zamówienie kawy i deseru',
        descRu: 'Выбор столика, кофе с молоком (овсяное/обычное), десерт и счет.',
        descUk: 'Вибір столика, кава з молоком (вівсяне/звичайне), десерт та рахунок.',
        descPl: 'Wybór stolika, kawa z mlekiem (owsiane/zwykłe), deser i rachunek.',
        starterHintPl: 'Dzień dobry, poproszę cappuccino na mleku owsianym i szarlotkę na ciepło.',
        starterHintUk: 'Добрий день, будь ласка, капучино на вівсяному молоці та теплу шарлотку.',
        starterHintRu: 'Добрый день, пожалуйста, капучино на овсяном молоке и теплую шарлотку.',
        plotTwist: 'Szarlotka właśnie się skończyła, kelner uśmiecha się i poleca świeży sernik krakowski z malinami.',
        vocab: ['mleko owsiane', 'szarlotka', 'sernik krakowski', 'rachunek', 'na wynos'],
        npcRole: 'barista / kelner w kawiarni przyjmujący zamówienia',
        setting:
            'Klient zamawia kawę i deser w kawiarni. Kelner wita gościa, pyta o wielkość i rodzaj kawy, mleko (zwykłe lub roślinne: owsiane/sojowe), '
            'czy podać na miejscu czy na wynos, oraz poleca świeże desery. '
            'OBOWIĄZKOWO podaje pełną kwotę zamówienia SŁOWAMI (np. „To będzie dwadzieścia cztery złote”).',
        npcFirstStarterPl: 'Dzień dobry! Zapraszam serdecznie, co mogę dla pana przygotować do picia lub na deser?',
        npcFirstStarterUk: 'Добрий день! Щиро запрошую, що можу для вас приготувати попити або на десерт?',
        npcFirstStarterRu: 'Добрый день! Приглашаю, что могу для вас приготовить попить или на десерт?',
        npcFirstInstruction:
            'Zacznij scenę jako kelner/barista w kawiarni. Przywitaj serdecznie gościa i zapytaj, co przygotować do picia lub na deser.',
        calmVariations: [
          'Gość zamawia klasyczne cappuccino i ciepłą szarlotkę z lodami; zamówienie przebiega gładko.',
          'Klient bierze flat white na wynos i croissant pistacjowy, barista sprawnie podaje kubek.',
        ],
        lifeVariations: [
          'Szarlotka właśnie się skończyła, kelner poleca wyśmienity sernik krakowski z malinami.',
          'Mleko owsiane się skończyło, kelner proponuje migdałowe, sojowe lub bezlaktozowe.',
          'Brak wolnych stolików na dole, kelner proponuje stolik na antresoli lub na wynos.',
        ],
        challengeVariations: [
          'Ekspres do kawy przechodzi 15-minutowy cykl czyszczenia; barista proponuje kawę przelewową drip lub herbatę rozgrzewającą.',
          'W kasie brakuje bilonu do wydania reszty z banknotu 100 zł; kelner prosi o płatność zbliżeniową lub BLIK.',
          'W kawiarni jest duży ruch, czas oczekiwania wynosi 20 minut; kelner uprzedza i podaje darmową wodę.',
        ],
        npcPersonalities: [
          'Uśmiechnięty barista z pasją do parzenia kawy specialty.',
          'Elegancki, dyskretny kelner dbający o spokój gości.',
          'Młoda, bardzo serdeczna kelnerka, która dopiero poznaje menu.',
        ],
      ),
      SubScenario(
        id: 'cafe_allergies',
        titleRu: 'Аллергии и особенности меню',
        titleUk: 'Алергії та особливості меню',
        titlePl: 'Alergie i specjalne menu',
        descRu: 'Уточнение состава блюд: без глютена, без орехов или постное/веганское меню.',
        descUk: 'Уточнення складу страв: без глютену, без горіхів або пісне/веганське меню.',
        descPl: 'Skład dań: bez glutenu, bez orzechów lub dania wegańskie i bez laktozy.',
        starterHintPl: 'Przepraszam, mam silną alergię na orzechy i gluten. Czy te desery są dla mnie bezpieczne?',
        starterHintUk: 'Перепрошую, у мене сильна алергія на горіхи та глютен. Чи ці десерти безпечні для мене?',
        starterHintRu: 'Извините, у меня сильная аллергия на орехи и gluten. Эти десерты безопасны для меня?',
        plotTwist: 'Kelner sprawdza tabelę alergenów w kuchni i informuje, że ciasto ma śladowe ilości glutenu, ale proponuje bezpieczny deser chia.',
        vocab: ['karta alergenów', 'bezglutenowe', 'orzechy', 'laktoza', 'bezpieczne danie'],
        npcRole: 'kelner w kawiarni znający szczegółowo kartę alergenów',
        setting:
            'Klient pyta o skład deserów z powodu alergii pokarmowej (gluten, orzechy, laktoza). '
            'Kelner traktuje to z pełną powagą, sprawdza segregator alergenów w kuchni i wskazuje, które pozycje są w 100% bezpieczne, a które mogą zawierać alergeny śladowe.',
        npcFirstStarterPl: 'Dzień dobry! Czy wybrali już państwo, czy mają państwo jakieś pytania o alergeny lub składniki dań?',
        npcFirstStarterUk: 'Добрий день! Чи обрали вже, чи маєте питання щодо алергенів або складу страв?',
        npcFirstStarterRu: 'Добрый день! Вы уже выбрали или у вас есть вопросы по аллергенам или составу блюд?',
        npcFirstInstruction:
            'Zacznij scenę jako kelner w kawiarni. Klient uważnie studiuje kartę deserów. Przywitaj się i zapytaj, czy ma pytania dotyczące alergenów lub składników dań.',
        calmVariations: [
          'Kelner przynosi kartę alergenów i wskazuje ciasta w 100% bezpieczne i certyfikowane bezglutenowe.',
          'Klient szuka deseru bez cukru i laktozy, kelner poleca mus kokosowy z chia i owocami leśnymi.',
        ],
        lifeVariations: [
          'Kelner sprawdza w kuchni i uprzedza, że ciasto ma śladowe ilości glutenu, ale deser chia jest w pełni bezpieczny.',
          'Ciasto bezglutenowe pieczone jest w tym samym piecu co zwykłe; kelner uczciwie informuje o ryzyku zanieczyszczenia.',
          'Syrop smakowy zawiera ekstrakt z orzechów; kelner proponuje bezpieczną przyprawę cynamonową.',
        ],
        challengeVariations: [
          'Klient ma silną alergię anafilaktyczną na orzeszki ziemne; kelner wzywa szefa kuchni dla pełnej pewności składników.',
          'Przez pomyłkę baristy kawa została przygotowana na mleku krowim zamiast owsianego; kelner natychmiast ją wymienia z przeprosinami.',
          'Większość deserów zawiera żelatynę wieprzową lub laktozę; wegański gość szuka alternatywy, a kelner analizuje całą kartę.',
        ],
        npcPersonalities: [
          'Uważny kelner traktujący alergie gości z najwyższą odpowiedzialnością.',
          'Konkretny pracownik kuchni mówiący szczerze o składzie i procesie przygotowania.',
          'Profesjonalny kelner z certyfikatem baristy i wiedzą o dietetyce.',
        ],
      ),
      SubScenario(
        id: 'cafe_split_bill',
        titleRu: 'Раздельный счет и чаевые',
        titleUk: 'Роздільний рахунок та чайові',
        titlePl: 'Osobny rachunek i napiwek',
        descRu: 'Расчет: отдельные чеки, оплата частями (карта + BLIK) и чаевые.',
        descUk: 'Розрахунок: окремі чеки, оплата частинами (картка + BLIK) та чайові.',
        descPl: 'Rozliczenie: płatność osobno, podział kwoty (karta + BLIK) i napiwek.',
        starterHintPl: 'Poprosimy o rachunek, ale chcielibyśmy zapłacić osobno za kawę i desery.',
        starterHintUk: 'Будь ласка, рахунок, але ми хотіли б заплатити окремо за каву та десерти.',
        starterHintRu: 'Пожалуйста, счет, но мы хотели бы заплатить раздельно за кофе и десерты.',
        plotTwist: 'Terminal wymaga osobnego wbicia każdej kwoty, kelner pyta czy doliczyć 10% serwisu lub dobrowolny napiwek.',
        vocab: ['płacimy osobno', 'podział rachunku', 'napiwek', 'terminal', 'razem'],
        npcRole: 'kelner podchodzący do stolika z terminalem płatniczym',
        setting:
            'Goście proszą o rozliczenie i chcą zapłacić osobno (np. jedna osoba kartą, druga kodem BLIK). '
            'Kelner rozbija pozycje, podaje kwoty dla każdej osoby SŁOWAMI, pyta o formę płatności oraz czy doliczyć napiwek.',
        npcFirstStarterPl: 'Dzień dobry! Proszę bardzo, oto państwa rachunek. Płacą państwo razem czy osobno?',
        npcFirstStarterUk: 'Добрий день! Будь ласка, ось ваш рахунок. Розраховуєтесь разом чи окремо?',
        npcFirstStarterRu: 'Добрый день! Пожалуйста, вот ваш счет. Платите вместе или раздельно?',
        npcFirstInstruction:
            'Zacznij scenę jako kelner podchodzący z rachunkiem do stolika. Przywitaj się i zapytaj, czy goście płacą razem czy osobno.',
        calmVariations: [
          'Kelner dzieli rachunek równo na pół, podaje kwoty słowami i bez problemu przyjmuje kartę i gotówkę.',
          'Jedna osoba płaci za napoje, druga za desery; kelner drukuje dwa osobne paragony.',
        ],
        lifeVariations: [
          'Terminal wymaga osobnego wbicia każdej kwoty, kelner pyta czy doliczyć napiwek za miłą obsługę.',
          'Kod BLIK wygasł po 2 minutach, klient musi wygenerować nowy kod w aplikacji bankowej.',
          'Rachunek wynosi 87 zł, goście chcą zapłacić po 43,50 zł; kelner precyzyjnie rozlicza transakcję.',
        ],
        challengeVariations: [
          'Stolik liczy 6 osób i obowiązuje 10% serwisu grupowego; goście dopytują o pozycję, a kelner uprzejmie wyjaśnia zasady lokalu.',
          'Karta jednej z osób została odrzucona przez terminal; kelner dyskretnie proponuje BLIK lub gotówkę.',
          'Klienci chcą zapłacić część w euro w gotówce, a część kartą; kelner wyjaśnia przelicznik kursowy lokalu.',
        ],
        npcPersonalities: [
          'Wesoły kelner sprawnie i żartobliwie pomagający rozdzielić płatności.',
          'Precyzyjny kelner wyliczający każdą pozycję co do grosza.',
          'Dyskretny i taktowny kelner świetnie radzący sobie w delikatnych kwestiach rachunków.',
        ],
      ),
    ],
  ),
  Scenario(
    key: 'doctor',
    emoji: '🩺',
    titleRu: 'У врача',
    titleUk: 'У лікаря',
    titlePl: 'U lekarza',
    level: 'A2',
    npcRole: 'pracownik placówki ochrony zdrowia (przychodnia POZ / apteka)',
    setting:
        'Wizyta w polskiej placówce medycznej lub aptece. '
        'W zależności od podscenariusza pacjent rejestruje się w okienku POZ, odbywa konsultację lekarską z wystawieniem zwolnienia L4 lub kupuje leki na e-receptę w aptece.',
    vocab: ['boli mnie gardło', 'mam gorączkę', 'e-recepta', 'kod recepty', 'zwolnienie L4'],
    subScenarios: [
      SubScenario(
        id: 'doctor_registry',
        titleRu: 'Регистрация в окошке (POZ)',
        titleUk: 'Реєстрація у віконці (POZ)',
        titlePl: 'Rejestracja w okienku (POZ)',
        descRu: 'Запись на прием к терапевту, выбор времени, проверка страховки NFZ или e-WUŚ.',
        descUk: 'Запис на прийом до терапевта, вибір часу, перевірка страховки NFZ чи e-WUŚ.',
        descPl: 'Zapis do lekarza pierwszego kontaktu, wybór terminu, weryfikacja ubezpieczenia NFZ / e-WUŚ.',
        starterHintPl: 'Dzień dobry, chciałbym zapisać się do lekarza pierwszego kontaktu na dzisiejszy termin.',
        starterHintUk: 'Добрий день, я хотів би записатися до сімейного лікаря на сьогодні.',
        starterHintRu: 'Добрый день, я хотел бы записаться к участковому терапевту на сегодня.',
        plotTwist: 'Na dziś nie ma już wolnych numerków do lekarza rodzinnego, rejestratorka proponuje wizytę popołudniową w trybie nagłym.',
        vocab: ['rejestracja', 'lekarz POZ', 'brak wolnych terminów', 'system e-WUŚ', 'PESEL'],
        npcRole: 'rejestratorka medyczna w okienku przychodni POZ',
        setting:
            'Pacjent podchodzi do okienka rejestracji w przychodni publicznej POZ, aby zapisać się do lekarza pierwszego kontaktu. '
            'Rejestratorka pyta o numer PESEL do weryfikacji w systemie e-WUŚ (ubezpieczenie NFZ), sprawdza wolne godziny, a w razie braku miejsc informuje o zapisach na inny termin lub wizycie ostrej.',
        npcFirstStarterPl: 'Dzień dobry! Do którego lekarza chciałby się pan zarejestrować i czy sprawa jest pilna na dziś?',
        npcFirstStarterUk: 'Добрий день! До якого лікаря ви хотіли б зареєструватися і чи справа термінова на сьогодні?',
        npcFirstStarterRu: 'Добрый день! К какому врачу вы хотели бы записаться и срочный ли случай на сегодня?',
        npcFirstInstruction:
            'Zacznij scenę jako rejestratorka medyczna w okienku rejestracji przychodni POZ. Pacjent podszedł do okienka. Przywitaj się i zapytaj, do jakiego lekarza chce się zarejestrować i na jaki termin.',
        calmVariations: [
          'Rejestratorka znajduje wolny termin na ten sam dzień o 14:30 i sprawnie wpisuje pacjenta na listę.',
          'Pacjent rejestruje się na szczepienie lub rutynowy bilans zdrowia na kolejny tydzień.',
        ],
        lifeVariations: [
          'Na dziś brak wolnych terminów do lekarza rodzinnego, rejestratorka proponuje dyżur ostry popołudniu.',
          'W systemie e-WUŚ status świeci na czerwono; rejestratorka prosi o podpisanie oświadczenia o prawie do świadczeń.',
          'Lekarz pierwszego kontaktu przyjmuje tylko do 13:00, pacjent zostaje zapisany do lekarza dyżurnego.',
        ],
        challengeVariations: [
          'Pacjent nie złożył jeszcze deklaracji wyboru lekarza POZ w tej placówce; rejestratorka prosi najpierw o wypełnienie deklaracji.',
          'Pacjent ma wysoką gorączkę i duszności; rejestratorka ocenia stan jako nagły i od razu kieruje do gabinetu zabiegowego.',
          'Duża kolejka do okienka i ciągle dzwoniący telefon; rejestratorka rozmawia krótko i prosi o szybkie podanie numeru PESEL.',
        ],
        npcPersonalities: [
          'Ciepła i opiekuńcza pani z rejestracji, starająca się pomóc każdemu choremu.',
          'Zaganiana urzędniczka medyczna pracująca pod presją kolejki.',
          'Dokładna rejestratorka ściśle przestrzegająca przepisów NFZ i weryfikacji tożsamości.',
        ],
      ),
      SubScenario(
        id: 'doctor_consultation',
        titleRu: 'Прием у врача: симптомы и больничный L4',
        titleUk: 'Прийом у лікаря: симптоми та лікарняний L4',
        titlePl: 'Wizyta u lekarza: objawy i zwolnienie L4',
        descRu: 'Осмотр, жалобы на кашель и температуру, аускультация легких и оформление больничного L4.',
        descUk: 'Огляд, скарги на кашель і температуру, аускультація легень та відкриття електронного лікарняного L4.',
        descPl: 'Badanie, kaszel i gorączka, osłuchanie płuc oraz wystawienie e-zwolnienia L4.',
        starterHintPl: 'Dzień dobry panie doktorze, od dwóch dni mam wysoką gorączkę i męczący kaszel.',
        starterHintUk: 'Добрий день, лікарю, вже два дні маю високу температуру та виснажливий кашель.',
        starterHintRu: 'Добрый день, доктор, уже два дня у меня высокая температура и изнуряющий кашель.',
        plotTwist: 'Lekarz osłuchuje płuca, stwierdza ostre zapalenie oskrzeli, wystawia zwolnienie L4 na 7 dni i prosi o NIP pracodawcy.',
        vocab: ['gorączka', 'osłuchanie', 'zapalenie oskrzeli', 'zwolnienie L4', 'NIP pracodawcy'],
        npcRole: 'lekarz rodzinny / internista w gabinecie przychodni POZ',
        setting:
            'Pacjent wchodzi do gabinetu na wizytę lekarską. Lekarz wita pacjenta, zaprasza na krzesło, pyta o objawy (ból gardła, kaszel, gorączka od kiedy), '
            'bada pacjenta stetoskopem, stawia diagnozę, ordynuje leki na e-receptę i wystawia elektroniczne zwolnienie e-ZLA (L4), pytając o NIP pracodawcy.',
        npcFirstStarterPl: 'Dzień dobry, proszę wejść i usiąść. Co panu dolega, z jakimi objawami pan do mnie przychodzi?',
        npcFirstStarterUk: 'Добрий день, проходьте та сідайте. Що вас турбує, з якими симптомами прийшли до мене?',
        npcFirstStarterRu: 'Добрый день, проходите и садитесь. Что вас беспокоит, с какими симптомами ко мне пришли?',
        npcFirstInstruction:
            'Zacznij scenę jako lekarz rodzinny w gabinecie lekarskim. Pacjent wszedł do gabinetu. Przywitaj się uprzejmie, wskaż krzesło i zapytaj, co pacjentowi dolega i jakie ma objawy.',
        calmVariations: [
          'Lekarz stwierdza lekką infekcję wirusową gardła, przepisuje syrop i witaminy oraz daje L4 na 4 dni.',
          'Wizyta kontrolna: lekarz osłuchuje płuca, widzi wyraźną poprawę i zamyka zwolnienie lekarskie.',
        ],
        lifeVariations: [
          'Lekarz osłuchuje płuca, stwierdza ostre zapalenie oskrzeli, wystawia zwolnienie L4 na 7 dni i prosi o NIP pracodawcy.',
          'Pacjent zgłasza silny ból zatok; lekarz ordynuje steryd donosowy i zaleca inhalacje.',
          'Pacjent wykonuje pracę fizyczną; lekarz decyduje się przedłużyć L4 na cały tydzień dla uniknięcia powikłań.',
        ],
        challengeVariations: [
          'Lekarz podejrzewa anginę bakteryjną i chce wdrożyć antybiotyk, ale pacjent zgłasza alergię na penicylinę; lekarz szuka bezpiecznej alternatywy.',
          'Objawy trwają ponad 10 dni; lekarz wystawia pilne skierowanie na RTG klatki piersiowej i badanie krwi z CRP.',
          'Pacjent prosi o wsteczne L4 za ubiegły tydzień; lekarz tłumaczy przepisy ZUS zezwalające na maks. 3 dni wstecz od badania.',
        ],
        npcPersonalities: [
          'Empatyczny lekarz rodzinny, który uważnie słucha pacjenta i szczegółowo omawia leczenie.',
          'Rzeczowy, konkretny internista stawiający szybką diagnozę opartą na badaniu.',
          'Dociekliwy diagnosta pytający o tryb życia, leki i historię chorób w rodzinie.',
        ],
      ),
      SubScenario(
        id: 'doctor_pharmacy',
        titleRu: 'В аптеке: 4-значный код e-рецепта',
        titleUk: 'В аптеці: 4-значний код e-рецепта',
        titlePl: 'W aptece: 4-cyfrowy kod e-recepty',
        descRu: 'Покупка лекарств по электронному рецепту в польской аптеке, аналоги и дозировка.',
        descUk: 'Купівля ліків за електронним рецептом у польській аптеці, аналоги та дозування.',
        descPl: 'Realizacja recepty elektronicznej w aptece, zamienniki i dawkowanie leków.',
        starterHintPl: 'Dzień dobry, chciałbym zrealizować e-receptę. Mam czterocyfrowy kod oraz numer PESEL.',
        starterHintUk: 'Добрий день, я хотів би отримати ліки за е-рецептом. Маю 4-значний код та номер PESEL.',
        starterHintRu: 'Добрый день, я хотел бы получить лекарства по е-рецепту. У меня 4-значный код и номер PESEL.',
        plotTwist: 'Przepisany antybiotyk jest chwilowo niedostępny w tej dawce, farmaceuta proponuje tańszy polski zamiennik o identycznym składzie.',
        vocab: ['e-recepta', 'kod recepty', 'zamiennik', 'dawkowanie', 'antybiotyk'],
        npcRole: 'magister farmacji za ladą w aptece',
        setting:
            'Klient przychodzi do apteki zrealizować e-receptę. Farmaceuta wita klienta, prosi o 4-cyfrowy kod e-recepty oraz numer PESEL pacjenta. '
            'Sprawdza system, w razie potrzeby proponuje tańszy polski odpowiednik (zamiennik), tłumaczy dawkowanie i podaje kwotę do zapłaty SŁOWAMI.',
        npcFirstStarterPl: 'Dzień dobry! Poproszę czterocyfrowy kod e-recepty oraz pana numer PESEL.',
        npcFirstStarterUk: 'Добрий день! Будь ласка, чотиризначний код е-рецепта та ваш номер PESEL.',
        npcFirstStarterRu: 'Добрый день! Пожалуйста, четырехзначный код е-рецепта и ваш номер PESEL.',
        npcFirstInstruction:
            'Zacznij scenę jako farmaceuta za ladą w aptece. Klient podszedł do okienka. Przywitaj się uprzejmie i poproś o 4-cyfrowy kod e-recepty oraz numer PESEL pacjenta.',
        calmVariations: [
          'Farmaceuta od ręki wydaje przepisane leki, opisuje dawkowanie markerem na opakowaniach i przyjmuje płatność.',
          'Klient kupuje maść i krople, farmaceuta dokładnie tłumaczy sposób aplikacji leków.',
        ],
        lifeVariations: [
          'Przepisany antybiotyk jest niedostępny w tej dawce, farmaceuta proponuje tańszy polski zamiennik o identycznym składzie.',
          'Recepta jest roczna, farmaceuta pyta czy klient chce wykupić zapas na miesiąc czy od razu na 3 miesiące.',
          'Do antybiotyku farmaceuta doradza probiotyk i tłumaczy, aby przyjmować go 2 godziny po leku głównym.',
        ],
        challengeVariations: [
          'Ważność e-recepty na antybiotyk minęła (7 dni od wystawienia); farmaceuta musi odmówić wydania leku i skierować do lekarza.',
          'Lek jest na liście leków deficytowych; farmaceuta sprawdza inne apteki w mieście i proponuje sprowadzenie z hurtowni na rano.',
          'Lekarz zaznaczył 100% odpłatności zamiast zniżki; farmaceuta informuje o wysokiej cenie i pyta czy klient kupuje lek pełnopłatnie.',
        ],
        npcPersonalities: [
          'Uprzejma pani magister farmacji z troską opisująca dawkowanie leków.',
          'Szybki i rzeczowy aptekarz sprawnie obsługujący kolejkę.',
          'Doświadczony farmaceuta doradzający tańsze polskie odpowiedniki leków.',
        ],
      ),
    ],
  ),
  Scenario(
    key: 'urzad',
    emoji: '🏛️',
    titleRu: 'В Urząd (оформление документов)',
    titleUk: 'В Urząd (оформлення документів)',
    titlePl: 'W Urzędzie (załatwianie spraw)',
    level: 'A2',
    npcRole: 'urzędnik w polskim urzędzie administracji publicznej',
    setting:
        'Załatwianie spraw formalnych w urzędzie gminy, dzielnicy lub urzędzie wojewódzkim. '
        'W zależności od podscenariusza urzędnik przyjmuje wniosek o meldunek i PESEL, weryfikuje dokumenty na Kartę Pobytu lub wydaje gotowy dokument.',
    vocab: ['wniosek', 'dowód / paszport', 'meldunek', 'termin', 'podpis', 'umowa najmu'],
    subScenarios: [
      SubScenario(
        id: 'urzad_meldunek_pesel',
        titleRu: 'Временная прописка и номер PESEL',
        titleUk: 'Тимчасова прописка та номер PESEL',
        titlePl: 'Meldunek czasowy i numer PESEL',
        descRu: 'Оформление прописки по договору аренды жилья и получение идентификационного номера PESEL.',
        descUk: 'Оформлення прописки за договором оренди квартири та отримання податкового/ідентифікаційного номера PESEL.',
        descPl: 'Złożenie wniosku o meldunek czasowy z umową najmu oraz nadanie numeru PESEL.',
        starterHintPl: 'Dzień dobry, mam bilet z numerkiem. Chciałbym złożyć wniosek o meldunek czasowy i numer PESEL.',
        starterHintUk: 'Добрий день, у мене талон з номерком. Я хотів би подати заяву на тимчасову прописку та номер PESEL.',
        starterHintRu: 'Добрый день, у меня талон с номерком. Я хотел бы подать заявление на временную регистрацию и номер PESEL.',
        plotTwist: 'W umowie najmu brakuje zgody właściciela lokalu lub podpisy nie są poświadczone, urzędnik wyjaśnia procedurę uzupełnienia braków formalnych.',
        vocab: ['wniosek o meldunek', 'umowa najmu', 'potwierdzenie', 'numer PESEL', 'podpis'],
        npcRole: 'urzędnik w wydziale spraw obywatelskich urzędu gminy / dzielnicy',
        setting:
            'Petent przychodzi do urzędu zameldować się na pobyt czasowy na podstawie umowy najmu lokalu oraz uzyskać PESEL. '
            'Urzędnik prosi o bilet z numerkiem, paszport, umowę najmu i formularz wniosku. Sprawdza dane, wyjaśnia wymogi formalne i wydaje zaświadczenie o zameldowaniu.',
        npcFirstStarterPl: 'Dzień dobry, proszę bilet z biletomatu. W jakiej sprawie pan przychodzi, meldunek czy nadanie numeru PESEL?',
        npcFirstStarterUk: 'Добрий день, дайте будь ласка талон з терміналу. У якій справі звертаєтесь, прописка чи надання номера PESEL?',
        npcFirstStarterRu: 'Добрый день, дайте пожалуйста талон из терминала. По какому вопросу обращаетесь, регистрация или получение номера PESEL?',
        npcFirstInstruction:
            'Zacznij scenę jako urzędnik wydziału spraw obywatelskich. Petent podszedł do biurka po wywołaniu numerka. Przywitaj się, poproś o bilet i zapytaj o cel wizyty: meldunek czy nadanie numeru PESEL.',
        calmVariations: [
          'Komplet dokumentów i umowa najmu są wzorowe; urzędnik od ręki melduje na rok i drukuje poświadczenie z PESEL.',
          'Cudzoziemiec przedłuża meldunek na kolejny okres na podstawie aneksu do umowy najmu.',
        ],
        lifeVariations: [
          'W umowie najmu brakuje numeru księgi wieczystej lokalu; urzędnik pomaga znaleźć wpis w internetowym rejestrze KW po adresie.',
          'Umowa została podpisana podpisem zaufanym ePUAP; urzędnik weryfikuje certyfikat w systemie.',
          'Urzędnik prosi o doprecyzowanie podstawy prawnej do nadania PESEL i wskazuje odpowiednie pole formularza.',
        ],
        challengeVariations: [
          'Umowa najmu jest zawarta z podnajemcą; urzędnik żąda pisemnej zgody głównego właściciela mieszkania na podnajem.',
          'Ważność paszportu kończy się za 2 miesiące; urzędnik tłumaczy, że meldunek może być nadany tylko do daty ważności paszportu.',
          'W danych brakuje poświadczonego tłumaczenia imion rodziców; urzędnik wzywa do uzupełnienia braków formalnych.',
        ],
        npcPersonalities: [
          'Przyjazny urzędnik spraw obywatelskich cierpliwie pomagający wypełnić formularze.',
          'Skrupulatna urzędniczka weryfikująca każdą datę i podpis w umowie.',
          'Doświadczony kierownik referatu mówiący precyzyjnym językiem urzędowym.',
        ],
      ),
      SubScenario(
        id: 'urzad_karta_pobytu',
        titleRu: 'Подача заявления на Карту Побыту',
        titleUk: 'Подача заяви на Карту Побиту',
        titlePl: 'Złożenie wniosku o Kartę Pobytu',
        descRu: 'Подача пакета документов на ВНЖ в воеводстве, сдача отпечатков пальцев, приложение №1.',
        descUk: 'Подача пакету документів на ВНЖ, зняття відбитків пальців, додаток Załącznik nr 1 від роботодавця.',
        descPl: 'Składanie wniosku o pobyt czasowy w urzędzie wojewódzkim, odciski palców i załącznik nr 1.',
        starterHintPl: 'Dzień dobry, mam wezwanie na pobranie odcisków palców i złożenie wniosku o pobyt czasowy.',
        starterHintUk: 'Добрий день, маю виклик на зняття відбитків пальців та подачу документів на тимчасовий побит.',
        starterHintRu: 'Добрый день, у меня вызов на сдачу отпечатков пальцев и подачу заявления на временный побыт.',
        plotTwist: 'Jedno ze zdjęć ma zły format biometryczny lub brakuje potwierdzenia opłaty skarbowej (440 zł) — urzędnik kieruje do kasy na dole.',
        vocab: ['pobyt czasowy', 'odciski palców', 'opłata skarbowa', 'załącznik nr 1', 'karta pobytu'],
        npcRole: 'inspektor do spraw cudzoziemców w Urzędzie Wojewódzkim',
        setting:
            'Petent składa wniosek o kartę pobytu czasowego i pracę w urzędzie wojewódzkim. '
            'Inspektor sprawdza bilet, weryfikuje paszport, kompletność załączników (Załącznik nr 1, zdjęcia, opłata skarbowa 440 zł), '
            'pobiera odciski palców na czytniku biometrycznym i wbija pieczęć do paszportu.',
        npcFirstStarterPl: 'Dzień dobry, zapraszam do stanowiska. Proszę bilet z numerkiem, paszport oraz wniosek o pobyt czasowy.',
        npcFirstStarterUk: 'Добрий день, запрошую до робочого місця. Будь ласка, талон, закордонний паспорт та заяву на тимчасовий побит.',
        npcFirstStarterRu: 'Добрый день, приглашаю к рабочему месту. Пожалуйста, талон, загранпаспорт и заявление на временный побыт.',
        npcFirstInstruction:
            'Zacznij scenę jako inspektor ds. cudzoziemców w urzędzie wojewódzkim. Petent podszedł do stanowiska. Przywitaj się i poproś o bilet z numerkiem, paszport oraz wniosek o pobyt czasowy.',
        calmVariations: [
          'Dokumenty, załącznik nr 1 i dowód wpłaty 440 zł są kompletne; inspektor skanuje odciski palców i wbija pieczęć do paszportu.',
          'Wniosek studencki o pobyt czasowy; inspektor weryfikuje zaświadczenie z uczelni i przyjmuje wniosek.',
        ],
        lifeVariations: [
          'Jedno ze zdjęć nie spełnia wymogów biometrycznych (lekki uśmiech); inspektor kieruje do fotografa na parterze i czeka.',
          'Brakuje potwierdzenia opłaty skarbowej 440 zł; inspektor daje druczek do wpłaty w kasie urzędu.',
          'W załączniku nr 1 brakuje podpisu członka zarządu według KRS; inspektor wystawia wezwanie na 7 dni.',
        ],
        challengeVariations: [
          'Wynagrodzenie z załącznika nr 1 jest poniżej ustawowego kryterium dochodowego; inspektor ostrzega przed odmową i żąda aneksu do umowy.',
          'Brak wolnych stron w paszporcie na czerwoną pieczęć; inspektor wydaje papierowe zaświadczenie z pouczeniem o wymianie paszportu.',
          'Czytnik linii papilarnych nie rejestruje startych opuszków palców; inspektor kilkukrotnie ponawia kalibrację skanera.',
        ],
        npcPersonalities: [
          'Rzeczowy inspektor ds. cudzoziemców, profesjonalny i bezstronny.',
          'Rygorystyczna urzędniczka sprawdzająca każdą rubrykę pod kątem braków formalnych.',
          'Życzliwy inspektor doradzający jak najskuteczniej udokumentować źródło utrzymania.',
        ],
      ),
      SubScenario(
        id: 'urzad_pickup',
        titleRu: 'Выдача готового документа',
        titleUk: 'Видача готового документа',
        titlePl: 'Odbiór gotowego dokumentu',
        descRu: 'Получение изготовленной карты побыту, сверка данных и подпись в реестре.',
        descUk: 'Отримання виготовленої карти побиту, перевірка даних та розпис у реєстрі.',
        descPl: 'Odbiór wydanej karty pobytu, weryfikacja danych i podpis na czytniku cyfrowym.',
        starterHintPl: 'Dzień dobry, dostałem SMS z informacją, że moja karta pobytu jest gotowa do odbioru.',
        starterHintUk: 'Добрий день, я отримав SMS з інформацією, що моя карта побиту готова до видачі.',
        starterHintRu: 'Добрый день, я получил SMS с уведомлением, что моя карта побыту готова к выдаче.',
        plotTwist: 'Przed wydaniem karty trzeba okazać stary paszport oraz zwrócić poprzednie zaświadczenie, po czym złożyć podpis na czytniku cyfrowym.',
        vocab: ['odbiór dokumentu', 'potwierdzenie SMS', 'czytnik cyfrowy', 'czytelny podpis'],
        npcRole: 'urzędnik w punkcie wydawania gotowych kart pobytu i dokumentów',
        setting:
            'Petent przychodzi odebrać gotową kartę pobytu po otrzymaniu SMS-a. '
            'Urzędnik prosi o paszport zagraniczny oraz SMS z numerem sprawy, wyciąga kartę z depozytu, prosi o sprawdzenie poprawności danych i złożenie podpisu na cyfrowym padzie/czytniku.',
        npcFirstStarterPl: 'Dzień dobry! Poproszę ważny paszport oraz okazanie wiadomości SMS z numerem sprawy do odbioru karty.',
        npcFirstStarterUk: 'Добрий день! Будь ласка, дійсний паспорт та покажіть SMS з номером справи для видачі карти.',
        npcFirstStarterRu: 'Добрый день! Пожалуйста, действующий паспорт и покажите SMS с номером дела для выдачи карты.',
        npcFirstInstruction:
            'Zacznij scenę jako urzędnik wydający dokumenty w urzędzie. Petent podszedł do lady odbioru. Przywitaj się uprzejmie i poproś o paszport oraz SMS powiadamiający o gotowej karcie pobytu.',
        calmVariations: [
          'Urzędnik weryfikuje paszport, wydaje plastikową kartę pobytu, prosi o sprawdzenie danych i podpis na czytniku cyfrowym.',
          'Cudzoziemiec odbiera jednocześnie decyzję wojewody i plastikową kartę w miłej atmosferze.',
        ],
        lifeVariations: [
          'Przed wydaniem nowej karty trzeba zdać poprzednią kartę do unieważnienia; urzędnik przecina stary plastik.',
          'W powiadomieniu SMS podano stary numer pokoju; urzędnik wyjaśnia zmianę stanowisk i zaprasza do siebie.',
          'Petent zmienił adres zamieszkania; urzędnik wyjaśnia procedurę aktualizacji danych w rejestrze cudzoziemców.',
        ],
        challengeVariations: [
          'Na wydrukowanej karcie pobytu wkradła się literówka w nazwisku; urzędnik sporządza protokół reklamacyjny do PWPW.',
          'Klient nie ma oryginału paszportu (zgłosił kradzież), a jedynie zaświadczenie z policji; urzędnik konsultuje wydanie karty z naczelnikiem.',
          'Terminal do podpisu biometrycznego zawiesił się; urzędnik restartuje system i przeprasza za opóźnienie.',
        ],
        npcPersonalities: [
          'Uprzejmy urzędnik wydający dokumenty, gratulujący uzyskania karty pobytu.',
          'Skupiony pracownik kancelarii sprawdzający każdy detal tożsamości.',
          'Cierpliwa urzędniczka tłumacząca jak dbać o dokument i terminy meldunkowe.',
        ],
      ),
    ],
  ),
];
