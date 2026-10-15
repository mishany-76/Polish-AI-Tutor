enum DialogInitiator {
  userFirst,
  npcFirst,
}

class SubScenario {
  const SubScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.starterHintPl,
    required this.starterHintUk,
    required this.starterHintRu,
    required this.plotTwist,
    this.vocab = const [],
    this.npcRole,
    this.setting,
  });

  final String id;
  final String title;
  final String description;
  final String starterHintPl;
  final String starterHintUk;
  final String starterHintRu;
  final String plotTwist;
  final List<String> vocab;
  final String? npcRole;
  final String? setting;
}

class Scenario {
  const Scenario({
    required this.key,
    required this.emoji,
    required this.title,
    required this.level,
    required this.npcRole,
    required this.setting,
    required this.vocab,
    this.subScenarios = const [],
  });

  final String key;
  final String emoji;
  final String title;
  final String level;

  /// Кого играет ИИ (по-польски/по-русски — для системного промпта).
  final String npcRole;

  /// Описание ситуации для ИИ.
  final String setting;

  /// Ключевая лексика сцены (показывается в шапке).
  final List<String> vocab;

  /// Список детализированных под-сценариев.
  final List<SubScenario> subScenarios;
}

const scenarios = <Scenario>[
  Scenario(
    key: 'zabka',
    emoji: '🛒',
    title: 'В магазине Żabka / Biedronka',
    level: 'A1',
    npcRole: 'kasjer/kasjerka oraz pracownik w sklepie Żabka lub Biedronka',
    setting:
        'Klient robi zakupy w Żabce lub Biedronce. Przy kasie skanujesz artykuły, pytasz o torbę i kartę lojalnościową („Żappka” / „Moja Biedronka”). '
        'OBOWIĄZKOWO podajesz realistyczną kwotę do zapłaty SŁOWAMI (np. „Do zapłaty czterdzieści siedem złotych i osiemdziesiąt groszy”). '
        'Pytasz o formę płatności: „Płatność kartą, gotówką czy BLIKiem?”, wydajesz resztę i pytasz: „Czy potrzebny jest paragon fiskalny?”.',
    vocab: ['gdzie znajdę', 'w promocji', 'ile płacę', 'karta czy BLIK', 'paragon fiskalny', 'reszta'],
    subScenarios: [
      SubScenario(
        id: 'zabka_checkout',
        title: 'На касі (Żappka, пакет, BLIK)',
        description: 'Сканування покупок, застосунок Żappka, питання про пакет та оплата BLIK або карткою.',
        starterHintPl: 'Dzień dobry, mam aplikację Żappka i płacę BLIKiem.',
        starterHintUk: 'Добрий день, у мене є додаток Żappka і я плачу BLIKом.',
        starterHintRu: 'Добрый день, у меня приложение Żappka и я плачу BLIKом.',
        plotTwist: 'Terminal zbliżeniowy chwilowo odrzucił kartę, kasjer uprzejmie prosi o kod BLIK lub gotówkę.',
        vocab: ['Żappka', 'kod BLIK', 'reklamówka', 'paragon fiskalny', 'zbliżeniowo'],
      ),
      SubScenario(
        id: 'zabka_finding',
        title: 'Пошук товару та термін придатності',
        description: 'Пошук свіжого багета чи молока без лактози серед полиць та перевірка ціни за акцією.',
        starterHintPl: 'Przepraszam, gdzie znajdę świeże pieczywo i mleko bez laktozy?',
        starterHintUk: 'Перепрошую, де знайти свіжу випічку та безлактозне молоко?',
        starterHintRu: 'Извините, где найти свежую выпечку и безлактозное молоко?',
        plotTwist: 'Zwykłe mleko się skończyło, jest tylko roślinne owsiane albo dostawa przyjedzie za pół godziny.',
        vocab: ['bez laktozy', 'gdzie znajdę', 'termin ważności', 'gazetka promocyjna'],
      ),
      SubScenario(
        id: 'zabka_refund',
        title: 'Повернення або рекламація',
        description: 'Товар виявився пошкодженим або в чеку пробита невірна ціна без урахування знижки.',
        starterHintPl: 'Dzień dobry, na paragonie nabiła się inna cena niż na półce sklepu.',
        starterHintUk: 'Добрий день, у чеку вибило іншу ціну, ніж на полиці магазину.',
        starterHintRu: 'Добрый день, в чеке пробилась другая цена, чем на полке магазина.',
        plotTwist: 'Kasjer prosi o pokazanie paragonu z zakupu i potwierdza błąd promocyjny, oferując zwrot różnicy w gotówce.',
        vocab: ['reklamacja', 'błędna cena', 'paragon', 'korekta', 'zwrot różnicy'],
      ),
    ],
  ),
  Scenario(
    key: 'bank',
    emoji: '🏦',
    title: 'В банке PKO / IKO (открытие счёта)',
    level: 'A2',
    npcRole: 'doradca klienta w oddziale PKO Bank Polski',
    setting:
        'Klient przychodzi do banku otworzyć konto bankowe w Polsce. '
        'Witasz serdecznie („Dzień dobry, w czym mogę pomóc?”). '
        'Pytasz o paszport, numer PESEL oraz polski numer telefonu. '
        'Proponujesz „PKO Konto za Zero”, bezpłatną kartę debetową wielowalutową, '
        'pytasz o adres korespondencyjny do wysyłki karty. '
        'Tłumaczysz jak aktywować aplikację mobilną IKO, jak działa kod BLIK oraz jak ustawić PIN.',
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
        title: 'Відкриття рахунку та додаток IKO',
        description: 'Оформлення PKO Konto za Zero, отримання картки та реєстрація додатку IKO з кодом BLIK.',
        starterHintPl: 'Dzień dobry, chciałbym założyć konto osobiste i aktywować aplikację IKO.',
        starterHintUk: 'Добрий день, я хотів би відкрити особистий рахунок та активувати додаток IKO.',
        starterHintRu: 'Добрый день, я хотел бы открыть расчетный счет и активировать приложение IKO.',
        plotTwist: 'Doradca bankowy pyta o meldunek oraz prosi o podanie polskiego numeru telefonu do autoryzacji SMS.',
        vocab: ['PKO Konto za Zero', 'karta debetowa', 'aplikacja IKO', 'numer PESEL', 'autoryzacja'],
      ),
      SubScenario(
        id: 'bank_atm_blocked',
        title: 'Банкомат заблокував картку',
        description: 'Банкомат не повернув картку або транзакцію заблоковано системою безпеки банку.',
        starterHintPl: 'Dzień dobry, bankomat przy oddziale wciągnął moją kartę i jej nie zwrócił.',
        starterHintUk: 'Добрий день, банкомат біля відділення затягнув мою картку і не повернув її.',
        starterHintRu: 'Добрый день, банкомат у отделения затянул мою карту и не вернул ее.',
        plotTwist: 'Karta została zatrzymana ze względów bezpieczeństwa, doradca od ręki blokuje starą i generuje wirtualną w aplikacji IKO.',
        vocab: ['zablokowana karta', 'zatrzymana w bankomacie', 'karta wirtualna', 'zgłoszenie incydentu'],
      ),
      SubScenario(
        id: 'bank_statement_urzad',
        title: 'Виписка з печаткою для Urząd (Karta Pobytu)',
        description: 'Отримання офіційної виписки про стан рахунку та рух коштів з мокрою печаткою для відділу іноземців.',
        starterHintPl: 'Dzień dobry, potrzebuję oficjalny wyciąg z konta z pieczęcią banku do karty pobytu.',
        starterHintUk: 'Добрий день, мені потрібна офіційна виписка з рахунку з печаткою банку для карти побиту.',
        starterHintRu: 'Добрый день, мне нужна официальная выписка со счета с печатью банка для карты побыту.',
        plotTwist: 'Zwykły wydruk z bankowości internetowej nie wystarczy, urzędnik generuje papierowe zaświadczenie z pieczęcią z opłatą manipulacyjną.',
        vocab: ['wyciąg z konta', 'zaświadczenie o saldzie', 'pieczęć bankowa', 'karta pobytu', 'opłata'],
      ),
    ],
  ),
  Scenario(
    key: 'cafe',
    emoji: '☕',
    title: 'Заказ в кафе',
    level: 'A1',
    npcRole: 'kelner/kelnerka w kawiarni',
    setting:
        'Klient zamawia kawę i deser. Pytasz o rodzaj kawy, mleko (zwykłe/owsiane), na miejscu czy na wynos. '
        'Przy prośbie o rachunek pytasz: „Płacimy razem czy osobno?”. '
        'OBOWIĄZKOWO podajesz pełną sumę słowami (np. „To będzie dwadzieścia trzy złote i pięćdziesiąt groszy”). '
        'Pytasz: „Płatność kartą, gotówką czy BLIKiem?”, czy doliczyć napiwek oraz czy wydrukować paragon.',
    vocab: ['na wynos', 'na miejscu', 'poproszę rachunek', 'płacimy osobno', 'doliczyć napiwek'],
    subScenarios: [
      SubScenario(
        id: 'cafe_order',
        title: 'Замовлення кави та десерту',
        description: 'Вибір столика, кава з молоком (вівсяне/звичайне), тістечко та рахунок.',
        starterHintPl: 'Dzień dobry, poproszę cappuccino na mleku owsianym i szarlotkę.',
        starterHintUk: 'Добрий день, будь ласка, капучино на вівсяному молоці та шарлотку.',
        starterHintRu: 'Добрый день, пожалуйста, капучино на овсяном молоке и шарлотку.',
        plotTwist: 'Szarlotka właśnie się skończyła, kelner uśmiecha się i poleca świeży sernik krakowski z malinami.',
        vocab: ['mleko owsiane', 'szarlotka', 'sernik', 'rachunek', 'na wynos'],
      ),
      SubScenario(
        id: 'cafe_allergies',
        title: 'Алергії та особливості меню',
        description: 'Уточнення складу страв: без глютену, без горіхів або пісне/веганське меню.',
        starterHintPl: 'Przepraszam, czy te desery zawierają orzechy lub gluten? Mam alergię.',
        starterHintUk: 'Перепрошую, чи ці десерти містять горіхи або глютен? У мене алергія.',
        starterHintRu: 'Извините, эти десерты содержат орехи или глютен? У меня аллергия.',
        plotTwist: 'Kelner sprawdza tabelę alergenów w kuchni i informuje, że ciasto ma śladowe ilości glutenu, ale proponuje bezpieczny deser chia.',
        vocab: ['karta alergenów', 'bezglutenowe', 'orzechy', 'laktoza', 'bezpieczne danie'],
      ),
      SubScenario(
        id: 'cafe_split_bill',
        title: 'Роздільний рахунок та чайові',
        description: 'Розрахунок: окремі чеки, оплата частинами (картка + BLIK) та чайові.',
        starterHintPl: 'Poprosimy o rachunek, ale chcielibyśmy zapłacić osobno.',
        starterHintUk: 'Будь ласка, рахунок, але ми хотіли б заплатити окремо.',
        starterHintRu: 'Пожалуйста, счет, но мы хотели бы заплатить раздельно.',
        plotTwist: 'Terminal wymaga osobnego wbicia każdej kwoty, kelner pyta czy doliczyć 10% serwisu lub dobrowolny napiwek.',
        vocab: ['płacimy osobno', 'podział rachunku', 'napiwek', 'terminal', 'razem'],
      ),
    ],
  ),
  Scenario(
    key: 'doctor',
    emoji: '🩺',
    title: 'У врача',
    level: 'A2',
    npcRole: 'lekarz rodzinny w przychodni POZ',
    setting:
        'Pacjent przychodzi z objawami (ból gardła, kaszel, gorączka). '
        'Pytasz o objawy, od kiedy trwają, czy ma alergie na leki. '
        'Badasz pacjenta, stawiasz diagnozę (infekcja wirusowa), '
        'wypisujesz e-receptę (podajesz 4-cyfrowy kod e-recepty do realizacji w aptece z numerem PESEL) '
        'oraz proponujesz zwolnienie lekarskie L4.',
    vocab: ['boli mnie gardło', 'mam gorączkę', 'e-recepta', 'kod recepty', 'zwolnienie L4'],
    subScenarios: [
      SubScenario(
        id: 'doctor_registry',
        title: 'Реєстрація у віконці (Rejestracja POZ)',
        description: 'Запис на прийом до терапевта, вибір часу, перевірка страховки NFZ чи e-WUŚ.',
        starterHintPl: 'Dzień dobry, chciałbym zapisać się do lekarza pierwszego kontaktu na dziś.',
        starterHintUk: 'Добрий день, я хотів би записатися до сімейного лікаря на сьогодні.',
        starterHintRu: 'Добрый день, я хотел бы записаться к терапевту на сегодня.',
        plotTwist: 'Na dziś nie ma już wolnych numerków do lekarza rodzinnego, rejestratorka proponuje wizytę popołudniową w trybie nagłym.',
        vocab: ['rejestracja', 'lekarz POZ', 'brak wolnych terminów', 'system e-WUŚ', 'PESEL'],
      ),
      SubScenario(
        id: 'doctor_consultation',
        title: 'Прийом у лікаря: симптоми та лікарняний L4',
        description: 'Огляд, скарги на кашель і температуру, аускультація легень та відкриття електронного лікарняного L4.',
        starterHintPl: 'Dzień dobry, od dwóch dni mam wysoką gorączkę i silny kaszel.',
        starterHintUk: 'Добрий день, вже два дні у мене висока температура та сильний кашель.',
        starterHintRu: 'Добрый день, уже два дня у меня высокая температура и сильный кашель.',
        plotTwist: 'Lekarz osłuchuje płuca, stwierdza ostre zapalenie oskrzeli, wystawia zwolnienie L4 na 7 dni i prosi o NIP pracodawcy.',
        vocab: ['gorączka', 'osłuchanie', 'zapalenie oskrzeli', 'zwolnienie L4', 'NIP pracodawcy'],
      ),
      SubScenario(
        id: 'doctor_pharmacy',
        title: 'В аптеці: 4-значний код e-recepty',
        description: 'Купівля ліків за електронним рецептом у польській аптеці, аналоги та дозування.',
        starterHintPl: 'Dzień dobry, mam kod do e-recepty oraz numer PESEL.',
        starterHintUk: 'Добрий день, у мене є код до е-рецепта та номер PESEL.',
        starterHintRu: 'Добрый день, у меня код к е-рецепту и номер PESEL.',
        plotTwist: 'Przepisany antybiotyk jest chwilowo niedostępny w tej dawce, farmaceuta proponuje tańszy polski zamiennik o identycznym składzie.',
        vocab: ['e-recepta', 'kod recepty', 'zamiennik', 'dawkowanie', 'antybiotyk'],
      ),
    ],
  ),
  Scenario(
    key: 'urzad',
    emoji: '🏛️',
    title: 'В Urząd (оформление документов)',
    level: 'A2',
    npcRole: 'urzędnik/urzędniczka w urzędzie gminy / dzielnicy',
    setting:
        'Uczeń przychodzi załatwić sprawę urzędową (meldunek, numer PESEL, karta pobytu). '
        'Pytasz o numerek z biletomatu, cel wizyty, weryfikujesz wniosek, paszport, umowę najmu mieszkania. '
        'Prosisz o czytelny podpis, informujesz o terminie odbioru dokumentu.',
    vocab: ['wniosek', 'dowód / paszport', 'meldunek', 'termin', 'podpis', 'umowa najmu'],
    subScenarios: [
      SubScenario(
        id: 'urzad_meldunek_pesel',
        title: 'Meldunek czasowy i nadanie numeru PESEL',
        description: 'Оформлення прописки за договором оренди квартири та отримання податкового/ідентифікаційного номера PESEL.',
        starterHintPl: 'Dzień dobry, przyszedłem złożyć wniosek o meldunek czasowy i numer PESEL.',
        starterHintUk: 'Добрий день, я прийшов подати заяву на тимчасову прописку та номер PESEL.',
        starterHintRu: 'Добрый день, я пришел подать заявление на временную регистрацию и номер PESEL.',
        plotTwist: 'W umowie najmu brakuje zgody właściciela lokalu lub podpisy nie są poświadczone, urzędnik wyjaśня procedurę uzupełnienia braków formalnych.',
        vocab: ['wniosek o meldunek', 'umowa najmu', 'potwierdzenie', 'numer PESEL', 'podpis'],
      ),
      SubScenario(
        id: 'urzad_karta_pobytu',
        title: 'Подача заяви на Karta Pobytu (Urząd Wojewódzki)',
        description: 'Подача пакету документів на ВНЖ, зняття відбитків пальців, додаток Załącznik nr 1 від роботодавця.',
        starterHintPl: 'Dzień dobry, mam bilet na złożenie wniosku o pobyt czasowy i pracę.',
        starterHintUk: 'Добрий день, у мене талон на подачу документів на тимчасовий побит і роботу.',
        starterHintRu: 'Добрый день, у меня талон на подачу документов на временный побыт и работу.',
        plotTwist: 'Jedno ze zdjęć ma zły format biometryczny lub brakuje potwierdzenia opłaty skarbowej (440 zł) — urzędnik kieruje do kasy na dole.',
        vocab: ['pobyt czasowy', 'odciski palców', 'opłata skarbowa', 'załącznik nr 1', 'karta pobytu'],
      ),
      SubScenario(
        id: 'urzad_pickup',
        title: 'Видача готового документа',
        description: 'Отримання виготовленої карти побиту, перевірка даних та розпис у реєстрі.',
        starterHintPl: 'Dzień dobry, dostałem SMS z informacją, że moja karta pobytu jest gotowa do odbioru.',
        starterHintUk: 'Добрий день, я отримав SMS з інформацією, що моя карта побиту готова до видачі.',
        starterHintRu: 'Добрый день, я получил SMS с уведомлением, что моя карта побыту готова к выдаче.',
        plotTwist: 'Przed wydaniem karty trzeba okazać stary paszport oraz zwrócić poprzednie zaświadczenie, po czym złożyć podpis na czytniku cyfrowym.',
        vocab: ['odbiór dokumentu', 'potwierdzenie SMS', 'czytnik cyfrowy', 'czytelny podpis'],
      ),
    ],
  ),
];
