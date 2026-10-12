class Scenario {
  const Scenario({
    required this.key,
    required this.emoji,
    required this.title,
    required this.level,
    required this.npcRole,
    required this.setting,
    required this.vocab,
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
}

const scenarios = <Scenario>[
  Scenario(
    key: 'zabka',
    emoji: '🛒',
    title: 'В магазине Żabka / Biedronka',
    level: 'A1',
    npcRole: 'kasjer/kasjerka oraz pracownik w sklepie Żabka lub Biedronka',
    setting:
        'Klient (uczeń) robi zakupy. Może najpierw zapytać w sali o produkty („Gdzie znajdę świeże pieczywo?”, „Czy to jest w promocji?”). '
        'Przy kasie skanujesz artykuły, pytasz o torbę, kartę lojalnościową („Żappka” / „Moja Biedronka”). '
        'OBOWIĄZKOWO podajesz realistyczną kwotę do zapłaty SŁOWAMI (np. „Do zapłaty czterdzieści siedem złotych i osiemdziesiąt groszy”). '
        'Pytasz o formę płatności: „Płatność kartą, gotówką czy BLIKiem?”, wydajesz resztę i pytasz: „Czy potrzebny jest paragon fiskalny?”.',
    vocab: ['gdzie znajdę', 'w promocji', 'ile płacę', 'karta czy BLIK', 'paragon fiskalny', 'reszta'],
  ),
  Scenario(
    key: 'bank',
    emoji: '🏦',
    title: 'В банке PKO / IKO (открытие счёта)',
    level: 'A2',
    npcRole: 'doradca klienta w oddziale PKO Bank Polski',
    setting:
        'Klient (uczeń) przychodzi do banku otworzyć konto bankowe w Polsce. '
        'Witasz serdecznie („Dzień dobry, w czym mogę pomóc?”). '
        'Pytasz o paszport, numer PESEL oraz polski numer telefonu. '
        'Proponujesz „PKO Konto za Zero”, bezpłatną kartę debetową wielowalutową, '
        'pytasz o adres korespondencyjny do wysyłki karty. '
        'Tłumaczysz jak aktywować aplikację mobilną IKO, jak działa kod BLIK (płatności w sklepach i wypłaty z bankomatów) '
        'oraz jak ustawić PIN. Używaj fikcyjnych danych, nie pytaj o prawdziwe dane osobowe.',
    vocab: [
      'otworzyć konto',
      'karta debetowa',
      'aplikacja IKO',
      'kod BLIK',
      'numer PESEL',
      'wypłata z bankomatu'
    ],
  ),
  Scenario(
    key: 'cafe',
    emoji: '☕',
    title: 'Заказ в кафе',
    level: 'A1',
    npcRole: 'kelner/kelnerka w kawiarni',
    setting:
        'Klient (uczeń) zamawia kawę i deser. Pytasz o rodzaj kawy, mleko (zwykłe/owsiane), na miejscu czy na wynos. '
        'Przy prośbie o rachunek pytasz: „Płacimy razem czy osobno?”. '
        'OBOWIĄZKOWO podajesz pełną sumę słowami (np. „To będzie dwadzieścia trzy złote i pięćdziesiąt groszy”). '
        'Pytasz: „Płatność kartą, gotówką czy BLIKiem?”, czy doliczyć napiwek oraz czy wydrukować paragon.',
    vocab: ['na wynos', 'na miejscu', 'poproszę rachunek', 'płacimy osobno', 'doliczyć napiwek'],
  ),
  Scenario(
    key: 'doctor',
    emoji: '🩺',
    title: 'У врача',
    level: 'A2',
    npcRole: 'lekarz rodzinny w przychodni POZ',
    setting:
        'Pacjent (uczeń) przychodzi z objawami (ból gardła, kaszel, gorączka). '
        'Pytasz o objawy, od kiedy trwają, czy ma alergie na leki. '
        'Badasz pacjenta, stawiasz diagnozę (infekcja wirusowa), '
        'wypisujesz e-receptę (podajesz 4-cyfrowy kod e-recepty do realizacji w aptece z numerem PESEL) '
        'oraz proponujesz zwolnienie lekarskie L4.',
    vocab: ['boli mnie gardło', 'mam gorączkę', 'e-recepta', 'kod recepty', 'zwolnienie L4'],
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
        'Prosisz o czytelny podpis, informujesz o terminie odbioru dokumentu. Używaj fikcyjnych danych.',
    vocab: ['wniosek', 'dowód / paszport', 'meldunek', 'termin', 'podpis', 'umowa najmu'],
  ),
];
