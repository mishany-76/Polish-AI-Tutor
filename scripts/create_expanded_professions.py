# -*- coding: utf-8 -*-
import sys

def main():
    content = []
    content.append("import '../tutor/scenarios.dart';")
    content.append("import 'profession_model.dart';\n")

    # Helper function to format ProfessionVocab
    def vocab(term, uk, ru, ex_pl, ex_uk, ex_ru):
        return f"""    ProfessionVocab(
      termPl: '{term}',
      translationUk: '{uk}',
      translationRu: '{ru}',
      examplePl: '{ex_pl}',
      exampleUk: '{ex_uk}',
      exampleRu: '{ex_ru}',
    ),"""

    # 1. LOGISTICS (32 terms)
    logistics_vocabs = [
        ("list przewozowy CMR", "міжнародна накладна CMR", "международная накладная CMR", "Poproszę o podpis i pieczątkę na liście przewozowym CMR.", "Будь ласка, підпис і печатку на накладній CMR.", "Пожалуйста, подпись и печать на накладной CMR."),
        ("rampa załadunkowa", "вантажна рампа / док", "погрузочная рампа / док", "Proszę podstawić naczepę pod rampę numer cztery.", "Будь ласка, підженіть причіп під рампу номер чотири.", "Пожалуйста, подайте полуприцеп под рампу номер четыре."),
        ("wózek widłowy", "вилковий навантажувач (кар)", "вилочный погрузчик (кар)", "Magazynier rozładowuje palety wózkiem widłowym.", "Комірник розвантажує палети вилковим навантажувачем.", "Кладовщик разгружает паллеты вилочным погрузчиком."),
        ("pasy transportowe", "стяжні ремені кріплення вантажу", "стяжные ремни крепления груза", "Muszę zabezpieczyć ładunek pasami transportowymi.", "Я мушу закріпити вантаж стяжними ременями.", "Я должен закрепить груз стяжными ремнями."),
        ("tachograf i pauза", "тахограф та обов’язковий відпочинок", "тахограф и обязательный отдых (пауза)", "Kończy mi się czas jazdy, muszę zrobić pauzę 45 minut.", "У мене закінчується час їзди, мушу зробити паузу 45 хвилин.", "У меня заканчивается время вождения, должен сделать паузу 45 минут."),
        ("awizacja załadunku", "авізація / час прибуття на склад", "авизация / время прибытия на склад", "Mam awizację na godzinę czternastą trzydzieści.", "У мене авізація на чотирнадцяту тридцять.", "У меня авизация на четырнадцать тридцать."),
        ("uszkodzona paleta", "пошкоджена палета / коробка", "повреждённая паллета / коробка", "Karton na palecie jest wgnieciony, wpisuję zastrzeżenie do protokołu.", "Коробка на палеті прим’ята, вношу зауваження до протоколу.", "Коробка на паллете помята, вношу замечание в протокол."),
        ("paleta przemysłowa / euro", "європалета (120x80) / промислова палета", "европаллета (120x80) / промышленная паллета", "Na naczepie mieści się dokładnie trzydzieści trzy europalety.", "У напівпричепі вміщується рівно 33 європалети.", "В полуприцепе помещается ровно 33 европаллеты."),
        ("owijarka do palet", "палетообмотувач / стрейч-машина", "паллетообмотчик / стрейч-машина", "Owiń tę paletę folią stretch przed załadunkiem.", "Обмотай цю палету стрейч-плівкою перед завантаженням.", "Обмотай эту паллету стрейч-плёнкой перед погрузкой."),
        ("skaner magazynowy (kolektor)", "сканер штрих-кодів / термінал ТЗД", "складской сканер штрих-кодов / терминал ТСД", "Mój skaner się rozładował, muszę wymienić baterię w doku.", "Мій сканер розрядився, мушу замінити акумулятор на док-станції.", "Мой сканер разрядился, нужно заменить батарею на док-станции."),
        ("strefa kompletacji", "зона комплектації замовлень (пікінг)", "зона комплектации заказов (пикинг)", "Pobierz zamówienie ze strefy kompletacji B-12.", "Візьми замовлення із зони комплектації B-12.", "Забери заказ из зоны комплектации B-12."),
        ("etykieta adresowa", "адресна транспортна наклейка", "адресная транспортная этикетка", "Naklej etykietę z kodem kreskowym na krótszy bok kartonu.", "Наклей етикетку зі штрих-кодом на коротший бік коробки.", "Наклей этикетку со штрих-кодом на короткую сторону коробки."),
        ("zwrot przesyłki", "повернення посилки / відмова клієнта", "возврат посылки / отказ получателя", "Klient odmówił przyjęcia paczki z powodu uszkodzenia.", "Клієнт відмовився приймати посилку через пошкодження.", "Клиент отказался принимать посылку из-за повреждения."),
        ("dyspozytor / spedytor", "диспетчер / експедитор рейсу", "диспетчер / экспедитор рейса", "Dyspozytor zmienił adres kolejnego rozładunku.", "Диспетчер змінив адресу наступного розвантаження.", "Диспетчер изменил адрес следующей выгрузки."),
        ("plomba transportowa", "вантажна номерна пломба", "номерная грузовая пломба", "Numer plomby musi zgadzać się z numerem w liście CMR.", "Номер пломби повинен збігатися з номером у CMR.", "Номер пломбы обязан совпадать с номером в CMR."),
        ("waga brutto / tara", "вага брутто та маса тари", "вес брутто и вес тары", "Masa całkowita pojazdu nie może przekraczać 40 ton.", "Повна маса автопоїзда не може перевищувати 40 тонн.", "Полная масса автопоезда не может превышать 40 тонн."),
        ("rozładunek bokiem / tyłem", "бокове або заднє розвантаження", "боковая или задняя выгрузка", "Muszę rozpiąć firankę, bo rozładunek będzie bokiem.", "Мушу розстебнути шторний тент, бо розвантаження буде збоку.", "Нужно расчехлить штору, потому что выгрузка будет сбоку."),
        ("kontrola drogowa ITD", "контроль інспекції ITD", "дорожный контроль польской инспекции ITD", "Inspektor ITD prosi o prawo jazdy, kartę kierowcy i wydruk z tachografu.", "Інспектор ITD просить посвідчення водія, карту та роздруківку тахографа.", "Инспектор ITD просит права, чип-карту водителя и распечатку тахографа."),
        ("mandat karny", "штраф / протокол про порушення", "штраф / квитанция штрафа", "Czy mogę opłacić mandat kartą płatniczą na miejscu?", "Чи можу я оплатити штраф платіжною карткою на місці?", "Могу я оплатить штраф картой на месте?"),
        ("winieta drogowa / e-TOLL", "оплата польських доріг e-TOLL", "система оплаты дорог e-TOLL", "Urządzenie pokładowe e-TOLL świeci na zielono, opłata pobrana.", "Бортовий пристрій e-TOLL світить зеленим, плату знято.", "Бортовое устройство e-TOLL горит зелёным, оплата списана."),
        ("strefa wysokiego składu", "стелажі високого складування", "стеллажи высокого складирования", "Tylko uprawnieni operatorzy mogą pracować w strefie wysokiego składu.", "Тільки сертифіковані оператори можуть працювати на висотному складі.", "Только сертифицированные операторы могут работать на высотном складе."),
        ("odbiór za pobraniem (COD)", "доставка з післяплатою (накладений платіж)", "доставка с наложенным платежом", "Paczka jest za pobraniem, kwota wynosi sto pięćdziesiąt złotych.", "Посилка з післяплатою, сума 150 злотих.", "Посылка с оплатой при получении, сумма 150 злотых."),
        ("paleciak ręczny", "ручна рохля / гідравлічний візок", "ручная гидравлическая тележка (рохля)", "Gdzie zostawiłeś paleciak ręczny po rozładunku?", "Де ти залишив ручну рохлю після розвантаження?", "Где ты оставил ручную рохлю после разгрузки?"),
        ("awaria chłodni (agregatu)", "поломка холодильного агрегату", "поломка холодильного агрегата", "Temperatura w chłodni wzrosła do plus ośmiu stopni, zgłaszam awarię.", "Температура в рефрижераторі зросла до +8°C, повідомляю про аварію.", "Температура в рефрижераторе поднялась до +8°C, сообщаю об аварии."),
        ("magazyn celny", "митний ліцензійний склад", "таможенный склад временного хранения", "Towar spoza Unii musi trafić najpierw do magazynu celnego.", "Вантаж з-поза меж ЄС має надійти спочатку на митний склад.", "Груз из-за пределов ЕС должен поступить сначала на таможенный склад."),
        ("protokół szkody", "акт про пошкодження вантажу", "акт о повреждении груза", "Spiszmy protokół szkody przed podpisaniem odbioru.", "Складімо акт пошкодження перед підписанням отримання.", "Давайте составим акт повреждения перед подписанием приёмки."),
        ("baza transportowa", "автотранспортна база / автопарк", "автотранспортная база / автопарк", "Wracam na bazę w piątek wieczorem.", "Повертаюся на базу в п’ятницю ввечері.", "Возвращаюсь на автобазу в пятницу вечером."),
        ("zabezpieczenie narożnikami", "захисні пластикові кутики під ремені", "защитные пластиковые уголки под ремни", "Użyj narożników ochronnych, żeby pasy nie zgniotły kartonów.", "Використай захисні кутики, щоб ремені не розчавили коробки.", "Используй защитные уголки, чтобы ремни не помяли коробки."),
        ("strefa załadunku", "зона завантаження та вивантаження", "зона погрузки и разгрузки", "Zakaz wstępu osobom nieupoważnionym do strefy załadunku.", "Вхід стороннім особам у зону завантаження заборонено.", "Вход посторонним в зону погрузки воспрещён."),
        ("termin dostawy", "узгоджений термін доставки (тайм-слот)", "согласованный срок доставки (тайм-слот)", "Czy zdążymy z dostawą przed zamknięciem magazynu o osiemnastej?", "Чи встигнемо ми з доставкою до закриття складу о 18:00?", "Успеем ли мы с доставкой до закрытия склада в 18:00?"),
        ("przepustka wjazdowa", "перепустка на в’їзд на територію", "пропуск на въезд на территорию", "Ochrona na bramie wydała mi przepustkę wjazdową.", "Охорона на КПП видала мені перепустку на в’їзд.", "Охрана на КПП выдала мне пропуск на въезд."),
        ("ubezpieczenie OCP przewoźnika", "страхування цивільної відповідальності OCP", "страхование ответственности перевозчика OCP", "Nasz ładunek jest objęty pełną polisą OCP.", "Наш вантаж покривається повним полісом OCP.", "Наш груз покрывается полным полисом OCP."),
    ]

    # Format professionLogistics
    content.append("const professionLogistics = ProfessionItem(")
    content.append("  id: 'logistics',")
    content.append("  emoji: '🚚',")
    content.append("  titlePl: 'Logistyka, Kierowcy i Magazyn',")
    content.append("  titleUk: 'Логістика, водії та склад',")
    content.append("  titleRu: 'Логистика, водители и склад',")
    content.append("  descPl: 'Załadunek, listy przewozowe CMR, kontakt ze spedytorem, rampa, wózek i kontrola ITD.',")
    content.append("  descUk: 'Завантаження, накладні CMR, зв’язок з експедитором, рампа, навантажувач та контроль інспекції ITD.',")
    content.append("  descRu: 'Погрузка, накладные CMR, связь с экспедитором, рампа, погрузчик и дорожный контроль инспекции ITD.',")
    content.append("  vocabulary: [")
    for v in logistics_vocabs:
        content.append(vocab(*v))
    content.append("  ],")
    content.append("""  scenario: Scenario(
    key: 'prof_logistics',
    emoji: '🚚',
    titlePl: 'Logistyka i Magazyn',
    titleUk: 'Логістика та Склад',
    titleRu: 'Логистика и Склад',
    level: 'B1',
    npcRole: 'dyspozytor lub magazynier w polskiej firmie logistycznej',
    setting: 'Rozmowa na rampie, kontakt ze spedytorem i kontrola ITD.',
    vocab: ['rampa', 'CMR', 'awizacja', 'opóźnienie', 'tachograf'],
    subScenarios: [
      SubScenario(
        id: 'logistics_ramp',
        titlePl: 'Rozmowa na rampie magazynowej',
        titleUk: 'Розмова на рампі складу',
        titleRu: 'Разговор на погрузочной рампе склада',
        descPl: 'Podstawienie naczepy, awizacja i weryfikacja uszkodzonych palet.',
        descUk: 'Подача напівпричепа, авізація та фіксація пошкоджених палет.',
        descRu: 'Подача полуприцепа, авизация и фиксация повреждённых паллет.',
        starterHintPl: 'Dzień dobry, przywiozłem ładunek z Niemiec, mam awizację na trzynastą. Pod którą rampę mam podstawić?',
        starterHintUk: 'Доброго дня, привіз вантаж із Німеччини, маю авізацію на тринадцяту. Під яку рампу під’їжджати?',
        starterHintRu: 'Добрый день, привёз груз из Германии, у меня авизация на час дня. Под какую рампу подавать?',
        plotTwist: 'Magazynier zauważa, że jedna paleta jest przekrzywiona i żąda wpisu do CMR.',
        vocab: ['rampa', 'awizacja', 'uszkodzenie', 'podpis', 'pieczątka'],
        npcRole: 'Magazynier przyjmujący dostawę',
        setting: 'Hałaśliwy dok przeładunkowy w centrum logistycznym pod Poznaniem.',
        npcFirstStarterPl: 'Dzień dobry. Proszę dokumenty przewozowe i numer awizacji. Co pan przywiózł?',
        npcFirstStarterUk: 'Доброго дня. Будь ласка, документи та номер авізації. Що привезли?',
        npcFirstStarterRu: 'Добрый день. Пожалуйста, транспортные документы и номер авизации. Что привезли?',
      ),
      SubScenario(
        id: 'logistics_dispatcher',
        titlePl: 'Telefon do spedytora: korekta trasy',
        titleUk: 'Дзвінок експедитору: коригування маршруту',
        titleRu: 'Звонок экспедитору: пробка и изменение маршрута',
        descPl: 'Korekta trasy z powodu wypadku na autostradzie A2 i kończącego się czasu pracy.',
        descUk: 'Коригування маршруту через ДТП на автомагістралі A2 та ліміт часу.',
        descRu: 'Корректировка маршрута из-за аварии на автобане A2 и лимита времени.',
        starterHintPl: 'Cześć Marek, stoję w korku na A2 przed węzłem Stryków. Nie zdążę przed szesnastą na rozładunek.',
        starterHintUk: 'Привіт Марек, стою в заторі на A2 перед Стрикувом. Не встигну до 16:00 на розвантаження.',
        starterHintRu: 'Привет Марек, стою в пробке на A2 перед Стрыкувом. Не успею до 16:00 на выгрузку.',
        plotTwist: 'Klient grozi karą umowną za spóźnienie, jeśli towar nie dojedzie dzisiaj.',
        vocab: ['korek', 'pauza', 'opóźnienie', 'rozładunek', 'awizacja'],
        npcRole: 'Spedytor koordynujący flotę',
        setting: 'Kabina ciężarówki na zatłoczonej autostradzie, rozmowa przez zestaw głośnomówiący.',
        npcFirstStarterPl: 'Cześć! Widzę na GPS, że zwolniłeś. Co się dzieje na trasie?',
        npcFirstStarterUk: 'Привіт! Бачу по GPS, що ти сповільнився. Що там відбувається на трасі?',
        npcFirstStarterRu: 'Привет! Вижу по GPS, что ты замедлился. Что там происходит на трассе?',
      ),
      SubScenario(
        id: 'logistics_itd_control',
        titlePl: 'Kontrola drogowa ITD na MOP-ie',
        titleUk: 'Перевірка інспекції ITD на стоянці MOP',
        titleRu: 'Дорожный контроль инспекции ITD на стоянке MOP',
        descPl: 'Weryfikacja tachografu, czasu jazdy, zabezpieczenia ładunku i dokumentów.',
        descUk: 'Перевірка тахографа, режиму праці, кріплення вантажу та документів водія.',
        descRu: 'Проверка тахографа, времени вождения, крепления груза и документов водителя.',
        starterHintPl: 'Dzień dobry panie inspektorze. Oto prawo jazdy, karta kierowcy, dowód rejestracyjny i list CMR.',
        starterHintUk: 'Доброго дня, пане інспекторе. Ось посвідчення, карта водія, техпаспорт і CMR.',
        starterHintRu: 'Добрый день, господин инспектор. Вот права, карта водителя, техпаспорт и накладная CMR.',
        plotTwist: 'Inspektor twierdzi, że jeden pas transportowy jest zbyt luźny.',
        vocab: ['karta kierowcy', 'tachograf', 'przegląd', 'mandat', 'zabezpieczenie'],
        npcRole: 'Młodszy inspektor transportu drogowego',
        setting: 'Parking MOP przy drodze ekspresowej S8.',
        npcFirstStarterPl: 'Inspekcja Transportu Drogowego, młodszy inspektor Nowak. Proszę wyłączyć silnik i okazać dokumenty do kontroli.',
        npcFirstStarterUk: 'Інспекція дорожнього транспорту, інспектор Новак. Вимкніть двигун та покажіть документи для контролю.',
        npcFirstStarterRu: 'Инспекция дорожного транспорта, инспектор Новак. Выключите двигатель и покажите документы для проверки.',
      ),
    ],
  ),
);""")

    # 2. CONSTRUCTION (32 terms)
    construction_vocabs = [
        ("zasady BHP na budowie", "правила безпеки праці (BHP)", "правила безопасности труда (BHP)", "Na placu budowy obowiązuje bezwzględny nakaz noszenia kasku i kamizelki.", "На будмайданчику діє суворий наказ носити каску та жилет.", "На стройплощадке действует строгий приказ носить каску и жилет."),
        ("kask ochronny i kamizelka", "захисна каска та світловідбивний жилет", "защитная каска и светоотражающий жилет", "Bez kasku i kamizelki odblaskowej kierownik nie wpuści cię na teren.", "Без каски та жилета виконроб не пустить тебе на територію.", "Без каски и жилета прораб не впустит тебя на территорию."),
        ("szpachla i gładź gipsowa", "шпатель та фінішна шпаклівка", "шпатель и финишная шпаклёвка", "Przed malowaniem musimy nałożyć dwie warstwy gładzi szpachlowej.", "Перед фарбуванням мусимо нанести два шари фінішної шпаклівки.", "Перед покраской нужно нанести два слоя финишной шпаклёвки."),
        ("rusztowanie elewacyjne", "фасадні риштування (ліси)", "фасадные строительные леса", "Rusztowanie zostało odebrane przez inspektora nadzoru budowlanego.", "Фасадні риштування прийняв інспектор будівельного нагляду.", "Строительные леса приняты инспектором строительного надзора."),
        ("wkrętarka akumulatorowa", "акумуляторний шуруповерт", "аккумуляторный шуруповёрт", "Pożycz mi wkrętarkę, muszę przykręcić płyty karton-gips.", "Позич мені шуруповерт, треба прикрутити гіпсокартон.", "Одолжи шуруповёрт, нужно прикрутить гипсокартон."),
        ("kierownik budowy / majster", "виконроб / майстер ділянки", "прораб / мастер участка", "Majster kazał poprawić zbrojenie przed przyjazdem betoniarki.", "Майстер велів поправити армування перед приїздом бетономішалки.", "Прораб велел поправить армирование перед приездом бетономешалки."),
        ("pomiary i poziomica", "виміри та будівельний рівень", "замеры и строительный уровень", "Sprawdź poziomicą, czy ściana trzyma pion.", "Перевір рівнем, чи стіна тримає вертикаль.", "Проверь уровнем, держит ли стена вертикаль."),
        ("wiertarka udarowa (młotowiertarka)", "перфоратор / ударний дриль", "перфоратор / ударная дрель", "Użyj młotowiertarki SDS, bo ten beton jest bardzo twardy.", "Використай перфоратор SDS, бо цей бетон дуже міцний.", "Используй перфоратор SDS, потому что этот бетон очень твёрдый."),
        ("płyta gipsowo-kartonowa (karton-gips)", "гіпсокартонна плита (ГКЛ)", "гипсокартонный лист (ГКЛ)", "Do łazienki bierzemy zielone płyty odporne na wilgoć.", "У ванну кімнату беремо зелений вологостійкий гіпсокартон.", "В ванную берём зелёный влагостойкий гипсокартон."),
        ("klej do płytek (kafelków)", "клей для керамічної плитки", "плиточный клей", "Rozmieszaj worek kleju w wiadrze mieszadłem wolnoobrotowym.", "Розмішай мішок клею у відрі міксером на малих обертах.", "Замешай мешок клея в ведре тихоходным миксером."),
        ("fuga do spoinowania", "затирка для швів (фуга)", "затирка для швов (фуга)", "Po ułożeniu terakoty dobierzemy fugę pod kolor płytek.", "Після укладання плитки підберемо затирку в колір.", "После укладки плитки подберём затирку в цвет плитки."),
        ("wylewka samopoziomująca", "самовирівнююча стяжка підлоги", "самовыравнивающаяся стяжка пола", "Wylewka musi schnąć przynajmniej czterdzieści osiem godzin.", "Самовирівнююча стяжка має сохнути щонайменше 48 годин.", "Стяжка должна сохнуть минимум сорок восемь часов."),
        ("betoniarka i gruszka z betonem", "бетонозмішувач та автобетонозмішувач", "бетономешалка и миксер с бетоном", "Gruszka z betonem B25 przyjedzie jutro o ósmej rano.", "Міксер із бетоном B25 приїде завтра о 8:00 ранку.", "Миксер с бетоном B25 приедет завтра в 8:00 утра."),
        ("zbrojenie i drut wiązałkowy", "арматурний каркас та в’язальний дріт", "арматурный каркас и вязальная проволока", "Zwiąż pręty zbrojeniowe drutem wiązałkowym co dwadzieścia centymetrów.", "Зв’яжи арматуру в’язальним дротом кожні 20 см.", "Свяжи арматуру вязальной проволокой через каждые 20 см."),
        ("szlifierka kątowa (kątówka)", "кутова шліфувальна машина (болгарка)", "угловая шлифовальная машина (болгарка)", "Załóż okulary ochronne przed cięciem profili kątówką.", "Одягни захисні окуляри перед різкою профілів болгаркою.", "Надень защитные очки перед резкой профилей болгаркой."),
        ("przewody instalacji elektrycznej", "кабелі електропроводки", "провода электропроводки", "Układamy peszle pod kable w bruzdach ściennych.", "Укладаємо гофру під кабелі у штробах стін.", "Укладываем гофру под кабели в штробах стен."),
        ("rury kanalizacyjne i hydraulika", "каналізаційні труби та сантехніка", "канализационные трубы и сантехника", "Próba szczelności instalacji wodnej wypadła pomyślnie.", "Випробування водопроводу на тиск пройшло успішно.", "Опрессовка системы водоснабжения прошла успешно."),
        ("wełna mineralna do ociepleń", "мінеральна вата для теплоізоляції", "минеральная вата для утепления", "Poddasze ocieplamy wełną mineralną o grubości piętnastu centymetrów.", "Мансарду утеплюємо мінватою товщиною 15 см.", "Мансарду утепляем минватой толщиной 15 см."),
        ("szalunek i stemple", "опалубка та телескопічні будівельні стійки", "опалубка и телескопические строительные стойки", "Szalunki stropowe muszą być solidnie podparte stemplami.", "Опалубка перекриття повинна надійно спиратися на стійки.", "Опалубка перекрытия должна быть надёжно подпёрта стойками."),
        ("nadproże okienne", "віконна перемичка", "оконная перемычка", "Ułóż gotowe nadproże prefabryковаne nad otworem okiennym.", "Поклади готову перемичку над віконним отвором.", "Уложи готовую перемычку над оконным проёмом."),
        ("kosztorys i przedmiar robót", "будівельний кошторис та відомість обсягів", "строительная смета и ведомость объёмов", "Inwestor zaakceptował dodatkowy kosztorys na tynki.", "Замовник погодив додатковий кошторис на штукатурку.", "Заказчик утвердил дополнительную смету на штукатурку."),
        ("odbiór techniczny lokalu", "технічна прийомка робіт замовником", "техническая приёмка работ заказчиком", "Komisja sprawdza kąty proste i gładkość ścian.", "Комісія перевіряє прямі кути та гладкість стін.", "Комиссия проверяет прямые углы и ровность стен."),
        ("pianka montażowa", "монтажна піна (поліуретанова)", "монтажная пена (полиуретановая)", "Wypełnij szczeliny wokół ościeżnicy pianką pistoletową.", "Заповни щілини навколо дверної коробки піною з пістолета.", "Заполни щели вокруг дверной коробки пеной из пистолета."),
        ("styropian grafitowy", "фасадний графітовий пінопласт", "фасадный графитовый пенопласт", "Do ocieplenia elewacji używamy styropianu grafitowego lambda 031.", "Для фасаду використовуємо графітовий пінопласт лямбда 031.", "Для фасада используем графитовый пенопласт с лямбдой 031."),
        ("siatka podtynkowa i klej", "армувальна сітка для фасаду та клей", "армирующая фасадная сетка и клей", "Zatop siatkę z włókna szklanego w warstwie kleju bez fałd.", "Втопи склосітку в шарі клею рівно без зморшок.", "Утопи стеклосетку в слое клея ровно без складок."),
        ("zagęszczarka do gruntu", "віброплита для трамбування ґрунту", "виброплита для трамбовки грунта", "Ubiliśmy podsypkę piaskową pod chudy beton zagęszczarką.", "Утрамбували піщану подушку під підбітонку віброплитою.", "Утрамбовали песчаную подушку под подбетонку виброплитой."),
        ("tarcza diamentowa do betonu", "алмазний відрізний диск по бетону", "алмазный отрезной диск по бетону", "Załóż tarczę diamentową do cięcia dylatacji w posadzce.", "Постав алмазний диск для нарізки швів у підлозі.", "Установи алмазный диск для нарезки швов в стяжке."),
        ("bruзdownica z odkurzaczem", "штроборіз із будівельним пилососом", "штроборез со строительным пылесосом", "Bruзdownica pozwala ciąć kanały pod kable bez kurzu.", "Штроборіз дозволяє різати канавки під дроти без пилу.", "Штроборез позволяет резать канавки под кабели без пыли."),
        ("taśma miernicza (miara zwijana)", "будівельна рулетка", "строительная рулетка", "Podaj mi miarę pięciometrową, muszę zmierzyć rozstaw belek.", "Дай мені п’ятиметрову рулетку поміряти крок балок.", "Подай пятиметровую рулетку измерить шаг балок."),
        ("silikon sanitarny", "сантехнічний протигрибковий силікон", "сантехнический противогрибковый силикон", "Uszczelnij krawędź brodzika silikonem bezbarwnym.", "Засиліконь край душового піддона прозорим силіконом.", "Загерметизируй край душевого поддона прозрачным силиконом."),
        ("grunt głęboko penetrujący", "ґрунтовка глибокого проникнення", "грунтовка глубокого проникновения", "Przed tynkowaniem trzeba zagruntować chłonny gazobeton.", "Перед штукатуркою треба заґрунтувати пористий газоблок.", "Перед штукатуркой нужно загрунтовать впитывающий газобетон."),
        ("odzież ochronna i nakolanniki", "спецодяг та наколінники плиточника", "спецодежда и наколенники плиточника", "Przy układaniu gresu nakolanniki chronią stawy.", "При укладанні керамограніту наколінники бережуть суглоби.", "При укладке керамогранита наколенники защищают суставы."),
    ]

    content.append("const professionConstruction = ProfessionItem(")
    content.append("  id: 'construction',")
    content.append("  emoji: '🏗️',")
    content.append("  titlePl: 'Budownictwo i Wykończenia',")
    content.append("  titleUk: 'Будівництво та оздоблення',")
    content.append("  titleRu: 'Строительство и отделка',")
    content.append("  descPl: 'BHP, rusztowania, szpachlowanie, instalacje, narzędzia i rozmowa z majstrem.',")
    content.append("  descUk: 'Безпека BHP, риштування, шпаклювання, інструменти, монтаж та спілкування з виконробом.',")
    content.append("  descRu: 'Безопасность BHP, строительные леса, шпаклёвка, инструмент, монтаж и общение с прорабом.',")
    content.append("  vocabulary: [")
    for v in construction_vocabs:
        content.append(vocab(*v))
    content.append("  ],")
    content.append("""  scenario: Scenario(
    key: 'prof_construction',
    emoji: '🏗️',
    titlePl: 'Budownictwo i Remonty',
    titleUk: 'Будівництво та Ремонти',
    titleRu: 'Строительство и Ремонт',
    level: 'A2–B1',
    npcRole: 'kierownik budowy lub majster na polskiej budowie',
    setting: 'Odprawa BHP, zamówienie materiałów i odbiór prac przez kierownika budowy.',
    vocab: ['BHP', 'rusztowanie', 'kierownik', 'usterka', 'zaprawa'],
    subScenarios: [
      SubScenario(
        id: 'construction_bhp',
        titlePl: 'Odprawa BHP i przydział zadań na budowie',
        titleUk: 'Інструктаж з безпеки BHP та розподіл завдань',
        titleRu: 'Инструктаж по технике безопасности и план на день',
        descPl: 'Rozmowa z majstrem rano: stan rusztowań, uprząż i wykończenie ścian.',
        descUk: 'Ранкова розмова з майстром: стан риштувань, страхувальний пояс та завдання.',
        descRu: 'Утренний разговор с прорабом: состояние лесов, страховочный пояс и фронт работ.',
        starterHintPl: 'Dzień dobry panie majstrze, zgłaszam gotowość. Wszyscy mamy kaski i uprzęże do pracy na wysokości.',
        starterHintUk: 'Доброго дня, пане майстре, до роботи готові. Усі мають каски та страхувальні пояси.',
        starterHintRu: 'Добрый день, господин прораб, к работе готовы. У всех есть каски и страховочные пояса.',
        plotTwist: 'Kierownik wstrzymuje prace na zewnątrz z powodu silnego wiatru i deszczu.',
        vocab: ['BHP', 'kask', 'rusztowanie', 'uprząż', 'majster'],
        npcRole: 'Majster budowlany z 20-letnim stażem',
        setting: 'Kontener biurowy na dużym placu budowy osiedla mieszkaniowego.',
        npcFirstStarterPl: 'Dzień dobry panowie. Zanim wejdziecie na rusztowania, muszę sprawdzić wasze uprzęże i szkolenia BHP. Kto ma aktualne badania?',
        npcFirstStarterUk: 'Доброго дня, панове. Перш ніж підніметеся на риштування, перевірю страхування та інструктаж BHP. У кого свіжий медогляд?',
        npcFirstStarterRu: 'Добрый день, господа. Прежде чем полезете на леса, проверю страховку и инструктаж BHP. У кого свежий допуск?',
      ),
      SubScenario(
        id: 'construction_store',
        titlePl: 'Zakupy w markecie budowlanym na fakturę',
        titleUk: 'Закупівля в будівельному маркеті на фактуру',
        titleRu: 'Закупка в строймаркете по безналу на фактуру',
        descPl: 'Wybór właściwej gładzi, profili CD/UD, wkrętów i wystawienie faktury na firmę.',
        descUk: 'Підбір потрібної шпаклівки, профілів CD/UD, саморізів та оформлення фактури з ПДВ.',
        descRu: 'Подбор шпаклёвки, профилей CD/UD, саморезов и выписка фактуры на фирму с NIP.',
        starterHintPl: 'Dzień dobry, potrzebuję dwadzieścia worków gładzi polimerowej, profile CD 60 i paczkę wkrętów do karton-gipsu na fakturę.',
        starterHintUk: 'Доброго дня, мені потрібно 20 мішків шпаклівки, профілі CD 60 та пачку саморізів для гіпсокартону на фактуру.',
        starterHintRu: 'Добрый день, нужно 20 мешков полимерной шпаклёвки, профили CD 60 и пачку саморезов для гипсокартона на фактуру.',
        plotTwist: 'Towaru nie ma na stanie w magazynie głównym, trzeba czekać do jutra.',
        vocab: ['gładź', 'profile', 'wkręty', 'faktura', 'rabat'],
        npcRole: 'Doradca klienta w dziale budowlanym',
        setting: 'Dział materiałów sypkich i suchej zabudowy w hurtowni budowlanej.',
        npcFirstStarterPl: 'Dzień dobry. W czym mogę pomóc? Szuka pan gotowej gładzi w wiaderku czy sypkiej w workach?',
        npcFirstStarterUk: 'Доброго дня. Чим допомогти? Шукаєте готову шпаклівку у відрах чи суху в мішках?',
        npcFirstStarterRu: 'Добрый день. Чем помочь? Ищете готовую шпаклёвку в ведрах или сухую в мешках?',
      ),
      SubScenario(
        id: 'construction_inspection',
        titlePl: 'Odbiór prac wykończeniowych przez inwestora',
        titleUk: 'Здача оздоблювальних робіт замовнику',
        titleRu: 'Сдача отделочных работ заказчику квартиры',
        descPl: 'Weryfikacja kątów prostych, gładkości ścian i rozliczenie zaliczki.',
        descUk: 'Перевірка прямоти кутів, гладкості стін та підсумковий розрахунок за етап.',
        descRu: 'Проверка прямых углов, гладкости стен и окончательный расчёт за этап.',
        starterHintPl: 'Dzień dobry, zakończyliśmy szpachlowanie i gruntowanie. Zapraszam do odbioru przed malowaniem.',
        starterHintUk: 'Доброго дня, ми завершили шпаклювання та ґрунтування. Запрошую прийняти роботу перед фарбуванням.',
        starterHintRu: 'Добрый день, закончили шпаклёвку и грунтовку. Приглашаю принять работу перед покраской.',
        plotTwist: 'Inwestor zauważa małe zarysowanie pod oknem i proсить poprawić.',
        vocab: ['odbiór', 'kąt prosty', 'poprawka', 'rozliczenie', 'zaliczka'],
        npcRole: 'Właściciel mieszkania odbierający remont',
        setting: 'Jasny salon w nowo wyremontowanym apartamencie w stanie deweloperskim.',
        npcFirstStarterPl: 'Dzień dobry panie Michale. Przyniosłem lampę halogenową i poziomicę, żeby dokładnie obejrzeć gładzie pod światło.',
        npcFirstStarterUk: 'Доброго дня, пане Михайле. Я взяв галогенну лампу та рівень, щоб уважно оглянути шпаклівку під світлом.',
        npcFirstStarterRu: 'Добрый день, господин Михаил. Я взял галогеновую лампу и уровень, чтобы внимательно осмотреть шпаклёвку на просвет.',
      ),
    ],
  ),
);""")

    # 3. GASTRONOMY (32 terms)
    gastro_vocabs = [
        ("rachunek fiskalny", "фіскальний чек / рахунок", "фискальный чек / счёт", "Czy życzą sobie państwo rachunek razem czy osobno?", "Бажаєте спільний рахунок чи окремо?", "Вам общий счёт или раздельный?"),
        ("napiwek dla kelnera", "чайові офіціанту", "чаевые официанту", "Napiwek można doliczyć bezpośrednio do płatności kartą.", "Чайові можна додати прямо до оплати банківською карткою.", "Чаевые можно включить сразу в оплату картой."),
        ("rezerwacja stolika", "бронювання столика", "бронирование столика", "Mamy rezerwację na cztery osoby na nazwisko Wiśniewski.", "У нас бронь на чотирьох осіб на прізвище Вишневський.", "У нас бронь на четверых на фамилию Вишневский."),
        ("alergeny w menu", "алергени в стравах", "аллергены в блюдах", "Czy ten sos zawiera gluten, orzechy lub laktozę?", "Чи містить цей соус глютен, горіхи або лактозу?", "Содержит ли этот соус глютен, орехи или лактозу?"),
        ("danie bezglutenowe", "безглютенова страва", "безглютеновое блюдо", "Gość przy ósmym stoliku prosi o danie bezglutenowe.", "Гість за восьмим столиком просить страву без глютену.", "Гость за восьмым столиком просит блюдо без глютена."),
        ("wydawka kuchenna (bemas)", "кухонна роздача готових страв", "кухонная раздача готовых блюд", "Dwa razy schabowy i zupa pomidorowa gotowe na wydawce!", "Дві порції відбивних та томатний суп готові на роздачі!", "Две отбивные и томатный суп готовы на раздаче!"),
        ("karta dań i napojów", "меню ресторану", "меню ресторана", "Podaję kartę dań, za chwilę podejdę przyjąć zamówienie.", "Подаю меню, за хвильку підійду прийняти замовлення.", "Подаю меню, через минутку подойду принять заказ."),
        ("zamówienie na wynos", "замовлення із собою (на виніс)", "заказ с собой (на вынос)", "Pakujemy to danie na wynos w biodegradowalne pudełko.", "Пакуємо цю страву із собою в біорозкладну коробку.", "Упаковываем это блюдо с собой в эко-бокс."),
        ("terminal płatniczy", "платіжний термінал", "банковский платёжный терминал", "Płatność kartą, zbliżeniowo czy kodem BLIK?", "Оплата карткою безконтактно чи кодом BLIK?", "Оплата картой бесконтактно или кодом BLIK?"),
        ("faktura na firmę z NIP-em", "фактура на фірму з податковим номером NIP", "фактура на фирму с номером NIP", "Poproszę o fakturę VAT, podaję nasz firmowy numer NIP.", "Будь ласка, фактуру з ПДВ, ось наш номер NIP.", "Пожалуйста, фактуру с НДС, вот наш номер NIP."),
        ("sztućce i serwetki", "столові прибори та паперові серветки", "столовые приборы и бумажные салфетки", "Przyniosę czyste sztućce i dodatkowe serwetki.", "Я принесу чисті прибори та додаткові серветки.", "Я принесу чистые приборы и салфетки."),
        ("wysmażenie steka (krwisty / średni)", "ступінь просмаження стейка", "степень прожарки стейка", "Jak wysmażony ma być stek: krwisty (rare) czy średni (medium)?", "Яке просмаження стейка бажаєте: з кров’ю чи середнє?", "Какую прожарку стейка предпочитаете: с кровью или среднюю?"),
        ("wyparzarka do naczyń", "промислова посудомийна машина з дезінфекцією", "промышленная посудомоечная машина", "Wszystkie szklanki muszą przejść przez wyparzarkę w temperaturze 90 stopni.", "Усі келихи повинні пройти через ошпарювач при 90°C.", "Все бокалы должны пройти через стерилизатор при 90°C."),
        ("deska do krojenia (kolory HACCP)", "обробна дошка за санітарними нормами HACCP", "разделочная доска по нормам HACCP", "Czerwona deska służy wyłącznie do surowego mięsa.", "Червона дошка використовується суто для сирого м’яса.", "Красная доска используется исключительно для сырого мяса."),
        ("fartuch kuchenny i zapaska", "кухарський фартух та офіціантський поясник", "поварской фартук и фартук официанта", "Każdy pracownik sali musi mieć czystą zapaskę.", "Кожен працівник залу повинен мати чистий фартух-поясник.", "Каждый работник зала должен быть в чистом переднике."),
        ("dzbanek wody z cytryną", "графин води з лимоном", "графин воды с лимоном", "Dla państwa stolika woda z miętą i cytryną gratis.", "Для вашого столика вода з м’ятою та лимоном безкоштовно.", "Для вашего столика вода с мятой и лимоном бесплатно."),
        ("danie dnia (lunch)", "страва дня / комплексний обід", "блюдо дня / комплексный бизнес-ланч", "Nasze danie dnia to krem z dyni i pieczony łosoś.", "Наша страва дня — гарбузовий крем-суп та запечений лосось.", "Наше блюдо дня — тыквенный крем-суп и запечённый лосось."),
        ("reklamacja dania", "претензія гостя до якості страви", "претензия гостя к блюду", "Przepraszam, zupa jest zimna, natychmiast wymienię na gorącą.", "Вибачте, суп охолов, я негайно заміню на гарячий.", "Извините, суп холодный, я сию секунду заменю на горячий."),
        ("ekspres kolbowy do kawy", "професійна ріжкова кавоварка", "профессиональная рожковая кофемашина", "Barista spienia mleko na gęstą piankę do cappuccino.", "Бариста збиває молоко в густу пінку для капучино.", "Бариста взбивает молоко в густую пенку для капучино."),
        ("nalewak do piwa (keg)", "пивний кран та кег", "пивной кран и кег с пивом", "Muszę wymienić keg z piwem rzemieślniczym pod barem.", "Мушу замінити кег із крафтовим пивом під барною стійкою.", "Нужно заменить кег с крафтовым пивом под барной стойкой."),
        ("inwentaryzacja baru", "інвентаризація барного залишку", "инвентаризация остатков бара", "W niedzielę po zamknięciu lokalu robimy spis butelek.", "У неділю після закриття проводимо переоблік пляшок.", "В воскресенье после закрытия проводим ревизию бутылок."),
        ("stolik dwuosobowy", "столик на двох гостей", "столик на двоих", "Czy jest wolny stolik dwuosobowy przy oknie?", "Чи є вільний столик на двох біля вікна?", "Есть ли свободный столик на двоих у окна?"),
        ("podgrzewacz do potraw (bemar)", "марміт для підігріву гарячих страв", "мармит для подогрева горячих блюд", "Zupa na bufecie stoi w podgrzewaczu elektrycznym.", "Суп на шведській лінії стоїть в електричному марміті.", "Суп на шведской линии находится в электрическом мармите."),
        ("paragon z NIP-em do 450 zł", "спрощена фактура (чек із номером NIP до 450 zł)", "упрощённая фактура (чек с NIP до 450 zł)", "Paragon z numerem NIP do kwoty 450 zł jest traktowany jak faktura.", "Чек із NIP до 450 злотих визнається податковою фактурою.", "Чек с NIP до 450 злотых приравнивается к фактуре."),
        ("termin ważności produktów", "термін придатності інгредієнтів", "срок годности продуктов на складе", "Zawsze sprawdzajmy etykiety z datą otwarcia sosu.", "Завжди перевіряймо наліпки з датою відкриття соусу.", "Всегда проверяем наклейки с датой вскрытия упаковки соуса."),
        ("kosz na odpady bio", "контейнер для органічних харчових відходів", "бак для пищевых органических отходов", "Resztki jedzenia z talerzy wyrzucamy do pojemnika bio.", "Залишки їжі з тарілок викидаємо в контейнер для біовідходів.", "Остатки еды с тарелок счищаем в контейнер для биоотходов."),
        ("porcjowanie mięsa", "порціонування м’ясних заготовок", "порционирование мясных заготовок", "Kucharz odważa stugramowe porcje polędwiczek.", "Кухар зважує стограмові порції філе.", "Повар развешивает стограммовые порции филе."),
        ("degustacja wina", "дегустація винної карти", "дегустация винной карты", "Mogę zaproponować wytrawne wino z polskiej winnicy.", "Можу запропонувати сухе вино з польської винарні.", "Могу предложить сухое вино из польской винодельни."),
        ("kuchnia polska tradycyjna", "традиційна польська кухня", "традиционная польская кухня", "Polecam nasz domowy żurek w chlebku oraz pierogi z mięsem.", "Рекомендую наш домашній журек у хлібі та вареники з м’ясом.", "Рекомендую наш домашний журек в хлебе и вареники с мясом."),
        ("podkładka pod talerz", "декоративна підкладка / серветка під тарілку", "плейсмет / салфетка под приборы", "Zmień papierową podkładkę przed posadzeniem nowych gości.", "Поміняй паперову підкладку перед посадкою нових гостей.", "Смени бумажный плейсмет перед посадкой новых гостей."),
        ("zgoda sanepidu (książeczka)", "санітарна книжка для роботи в харчопромі", "санитарная книжка для общепита", "Wszyscy pracownicy kuchni muszą mieć aktualne badania Sanepidu.", "Усі працівники кухні повинні мати чинну довідку Санепіду.", "Все работники кухни обязаны иметь санкнижку Санепида."),
        ("zamknięcie kasy fiskalnej", "добовий фінансовий звіт Z на касі", "закрытие смены и суточный отчёт Z", "Po wyjściu gości drukujemy dobowy raport fiskalny.", "Після виходу гостей друкуємо добовий Z-звіт на касі.", "После ухода гостей снимаем суточный Z-отчёт на кассе."),
    ]

    content.append("const professionGastronomy = ProfessionItem(")
    content.append("  id: 'gastronomy',")
    content.append("  emoji: '🍽️',")
    content.append("  titlePl: 'Gastronomia i Restauracje',")
    content.append("  titleUk: 'Гастрономія та ресторани',")
    content.append("  titleRu: 'Гастрономия и рестораны',")
    content.append("  descPl: 'Obsługa gości, przyjmowanie zamówień, wydawka, rachunki i zasady sanepidu.',")
    content.append("  descUk: 'Обслуговування гостей, прийом замовлень, роздача, розрахунок та санітарні норми.',")
    content.append("  descRu: 'Обслуживание гостей, приём заказов, кухня, счета, чаевые и санитарные нормы.',")
    content.append("  vocabulary: [")
    for v in gastro_vocabs:
        content.append(vocab(*v))
    content.append("  ],")
    content.append("""  scenario: Scenario(
    key: 'prof_gastronomy',
    emoji: '🍽️',
    titlePl: 'Gastronomia i Restauracje',
    titleUk: 'Гастрономія та Ресторани',
    titleRu: 'Гастрономия и Рестораны',
    level: 'A2–B1',
    npcRole: 'gość restauracji lub szef kuchni',
    setting: 'Przyjmowanie zamówień, modyfikacja dań i komunikacja kucharz-kelner.',
    vocab: ['zamówienie', 'rachunek', 'kuchnia', 'alergia', 'rezerwacja'],
    subScenarios: [
      SubScenario(
        id: 'gastro_guest',
        titlePl: 'Przyjęcie zamówienia od wymagającego gościa',
        titleUk: 'Прийом замовлення від вибагливого гостя',
        titleRu: 'Приём заказа у требовательного гостя ресторана',
        descPl: 'Dopasowanie dań do alergii, polecenie win i podział rachunku.',
        descUk: 'Врахування алергій на глютен, рекомендація напоїв та роздільний рахунок.',
        descRu: 'Учёт аллергии на глютен, рекомендация напитков и раздельный счёт.',
        starterHintPl: 'Dzień dobry, witam w naszej restauracji. Czy mogę zaproпоnować coś do picia przed daniem głównym?',
        starterHintUk: 'Доброго дня, вітаємо в нашому ресторані. Чи можу запропонувати напої перед основними стравами?',
        starterHintRu: 'Добрый день, добро пожаловать в наш ресторан. Могу предложить напитки перед основным блюдом?',
        plotTwist: 'Gość żąda dania bezglutenowego, którego nie ma w karcie dań.',
        vocab: ['karta dań', 'alergeny', 'rachunek', 'napiwek', 'stolik'],
        npcRole: 'Gość biznesowy na kolacji z partnerem',
        setting: 'Elegancka sala restauracji w centrum Warszawy.',
        npcFirstStarterPl: 'Dobry wieczór. Mój partner ma silną alergię na orzechy i gluten. Co pan może polecić z karty dań?',
        npcFirstStarterUk: 'Доброго вечора. У мого партнера сильна алергія на горіхи та глютен. Що порадите з меню?',
        npcFirstStarterRu: 'Добрый вечер. У моего коллеги аллергия на орехи и глютен. Что порекомендуете из меню?',
      ),
      SubScenario(
        id: 'gastro_kitchen',
        titlePl: 'Spór na wydawce: pomyłka kucharza',
        titleUk: 'Суперечка на кухонній роздачі: помилка кухаря',
        titleRu: 'Спор на кухонной раздаче: задержка и ошибка повара',
        descPl: 'Wyjaśnienie brakującego steka i priorytet dla opóźnionego stolika numer pięć.',
        descUk: 'З’ясування статусу страви, що затримується, та пріоритет для столика 5.',
        descRu: 'Выяснение статуса задерживающегося блюда и приоритет для столика 5.',
        starterHintPl: 'Szefie, stolik numer pięć czeka już pół godziny na polędwiczki. Kiedy będą gotowe do wydania?',
        starterHintUk: 'Шеф, п’ятий столик чекає вже пів години на вирізку. Коли страва буде на роздачі?',
        starterHintRu: 'Шеф, пятый столик ждёт вырезку уже полчаса. Когда блюдо будет на раздаче?',
        plotTwist: 'Kucharz twierdzi, że nie dostał bonu z kasy z powodu awarii drukarki.',
        vocab: ['wydawka', 'bon', 'stolik', 'opóźnienie', 'polędwiczki'],
        npcRole: 'Nerwowy szef kuchni podczas szczytu obiadowego',
        setting: 'Gorąca, hałaśliwa kuchnia restauracyjna w piątek o dwudziestej.',
        npcFirstStarterPl: 'Kelner, zabieraj natychmiast zupę dla siódemki, bo stygnie! Co tam znowu krzyczysz o piątce?',
        npcFirstStarterUk: 'Офіціант, забирай негайно суп для сьомого, бо охолоне! Що ти там знову кричиш про п’ятий?',
        npcFirstStarterRu: 'Официант, забирай суп для седьмого стола, стынет же! Что ты там опять кричишь про пятый?',
      ),
      SubScenario(
        id: 'gastro_complaint',
        titlePl: 'Reklamacja: zimna potrawa i kompensata',
        titleUk: 'Претензія гостя: холодна страва та комплімент',
        titleRu: 'Жалоба гостя: остывшее блюдо и комплимент заведения',
        descPl: 'Kulturalne załagodzenie sytuacji, propozycja deseru i zniżki na rachunek.',
        descUk: 'Ввічливе вирішення конфлікту, заміна страви та пропозиція компліменту від закладу.',
        descRu: 'Вежливое урегулирование конфликта, замена блюда и комплимент от шефа.',
        starterHintPl: 'Bardzo przepraszam za tę sytuację. Natychmiast poproszę kuchnię o przygotowanie świeżej, gorącej porcji.',
        starterHintUk: 'Дуже перепрошую за цю ситуацію. Негайно попрошу кухню приготувати свіжу гарячу порцію.',
        starterHintRu: 'Приношу искренние извинения за ситуацию. Немедленно попрошу кухню приготовить свежую порцию.',
        plotTwist: 'Klient prosi o rozmowę z menedżerem i grozi negatywną opinią w Google.',
        vocab: ['przepraszam', 'reklamacja', 'rabat', 'deser', 'menedżer'],
        npcRole: 'Niezadowolona klientka restauracji',
        setting: 'Kameralny stolik przy oknie w porze kolacji.',
        npcFirstStarterPl: 'Proszę pana, to jest niedopuszczalne! Czekałam czterdzieści minut, a to danie jest całkowicie zimne w środku.',
        npcFirstStarterUk: 'Шановний, це неприпустимо! Я чекала 40 хвилин, а страва всередині взагалі холодна.',
        npcFirstStarterRu: 'Молодой человек, это недопустимо! Я ждала 40 минут, а блюдо внутри совершенно холодное.',
      ),
    ],
  ),
);""")

    # 4. CLEANING & CARE (32 terms)
    cleaning_vocabs = [
        ("środek dezynfekujący", "дезінфікуючий засіб", "дезинфицирующее средство", "Używaj środka dezynfekującego w rękawicach gumowych.", "Використовуй дезінфектор у гумових рукавичках.", "Используй дезинфицирующее средство в перчатках."),
        ("wózek hotelowy (housekeeping)", "візок покоївки", "уборочная тележка горничной", "Uzupełnij czyste ręczniki i szampony na wózku piętrowym.", "Поповни чисті рушники та шампуні на візку покоївки.", "Пополни запас полотенец и шампуней на тележке."),
        ("wymiana pościeli", "зміна постільної білизни", "смена постельного белья", "W pokoju 204 goście poprosili o codzienną wymianę pościeli.", "У кімнаті 204 гості попросили щоденну заміну білизни.", "В комнаті 204 гости попросили ежедневную смену белья."),
        ("odkurzacz przemysłowy", "промисловий потужний пилосос", "промышленный пылесос", "Odkurzaczem piorącym usuniesz plamę z wykładziny.", "Миючим пилососом виведеш пляму з килимового покриття.", "Моющим пылесосом выведешь пятно с ковролина."),
        ("podopieczny / podopieczna", "підопічний / підопічна (в догляді)", "подопечный / подопечная (в уходе)", "Pani Maria, moja podopieczna, bardzo lubi popołudniowe spacery.", "Пані Марія, моя підопічна, любить прогулянки після обіду.", "Пани Мария, моя подопечная, любит прогулки после обеда."),
        ("pomiar ciśnienia i cukru", "вимірювання тиску та цукру", "измерение давления и сахара", "Zapisuję wynik pomiaru ciśnienia w dzienniku opieki.", "Записую результат тиску в щоденник догляду.", "Записываю давление в дневник ухода."),
        ("zażywanie leków według rozpiski", "прийом ліків за розкладом", "приём лекарств по назначению", "Tabletki na serce podajemy zawsze rano po śniadaniu.", "Таблетки для серця даємо щоранку після сніданку.", "Таблетки для сердца даём каждое утро после завтрака."),
        ("wózek inwalidzki", "інвалідний візок", "инвалидная коляска", "Zablokuj hamulce wózka inwalidzkiego przed przesadzeniem pacjenta.", "Заблокуй гальма візка перед пересаджуванням пацієнта.", "Заблокируй тормоза коляски перед пересаживанием пациента."),
        ("mop z mikrofibry", "моп із мікрофібри для миття підлоги", "швабра с микрофиброй для пола", "Do paneli podłogowych używamy lekko wilgotnego mopa.", "Для ламінату використовуємо ледь вологу швабру.", "Для ламината используем слегка влажную швабру."),
        ("płyn do mycia szyb bez smug", "засіб для миття вікон без розводів", "средство для мытья стёкол без разводов", "Przetrzyj lustro ściereczką z mikrofibry, żeby nie było smug.", "Протри дзеркало мікрофіброю, щоб не було розводів.", "Протри зеркало микрофиброй, чтобы не было разводов."),
        ("rękawice nitrylowe jednorazowe", "одноразові нітрилові рукавички", "одноразовые нитриловые перчатки", "Wyrzucaj zużyte rękawiczki po sprzątaniu każdej łazienki.", "Викидай рукавички після прибирання кожного санвузла.", "Выбрасывай перчатки после уборки каждого санузла."),
        ("segregacja śmieci (papier, plastik)", "сортування відходів за фракціями", "сортировка мусора по фракциям", "Żółty worek przeznaczony jest na plastik i metal.", "Жовтий мішок призначений для пластику та бляшанок.", "Жёлтый пакет предназначен для пластика и банок."),
        ("pranie i prasowanie", "прання та прасування одягу", "стирка и глажка одежды", "Koszule podopiecznego prasujemy na lewej stronie.", "Сорочки підопічного прасуємо навиворіт.", "Рубашки подопечного гладим с изнаночной стороны."),
        ("pomoc w higienie osobistej", "допомога в щоденній гігієні", "помощь в личной гигиене", "Pomagam panu Jerzemu wziąć prysznic i umyć plecy.", "Допомагаю пану Єжи прийняти душ та помити спину.", "Помогаю господину Ежи принять душ и помыть спину."),
        ("opatrunek i plaster", "перев’язувальний матеріал та пластир", "повязка и медицинский пластырь", "Trzeba zmienić sterylny opatrunek na przedramieniu.", "Потрібно змінити стерильну пов’язку на передпліччі.", "Нужно сменить стерильную повязку на предплечье."),
        ("lekarz rodzinny (POZ)", "сімейний лікар / дільнична поліклініка", "семейный врач в поликлинике", "Umówiłam wizytę u lekarza rodzinnego na czwartek.", "Я записала підопічного до сімейного лікаря на четвер.", "Я записала подопечного к семейному врачу на четверг."),
        ("odleżyny (profilaktyka)", "профілактика та лікування пролежнів", "профилактика и уход при пролежнях", "Zmieniamy pozycję leżącego pacjenta co dwie godziny.", "Змінюємо положення лежачого пацієнта кожні 2 години.", "Переворачиваем лежачего пациента каждые 2 часа."),
        ("apteczka pierwszej pomocy", "автомобільна та домашня аптечка", "аптечка первой помощи", "Sprawdź, czy w apteczce są bandaże i woda utleniona.", "Перевір, чи в аптечці є бинти та перекис водню.", "Проверь наличие в аптечке бинтов и перекиси водорода."),
        ("kamień w kabinie prysznicowej", "вапняний наліт у душовій кабіні", "известковый налёт в душевой", "Użyj odkamieniacza w piance, żeby usunąć zacieki z szyby.", "Використай піну від вапна, щоб відмити розводи на склі.", "Используй пену от налёта, чтобы отмыть стекло кабины."),
        ("chodzik rehabilitacyjny (balkonik)", "ходунки для реабілітації", "ходунки для пожилых людей", "Podopieczny porusza się po mieszkaniu przy pomocy balkonika.", "Підопічний ходить по квартирі за допомогою ходунків.", "Подопечный передвигается по квартире с ходунками."),
        ("dieta lekkostrawna", "дієтичне легкозасвоюване харчування", "легкоусвояемая диетическая пища", "Gotuję dla seniora zupę jarzynową bez ostrych przypraw.", "Варю для дідуся овочевий суп без гострих приправ.", "Варю для пожилого человека овощной суп без специй."),
        ("pogotowie ratunkowe (numer 112)", "швидка медична допомога (112)", "скорая медицинская помощь (112)", "W nagłym wypadku natychmiast dzwonię pod numer 112.", "У разі раптового погіршення одразу телефоную на 112.", "В экстренном случае сразу вызываю скорую по 112."),
        ("karta meldunkowa w hotelu", "реєстраційна карта гостя в готелі", "регистрационная карточка гостя", "Sprawdź stan minibarku przed wymeldowaniem gościa.", "Перевір стан мінібару перед виїздом гостя з номера.", "Проверь мини-бар перед выселением постояльца."),
        ("odplamiacz do tkanin", "засіб для виведення плям", "пятновыводитель для тканей", "Ten odplamiacz tlenowy świetnie radzi sobie z plamami po kawie.", "Цей кисневий засіб чудово виводить плями від кави.", "Этот кислородный пятновыводитель удаляет пятна кофе."),
        ("wietrzenie pomieszczeń", "провітрювання кімнат", "проветривание комнат", "Przewietrz sypialnię rano przez przynajmniej 10 minut.", "Провітри спальню вранці щонайменше 10 хвилин.", "Проветри спальню утром хотя бы 10 минут."),
        ("zakupy spożywcze i apteczne", "купівля продуктів та ліків за чеком", "покупка продуктов и медикаментов", "Idę do Biedronki i apteki kupić zalecone maści.", "Іду в супермаркет та аптеку купити призначені мазі.", "Иду в супермаркет и аптеку купить выписанные мази."),
        ("worki na śmieci o dużej gęstości", "міцні мішки для будівельного сміття", "плотные мешки для мусора", "Włóż ciężkie odpady do podwójnego worka 120 litrów.", "Поклади важке сміття в подвійний мішок на 120 л.", "Сложи тяжёлый мусор в двойной пакет на 120 литров."),
        ("krzesełko toaletowe", "санітарний стілець для людей з інвалідністю", "санитарный стул-туалет", "Zdezynfekuj krzesełko toaletowe specjalnym sprayem.", "Продезінфікуй санітарний стілець спеціальним спреєм.", "Продезинфицируй санитарный стул спецспреем."),
        ("kontakt z rodziną podopiecznego", "зв’язок із родичами літньої людини", "связь с родственниками подопечного", "Córka podopiecznej dzwoni codziennie o godzinie dwudziestej.", "Донька підопічної телефонує щодня о двадцятій годині.", "Дочь подопечной звонит каждый вечер в восемь часов."),
        ("odkurzanie tapicerki", "чищення меблевої оббивки пилососом", "чистка обивки мебели пылесосом", "Użyj wąskiej ssawki szczelinowej do czyszczenia kanapy.", "Візьми вузьку щілинну насадку для очищення дивана.", "Возьми узкую щелевую насадку для очистки дивана."),
        ("podkłady higieniczne jednorazowe", "одноразові гігієнічні пелюшки", "одноразовые гигиенические пелёнки", "Kładziemy podkład nieprzemakalny pod prześcieradło.", "Кладемо непромокальну пелюшку під простирадло.", "Стелим непромокаемую пелёнку под простыню."),
        ("bezpieczeństwo w łazience", "поручні та антиковзний килимок у ванній", "поручни и противоскользящий коврик", "Mata antypoślizgowa zapobiega upadkowi w wannie.", "Антиковзний килимок захищає від падіння у ванні.", "Противоскользящий коврик защищает от падения в ванной."),
    ]

    content.append("const professionCleaning = ProfessionItem(")
    content.append("  id: 'cleaning',")
    content.append("  emoji: '🧹',")
    content.append("  titlePl: 'Sprzątanie i Opieka',")
    content.append("  titleUk: 'Клінінг та догляд за літніми',")
    content.append("  titleRu: 'Клининг и уход за пожилыми',")
    content.append("  descPl: 'Środki czystości, sprzęt, opieka nad seniorem, leki i pierwsza pomoc.',")
    content.append("  descUk: 'Побутова хімія, стандарти готелів, догляд за підопічним, ліки та перша допомога.',")
    content.append("  descRu: 'Бытовая химия, стандарты отелей, уход за подопечным, лекарства и первая помощь.',")
    content.append("  vocabulary: [")
    for v in cleaning_vocabs:
        content.append(vocab(*v))
    content.append("  ],")
    content.append("""  scenario: Scenario(
    key: 'prof_cleaning',
    emoji: '🧹',
    titlePl: 'Sprzątanie i Hotelarstwo',
    titleUk: 'Клінінг та Готелі',
    titleRu: 'Клининг и Гостиничный сервис',
    level: 'A2',
    npcRole: 'koordynator serwisu sprzątającego lub kierownik piętra hotelu',
    setting: 'Instrukcje koordynatora, specyfikacja chemii i odbiór pokoi hotelowych.',
    vocab: ['środki czyszczące', 'pokój', 'ręczniki', 'odkurzacz', 'koordynator'],
    subScenarios: [
      SubScenario(
        id: 'cleaning_hotel',
        titlePl: 'Odprawa w hotelu: standardy czystości pokoju',
        titleUk: 'Інструктаж у готелі: перевірка прибирання номерів',
        titleRu: 'Проверка уборки номеров старшей горничной',
        descPl: 'Weryfikacja łazienki, wymiana ręczników i minibar przed przyjazdem VIP-a.',
        descUk: 'Перевірка санвузла, заміна білизни та мінібар перед заселенням гостей.',
        descRu: 'Проверка санузла, смена белья и пополнение мини-бара к заезду гостей.',
        starterHintPl: 'Pani kierowniczko, skończyłam pokoje na drugim piętrze. Wszystkie łazienki są zdezynfekowane.',
        starterHintUk: 'Пані адміністраторко, я закінчила номери на другому поверсі. Усі санвузли продезінфіковані.',
        starterHintRu: 'Пани администратор, я закончила номера на втором этаже. Все санузлы продезинфицированы.',
        plotTwist: 'Kierowniczka znajduje plamę na dywanie w apartamencie 204.',
        vocab: ['pościel', 'ręczniki', 'odkurzacz', 'łazienka', 'dezynfekcja'],
        npcRole: 'Kierowniczka służby pięter w hotelu',
        setting: 'Korytarz czterogwiazdkowego hotelu w Krakowie.',
        npcFirstStarterPl: 'Dzień dobry. Sprawdzam właśnie pokój 204. Lustro ma zacieki, a pod łóżkiem został kurz. Proszę to natychmiast poprawić.',
        npcFirstStarterUk: 'Доброго дня. Перевіряю номер 204. На дзеркалі розводи, а під ліжком пил. Будь ласка, негайно виправте.',
        npcFirstStarterRu: 'Добрый день. Проверяю номер 204. На зеркале разводы, а под кроватью пыль. Пожалуйста, переделайте сию минуту.',
      ),
      SubScenario(
        id: 'cleaning_elderly',
        titlePl: 'Raport dzienny dla córki podopiecznego',
        titleUk: 'Щоденний звіт для доньки літньої людини',
        titleRu: 'Ежедневный отчёт для дочери подопечного',
        descPl: 'Opis samopoczucia, apetytu, ciśnienia i godzin zażycia leków przez seniora.',
        descUk: 'Розповідь про самопочуття, апетит, показники тиску та прийом медикаментів.',
        descRu: 'Рассказ о самочувствии, аппетите, давлении и приёме медикаментов пожилым человеком.',
        starterHintPl: 'Dzień dobry pani Anno. Pan Jerzy czuje się dzisiaj dobrze, zjadł cały obiad, a ciśnienie wynosi sto dwadzieścia na osiemdziesiąt.',
        starterHintUk: 'Доброго дня, пані Анно. Пан Єжи почувається добре, з’їв увесь обід, тиск 120 на 80.',
        starterHintRu: 'Добрый день, пани Анна. Господин Ежи чувствует себя хорошо, пообедал с аппетитом, давление 120 на 80.',
        plotTwist: 'Senior odmawia zażycia wieczornej tabletки i skarży się na ból brzucha.',
        vocab: ['ciśnienie', 'leki', 'spacer', 'obiad', 'podopieczny'],
        npcRole: 'Córka podopiecznego dzwoniąca po pracy',
        setting: 'Przytulny salon w mieszkaniu podopiecznego w Gdańsku.',
        npcFirstStarterPl: 'Dzień dobry! Dzwonię zapytać, jak minął dzień tacie. Czy wziął wszystkie leki i czy byliście na spacerze w parku?',
        npcFirstStarterUk: 'Доброго дня! Дзвоню спитати, як минув день у тата. Чи прийняв він ліки і чи гуляли ви в парку?',
        npcFirstStarterRu: 'Добрый день! Звоню узнать, как прошёл день у папы. Принял ли он лекарства и гуляли ли вы в парке?',
      ),
      SubScenario(
        id: 'cleaning_emergency',
        titlePl: 'Nagłe wezwanie pogotowia ratunkowego (112)',
        titleUk: 'Терміновий виклик швидкої допомоги (112)',
        titleRu: 'Срочный вызов скорой помощи по номеру 112',
        descPl: 'Podanie adresu, objawów zasłabnięcia i stanu przytomności dyspozytorowi.',
        descUk: 'Повідомлення адреси, симптомів слабкості та стану свідомості оператору 112.',
        descRu: 'Сообщение точного адреса, симптомов обморока и состояния сознания оператору 112.',
        starterHintPl: 'Dzień dobry, wzywam karetkę pogotowia. Starsza osoba zasłabła, ma trudności z oddychaniem.',
        starterHintUk: 'Доброго дня, викликаю швидку. Літня людина знепритомніла, важко дихає.',
        starterHintRu: 'Добрый день, вызываю скорую помощь. Пожилой человек потерял сознание, тяжело дышит.',
        plotTwist: 'Dyspozytor prosi o natychmiastowe rozpoczęcie pozycji bocznej ustalonej.',
        vocab: ['pogotowie', '112', 'zasłabnięcie', 'oddychanie', 'adres'],
        npcRole: 'Dyspozytor numeru alarmowego 112',
        setting: 'Korytarz w mieszkaniu, sytuacja nagłego pogorszenia zdrowia seniora.',
        npcFirstStarterPl: 'Numer alarmowy 112, dyspozytor medyczny. Gdzie potrzebna pomoc i co dokładnie się dzieje z pacjentem?',
        npcFirstStarterUk: 'Служба 112, медичний диспетчер. Де потрібна допомога та що саме відбувається з пацієнтом?',
        npcFirstStarterRu: 'Служба 112, медицинский диспетчер. Назовите адрес и что конкретно происходит с человеком?',
      ),
    ],
  ),
);""")

    # 5. IT & TECH (32 terms)
    it_vocabs = [
        ("rozmowa rekrutacyjna (interview)", "технічна співбесіда", "техническое собеседование", "Jutro mam drugą rundę rozmowy rekrutacyjnej na stanowisko programisty.", "Завтра в мене другий раунд співбесіди на позицію розробника.", "Завтра у меня второй раунд собеседования на позицию разработчика."),
        ("wdrożenie produkcyjne (deploy)", "викладка оновлення на прод", "развёртывание релиза на прод (deploy)", "Wdrażamy nową wersję aplikacji na środowisko produkcyjne o północy.", "Викладаємо нову версію додатку на прод опівночі.", "Разворачиваем новую версию приложения на прод в полночь."),
        ("zgłoszenie błędu (bug report)", "репорт про помилку в трекері", "отчёт об ошибке (баг-репорт)", "Zgłosiłem krytyczny błąd w module płatności na tablicy Jira.", "Я завів критичний баг у модулі оплати на дошці Jira.", "Я завёл критический баг в модуле платежей на доске Jira."),
        ("przegląd kodu (code review)", "перевірка коду колегами", "код-ревью коллегами", "Czy mógłbyś rzucić okiem na mój pull request i zrobić code review?", "Чи міг би ти глянути мій pull request та зробити код-рев’ю?", "Не мог бы ты глянуть мой pull request и сделать код-ревью?"),
        ("spotkanie codzienne (daily / standup)", "ранкова нарада команди", "ежедневный утренний созвон (дейлик)", "Na daily powiem krótko, co udało mi się zrobić wczoraj.", "На дейлі коротко розкажу, що вдалося зробити вчора.", "На дейлике коротко расскажу, что удалось сделать вчера."),
        ("zadanie w Jirze (ticket)", "робоча картка завдання (тікет)", "рабочая задача / тикет в Jira", "Przesuń swój ticket z kolumny In Progress do Code Review.", "Перетягни свій тікет із колонки В роботі в Код-рев’ю.", "Передвинь свой тикет из работы в ревью."),
        ("termin oddania projektu (deadline)", "дедлайн / крайній термін здачі", "дедлайн / срок сдачи этапа", "Mamy sztywny deadline do końca tego kwartału.", "Маємо жорсткий дедлайн до кінця цього кварталу.", "У нас жёсткий дедлайн до конца этого квартала."),
        ("środowisko testowe (staging)", "тестовий сервер для перевірки", "тестовый сервер (стейджинг)", "Przetestujmy integrację najpierw na środowisku stagingowym.", "Протестуймо інтеграцію спочатку на тестовому сервері.", "Протестируем интеграцию сначала на стейджинге."),
        ("baza danych (SQL / NoSQL)", "реляційна або документна база даних", "база данных (SQL / NoSQL)", "Trzeba zoptymalizować to zapytanie, bo blokuje bazę danych.", "Треба оптимізувати цей запит, бо він навантажує базу.", "Нужно оптимизировать запрос, он сильно грузит базу данных."),
        ("system kontroli wersji Git", "система контролю версій Git", "система контроля версий Git", "Zrób commit i wypchnij zmiany na swoją gałąź roboczą.", "Зроби коміт та запуш зміни у свою робочу гілку.", "Сделай коммит и запушь изменения в свою рабочую ветку."),
        ("konflikt przy scalaniu (merge conflict)", "конфлікт злиття гілок коду", "конфликт при слиянии веток кодовой базы", "Musimy ręcznie rozwiązać konflikt w pliku konfiguracyjnym.", "Мусимо вручну вирішити конфлікт у файлі конфігурації.", "Придётся вручную разрешить конфликт в конфиге."),
        ("refaktoryzacja kodu", "покращення архітектури без зміни логіки", "рефакторинг устаревшего кода", "Ten moduł wymaga gruntownej refaktoryzacji, bo ma dużo długu technicznego.", "Цей модуль потребує глибокого рефакторингу через техборг.", "Этот модуль требует рефакторинга из-за техдолга."),
        ("dług technologiczny (legacy code)", "застарілий код та технічний борг", "легаси-код и технический долг", "Pozbywamy się starego legacy kodu napisanego pięć lat temu.", "Позбуваємося старого легасі-коду, написаного 5 років тому.", "Избавляемся от старого легаси-кода пятилетней давности."),
        ("dokumentacja techniczna API", "технічна документація для розробників", "техническая документация API (Swagger)", "Opisz nowe endpointy w dokumentacji Swaggera.", "Опиши нові точки доступу в документації Swagger.", "Опиши новые эндпоинты в документации Swagger."),
        ("dostęp administratorski (uprawnienia)", "права адміністратора / доступ до кластера", "права администратора / доступ к кластеру", "Dział bezpieczeństwa przyznał mi dostęp do serwera Kubernetes.", "Служба безпеки надала мені доступ до кластера Kubernetes.", "Служба безопасности выдала мне доступ к Kubernetes."),
        ("umowa B2B czy umowa o pracę", "контракт B2B чи трудовий договір", "контракт B2B или трудовой договор (UoP)", "Wielu programistów w Polsce rozlicza się na umowie B2B z ryczałtem 12%.", "Багато айтівців у Польщі працюють на B2B зі ставкою 12%.", "Многие айтишники в Польше работают на B2B по ставке 12%."),
        ("stawka godzinowa netto", "погодинна оплата праці на руки", "почасовая ставка чистыми на руки", "Jaka jest twoja oczekiwana stawka godzinowa netto na fakturze?", "Яка ваша очікувана погодинна ставка нетто у фактурі?", "Какова ваша ожидаемая почасовая ставка нетто по фактуре?"),
        ("praca zdalna (home office)", "дистанційна робота з дому", "удалённая работа из дома", "W naszej firmie pracujemy w modelu w pełni zdalnym.", "У нашій компанії ми працюємо в повністю віддаленому форматі.", "В нашей компании мы работаем полностью удалённо."),
        ("testy jednostkowe (unit testy)", "модульні автоматичні тести", "модульные автоматические тесты", "Pokrycie kodu testami jednostkowymi wynosi ponad osiemdziesiąt procent.", "Покриття коду юніт-тестами перевищує 80 відсотків.", "Покрытие кода тестами превышает восемьдесят процентов."),
        ("bezpieczeństwo aplikacji (cybersecurity)", "кібербезпека та захист даних", "кибербезопасность и защита данных", "Audyt bezpieczeństwa nie wykazał żadnych podatności.", "Аудит кібербезпеки не виявив жодних вразливостей.", "Аудит безопасности не выявил никаких уязвимостей."),
        ("awaria serwera (downtime)", "збій сервера та недоступність сервісу", "падение сервера и недоступность сервиса", "Incydent został rozwiązany w ciągu piętnastu minut.", "Інцидент падіння сервісу було вирішено за 15 хвилин.", "Инцидент сбоя сервиса был устранён за пятнадцать минут."),
        ("konteneryzacja Docker", "контейнеризація додатків Docker", "контейнеризация сервисов Docker", "Zbuduj obraz Dockera i wyślij go do rejestru chmurowego.", "Збери образ Docker та надішли його у хмарний реєстр.", "Собери образ Docker и отправь его в облачный реестр."),
        ("chmura obliczeniowa (AWS / Azure)", "хмарна інфраструктура", "облачная инфраструктура (AWS / Azure)", "Przenosimy mikroserwisy do chmury obliczeniowej.", "Переносимо мікросервіси у хмарне середовище AWS.", "Переносим микросервисы в облачную инфраструктуру AWS."),
        ("architektura mikroserwisowa", "мікросервісна модульна архітектура", "микросервисная модульная архитектура", "Każdy mikroserwis odpowiada za osobną domenę biznesową.", "Кожен мікросервіс відповідає за окремий бізнес-домен.", "Каждый микросервис отвечает за свой бизнес-домен."),
        ("sprint dwutygodniowy", "двотижневий цикл розробки в Scrum", "двухнедельный спринт по Scrum", "Planowanie kolejnego sprintu odbędzie się w poniedziałek.", "Планування наступного спринту відбудеться в понеділок.", "Планирование следующего спринта пройдёт в понедельник."),
        ("retrospektywa zespołu", "ретроспектива підсумків спринту", "ретроспектива итогов спринта команды", "Na retro porozmawiamy o tym, co możemy usprawnić w procesie.", "На ретро обговоримо, що можна покращити в процесах.", "На ретро обсудим, что можно улучшить в рабочих процессах."),
        ("oprogramowanie open source", "програмне забезпечення з відкритим кодом", "программное обеспечение с открытым кодом", "Korzystamy z bibliotek open source na licencji MIT.", "Використовуємо бібліотеки з відкритим кодом на ліцензії MIT.", "Используем библиотеки с открытым исходным кодом."),
        ("kopia zapasowa (backup)", "резервне копіювання даних", "резервное копирование (бэкап)", "Kopie zapasowe bazy danych tworzą się automatycznie co noc.", "Резервні копії бази даних створюються автоматично щоночі.", "Резервные копии базы данных создаются автоматически каждую ночь."),
        ("uwierzytelnianie dwuskładnikowe (2FA)", "двоетапна автентифікація", "двухфакторная аутентификация (2FA)", "Włącz dwuskładnikowe logowanie do poczty korporacyjnej.", "Увімкни двофакторний вхід у корпоративну пошту.", "Включи двухфакторный вход в корпоративную почту."),
        ("rozszerzenie funkcjonalności (feature)", "нова корисна функція в додатку", "новая полезная фича в продукте", "Nowa funkcja eksportu danych trafi do użytkowników w piątek.", "Нова фіча експорту стане доступна користувачам у п’ятницю.", "Новая фича экспорта станет доступна пользователям в пятницу."),
        ("audyt zgodności z RODO (GDPR)", "відповідність європейському регламенту RODO", "соответствие европейскому закону о персональных данных RODO (GDPR)", "Przetwarzanie danych osobowych musi być w pełni zgodne z RODO.", "Обробка персональних даних має повністю відповідати нормам RODO.", "Обработка персональных данных обязана соответствовать нормам RODO."),
        ("premia roczna i benefity", "річний бонус, страховка та абонемент", "годовая премия, ДМС и карта Multisport", "Pakiet benefitów obejmuje prywatną opiekę medyczną i kartę sportową.", "Пакет бонусів включає приватне медичне страхування та спорт.", "Пакет бенефитов включает страховку ДМС и карту Multisport."),
    ]

    content.append("const professionIT = ProfessionItem(")
    content.append("  id: 'it_office',")
    content.append("  emoji: '💻',")
    content.append("  titlePl: 'IT, Nowe Technologie i Biuro',")
    content.append("  titleUk: 'IT, технології та офіс',")
    content.append("  titleRu: 'IT, технологии и офис',")
    content.append("  descPl: 'Rozmowa rekrutacyjna, daily, code review, wdrożenia, zgłoszenia i umowy B2B.',")
    content.append("  descUk: 'Технічна співбесіда, daily, код-рев’ю, деплой, Jira та контракти B2B.',")
    content.append("  descRu: 'Техническое собеседование, дейли, код-ревью, деплой, Jira и контракты B2B.',")
    content.append("  vocabulary: [")
    for v in it_vocabs:
        content.append(vocab(*v))
    content.append("  ],")
    content.append("""  scenario: Scenario(
    key: 'prof_it_office',
    emoji: '💻',
    titlePl: 'IT i Praca Biurowa',
    titleUk: 'IT та Офіс',
    titleRu: 'IT и Офис',
    level: 'B1–B2',
    npcRole: 'rekruter HR lub Tech Lead w polskiej firmie technologicznej',
    setting: 'Rozmowa kwalifikacyjna, daily standup i sprawy kadrowe.',
    vocab: ['rekrutacja', 'B2B', 'widełki', 'sprint', 'L4', 'urlop'],
    subScenarios: [
      SubScenario(
        id: 'it_interview',
        titlePl: 'Rozmowa rekrutacyjna z Tech Leadem',
        titleUk: 'Технічна співбесіда з техлідом',
        titleRu: 'Техническое собеседование с техлидом проекта',
        descPl: 'Doświadczenie w projektach, architektura mikroserwisowa i warunki B2B.',
        descUk: 'Досвід у проектах, стек технологій та очікування щодо ставки на B2B.',
        descRu: 'Опыт разработки, архитектура систем и зарплатные ожидания на B2B.',
        starterHintPl: 'Dzień dobry. Przez ostatnie trzy lata pracowałem jako backend developer w fintechu w architekturze mikroserwisowej.',
        starterHintUk: 'Доброго дня. Останні 3 роки я працював бекенд-розробником у фінтеху на мікросервісах.',
        starterHintRu: 'Добрый день. Последние три года я работал бэкенд-разработчиком в финтехе на микросервисах.',
        plotTwist: 'Rekruter pyta o szczegóły trudnego błędu produkcyjnego i jak go rozwiązałeś.',
        vocab: ['doświadczenie', 'architektura', 'baza danych', 'stawka B2B', 'zespół'],
        npcRole: 'Tech Lead zespołu poszukujący programisty',
        setting: 'Rozmowa wideo przez Google Meet z biurem w Warszawie.',
        npcFirstStarterPl: 'Cześć! Miło cię poznać. Przejrzałem twoje CV i repozytorium na GitHubie. Opowiedz o najtrudniejszym projekcie, jaki wdrażałeś.',
        npcFirstStarterUk: 'Привіт! Радий знайомству. Я переглянув твоє резюме та GitHub. Розкажи про найскладніший проект, який ти розгортав.',
        npcFirstStarterRu: 'Привет! Рад познакомиться. Посмотрел твой профиль и GitHub. Расскажи о самом сложном проекте, который запускал.',
      ),
      SubScenario(
        id: 'it_standup',
        titlePl: 'Codzienny stand-up: status prac i blokery',
        titleUk: 'Ранковий daily stand-up: статус та блокери',
        titleRu: 'Ежедневный стендап: статус задач и блокеры',
        descPl: 'Krótki raport z wykonanych zadań, plan na dziś i zgłoszenie blokera infrastruktury.',
        descUk: 'Короткий звіт про вчорашні завдання, плани на день та блокер на середовищі.',
        descRu: 'Краткий отчёт по вчерашним задачам, план на день и сообщение о блокере.',
        starterHintPl: 'Cześć zespołowi! Wczoraj dokończyłem integrację API, dzisiaj piszę testy. Mam mały bloker z dostępem do bazy stagingowej.',
        starterHintUk: 'Привіт команді! Учора я завершив інтеграцію API, сьогодні пишу тести. Маю блокер із доступом до тестової бази.',
        starterHintRu: 'Привет команде! Вчера я закончил интеграцию API, сегодня пишу тесты. У меня блокер с доступом к тестовой базе данных.',
        plotTwist: 'Serwer testowy przestał odpowiadać po wdrożeniu nowego buildu przez inny zespół.',
        vocab: ['wczoraj', 'dzisiaj', 'bloker', 'code review', 'wdrożenie'],
        npcRole: 'Scrum Master prowadzący spotkanie',
        setting: 'Krótka 15-minutowa odprawa programistów na początku dnia.',
        npcFirstStarterPl: 'Cześć wszystkim! Zaczynamy daily. Kto chce zacząć ze statusem swoich zadań?',
        npcFirstStarterUk: 'Привіт усім! Починаємо daily. Хто хоче почати зі свого статусу завдань?',
        npcFirstStarterRu: 'Привет всем! Начинаем daily. Кто хочет начать со статуса своих задач?',
      ),
      SubScenario(
        id: 'it_negotiation',
        titlePl: 'Podpisanie umowy i negocjacja stawки',
        titleUk: 'Підписання контракту та узгодження ставки',
        titleRu: 'Обсуждение контракта B2B и согласование рейта',
        descPl: 'Ustalenie 26 dni płatnego urlopu na B2B, okresu wypowiedzenia i sprzętu firmowego.',
        descUk: 'Узгодження 26 днів оплачуваної перерви, терміну попередження та робочого ноутбука.',
        descRu: 'Согласование оплачиваемых отпускных дней на B2B, срока расторжения и ноутбука.',
        starterHintPl: 'Chciałbym doprecyzować zapisy dotyczące płatnych dni urlopowych oraz budżetu edukacyjnego.',
        starterHintUk: 'Хотів би уточнити пункти контракту щодо оплачуваних днів відпочинку та навчального бюджету.',
        starterHintRu: 'Хотел бы уточнить пункты договора относительно оплачиваемого отпуска и бюджета на обучение.',
        plotTwist: 'Firma proponuje wyższą stawkę godzinową w zamian za krótszy okres wypowiedzenia.',
        vocab: ['stawka', 'faktura', 'okres wypowiedzenia', 'sprzęt', 'urlop'],
        npcRole: 'Dyrektor personalny HR z centrali firmy',
        setting: 'Nowoczesna sala konferencyjna w szklanym wieżowcu w centrum Warszawy.',
        npcFirstStarterPl: 'Dzień dobry. Bardzo się cieszymy, że pomyślnie przeszedł pan rozmowę techniczną. Przygotowaliśmy ofertę współpracy na B2B. Czy miał pan okazję przejrzeć warunki?',
        npcFirstStarterUk: 'Доброго дня. Ми раді, що ви успішно пройшли технічну співбесіду. Підготували пропозицію B2B. Чи мали нагоду переглянути умови?',
        npcFirstStarterRu: 'Добрый день. Очень рады, что вы успешно прошли технический этап. Мы подготовили оффер на B2B. Успели ознакомиться с условиями?',
      ),
    ],
  ),
);""")

    # 6. MANUFACTURING & FACTORIES (32 terms) - BRAND NEW!
    mfg_vocabs = [
        ("linia produkcyjna", "виробнича лінія", "производственная линия", "Pracuję na linii produkcyjnej podzespołów elektronicznych.", "Працюю на виробничій лінії електронних компонентів.", "Работаю на производственной линии электронных компонентов."),
        ("taśma montażowa", "монтажний конвеєр / стрічка", "сборочный конвейер / лента", "Elementy przesuwają się po taśmie montażowej co dwadzieścia sekund.", "Деталі рухаються по конвеєру кожні двадцять секунд.", "Детали движутся по сборочной ленте каждые двадцать секунд."),
        ("brygadzista / brygadzistka", "бригадир / майстер зміни", "бригадир / мастер смены", "Brygadzista przydziela zadania na początku każdej zmiany roboczej.", "Бригадир розподіляє завдання на початку кожної робочої зміни.", "Бригадир распределяет задачи в начале каждой рабочей смены."),
        ("kontrola jakości (dział QA)", "служба контролю якості", "отдел контроля качества (ОТК / QA)", "Każda partia wyrobów przechodzi przez rygorystyczną kontrolę jakości.", "Кожна партія виробів проходить суворий контроль якості.", "Каждая партия изделий проходит строгий контроль качества."),
        ("brak / wyrób wadliwy (odrzut)", "бракований виріб / брак", "бракованное изделие / брак", "Wadliwe obudowy odkładamy do czerwonego pojemnika na braki.", "Браковані корпуси відкладаємо в червоний ящик для браку.", "Бракованные корпуса откладываем в красный ящик для брака."),
        ("norma dzienna", "денна норма виробітку", "дневная норма выработки", "Dzisiaj musimy zrealizować normę tysiąca dwustu sztuk.", "Сьогодні ми повинні виконати денну норму 1200 штук.", "Сегодня мы должны выполнить дневную норму в 1200 штук."),
        ("stop awaryjny (grzybek)", "кнопка аварійної зупинки", "кнопка аварийной остановки (грибок)", "W razie zacięcia taśmy natychmiast uderz w czerwony grzybek stopu.", "У разі заклинювання лінії негайно натисни червоний грибок зупинки.", "При заклинивании ленты немедленно ударь по красной кнопке стоп."),
        ("szkolenie stanowiskowe BHP", "інструктаж з безпеки на робочому місці", "инструктаж по технике безопасности на рабочем месте", "Przed rozpoczęciem pracy każdy podpisuje szkolenie stanowiskowe BHP.", "Перед початком роботи кожен підписує інструктаж з безпеки праці.", "Перед началом работы каждый подписывает инструктаж по безопасности."),
        ("buty ze stalowym noskiem", "захисне взуття зі сталевим носком", "спецобувь со стальным носком", "Wejście na halę fabryczną bez butów ze stalowym noskiem jest zabronione.", "Вхід у заводський цех без захисного взуття з металевим носком суворо заборонений.", "Вход в заводской цех без спецобуви со стальным носком строго запрещён."),
        ("czepek ochronny i fartuch", "захисна шапочка та фартух", "защитная шапочка для волос и фартук", "Na linii przetwórstwa spożywczego czepek musi całkowicie zakrywać włosy.", "На харчовій лінії шапочка повинна повністю закривати волосся.", "На пищевом производстве шапочка обязана полностью закрывать волосы."),
        ("rękawice antystatyчні (ESD)", "антистатичні рукавички для мікроелектроніки", "антистатические перчатки для электроники (ESD)", "Przy montażu płytek PCB używamy rękawic z ochroną antystatyczną.", "При складанні плат PCB використовуємо антистатичні рукавички.", "При монтаже плат PCB используем антистатические перчатки."),
        ("karta zakładowa (przepustka)", "заводська електронна перепустка", "заводской электронный пропуск", "Przyłóż kartę zakładową do kołowrotka przy wejściu na zakład.", "Приклади електронну перепустку до турнікета на прохідній заводу.", "Приложи пропуск к турникету на заводской проходной."),
        ("awaria maszyny", "поломка виробничого верстата", "поломка станка / оборудования", "Zgłaszam awarię zgrzewarki, wezwijcie mechanika dyżurnego.", "Повідомляю про поломку запаювача, покличте чергового техніка.", "Сообщаю о поломке станка, вызовите дежурного механика."),
        ("pakowanie i foliowanie", "пакування та обмотка плівкою", "упаковка и обмотка термоусадочной плёнкой", "Gotowe wyroби trafiają do automatu foliującego.", "Готові вироби надходять до пакувального автомата.", "Готовые изделия поступают в упаковочный автомат."),
        ("etykietarka automatyczna", "автоматичний етикетувальник", "автоматический аппликатор этикеток", "Sprawdź, czy na rolce etykietarki nie skończyła się taśma.", "Перевір, чи на бобіні етикетувальника не закінчилася стрічка.", "Проверь, не закончилась ли лента в этикетировочном аппарате."),
        ("partia produkcyjna (lot number)", "номер виробничої партії", "номер производственной партии (лот)", "Wydrukuj numer partii i datę ważności na spodzie puszki.", "Надрукуй номер партії та термін придатності на дні банки.", "Напечатай номер партии и срок годности на донышке банки."),
        ("waga precyzyjna", "високоточні електронні ваги", "прецизионные контрольные весы", "Waga każdego gotowego opakowania musi wynosić dokładnie 500 gramów.", "Вага кожної готової пачки повинна становити рівно 500 грамів.", "Вес каждой готовой пачки должен составлять ровно 500 граммов."),
        ("nadgodziny płatne", "оплачувані понаднормові години", "оплачиваемые сверхурочные часы", "Za pracę w nadgodzinach w nocy przysługuje dodatek stu procent.", "За роботу в надурочні години вночі належить доплата 100%.", "За работу в сверхурочные часы ночью полагается доплата 100%."),
        ("praca akordowa (akord)", "відрядна система оплати праці", "сдельная оплата труда (аккорд)", "Na pakowaniu stawka zależy od akordu: im więcej zapakujesz, tym więcej zarobisz.", "На фасуванні ставка залежить від відрядності: більше зробиш — більше заробиш.", "На фасовке сдельная оплата: чем больше упакуешь, тем больше заработаешь."),
        ("zmiana poranna / popołudniowa / nocna", "ранкова, денна та нічна зміна (трьохзмінка)", "утренняя, дневная и ночная смены", "W tym tygodniu pracuję na nockach od godziny dwudziestej drugiej.", "Цього тижня я працюю в нічну зміну з 22:00.", "На этой неделе я работаю в ночную смену с 22:00."),
        ("przerwa regeneracyjna (śniadaniowa)", "регламентована перерва на обід", "регламентированный перерыв на обед", "Mamy dwadzieścia minut płatnej przerwy śniadaniowej o dziesiątej.", "Маємо двадцять хвилин оплачуваної обідньої перерви о десятій.", "У нас есть двадцать минут оплачиваемого обеда в десять часов."),
        ("sanitariaty i szatnia pracownicza", "роздягальня та санвузол для персоналу", "раздевалка и шкафчики для персонала", "W szafce czystej zostawiasz ubranie codzienne, a w brudnej robocze.", "У чистій шафці залишаєш звичайний одяг, а в брудній робочий.", "В чистом шкафчике оставляешь повседневную одежду, а в грязном робу."),
        ("czyszczenie stanowiska pracy (5S)", "прибирання робочого місця за стандартом 5S", "уборка рабочего места по японской системе 5S", "Przed zdaniem zmiany musimy uporządkować i zamieść stanowisko.", "Перед здачею зміни мусимо прибрати та підмести робоче місце.", "Перед сдачей смены нужно навести идеальный порядок на рабочем месте."),
        ("wkrętak automatyczny", "пневматичний або електричний шурупокрут", "электрический винтовёрт на подвесе", "Ustaw odpowiedni moment dokręcania na wkrętaku pneumatycznym.", "Вистав правильний крутний момент на шурупокруті.", "Выстави правильный крутящий момент на винтовёрте."),
        ("płytka drukowana (PCB)", "друкована плата електроніки", "печатная плата электроники (PCB)", "Uważaj, żeby nie dotknąć styków scalonych gołą dłonią.", "Обережно, не торкайся контактів мікросхеми голою рукою.", "Осторожно, не касайся контактов микросхемы голой рукой."),
        ("lutownica i odsysacz", "паяльна станція та відсмоктувач припою", "паяльная станция и оловоотсос", "Popraw zimny lut na złączu zasilania przy pomocy lutownicy.", "Поправ холодну пайку на роз’ємі живлення паяльником.", "Поправ непропаянный контакт на разъёме питания паяльником."),
        ("obróbka mięsa / rozbiór", "обробка м’яса та розбирання на м’ясокомбінаті", "обработка мяса и обвалка на мясокомбинате", "Na rozbiorze drobiu pracujemy w rękawicach antyprzecięciowych ze stali.", "На обробці птиці працюємо в захисних кольчужних рукавицях.", "На разделке птицы работаем в защитных кольчужных перчатках."),
        ("strefa chłodnicza (chłodnia zakładowa)", "заводський холодильний цех (+2°C)", "производственный холодильный цех (+2°C)", "W chłodni zakładowej temperatura wynosi od zera do czterech stopni.", "У заводському холодильнику температура становить від 0 до 4°C.", "В заводском холодильном цехе температура составляет от 0 до 4°C."),
        ("pojemnik plastikowy (euroskrzynka)", "стандартний пластиковий харчовий ящик", "пластиковый ящик для готовой продукции", "Układaj gotowe wędliny do czystych żółtych pojemników euro.", "Складай готові вироби в чисті пластикові ящики.", "Складывай готовые изделия в чистые пластиковые ящики."),
        ("magazyn wyrobów gotowych", "склад готової заводської продукції", "склад готовой продукции завода", "Palety z gotowym towarem odwozimy do magazynu wyrobów gotowych.", "Палети з готовим товаром відвозимо на призаводський склад.", "Паллеты с готовым товаром отвозим на склад готовой продукции."),
        ("kierownik produkcji", "начальник виробничого цеху", "начальник производства цеха", "Kierownik produkcji przeprowadza cotygodniowy audyt wydajności.", "Керівник виробництва проводить щотижневий аудит продуктивності.", "Начальник производства проводит еженедельный аудит выработки."),
        ("premia regulaminowa", "щомісячна премія за відсутність прогулів та браків", "ежемесячная премия за выполнение плана и без брака", "Jeśli nie opuścisz żadnego dnia w miesiącu, otrzymasz premię frekwencyjną.", "Якщо не пропустиш жодного дня, отримаєш премію за присутність.", "Если не пропустишь ни одного дня, получишь надбавку за посещаемость."),
    ]

    content.append("const professionManufacturing = ProfessionItem(")
    content.append("  id: 'manufacturing',")
    content.append("  emoji: '🏭',")
    content.append("  titlePl: 'Produkcja i Zakłady Przemysłowe',")
    content.append("  titleUk: 'Виробництво та заводи',")
    content.append("  titleRu: 'Производство и заводы',")
    content.append("  descPl: 'Linia produkcyjna, kontrola jakości, brygadzista, BHP, normy dzienne i awarie maszyn.',")
    content.append("  descUk: 'Виробнича лінія, контроль якості, бригадир, безпека праці (BHP), денні норми та поломки верстатів.',")
    content.append("  descRu: 'Производственная линия, контроль качества, бригадир, безопасность труда (BHP), дневные нормы и поломки станков.',")
    content.append("  vocabulary: [")
    for v in mfg_vocabs:
        content.append(vocab(*v))
    content.append("  ],")
    content.append("""  scenario: Scenario(
    key: 'prof_manufacturing',
    emoji: '🏭',
    titlePl: 'Produkcja i Zakłady Przemysłowe',
    titleUk: 'Виробництво та Заводи',
    titleRu: 'Производство и Заводы',
    level: 'A2–B1',
    npcRole: 'brygadzista zmiany lub kontroler jakości w fabryce',
    setting: 'Instruktaż stanowiskowy na linii produkcyjnej, kontrola jakości i grafik zmianowy.',
    vocab: ['linia produkcyjna', 'brygadzista', 'kontrola jakości', 'grafik', 'BHP', 'nadgodziny'],
    subScenarios: [
      SubScenario(
        id: 'mfg_training',
        titlePl: 'Pierwszy dzień: szkolenie u brygadzisty',
        titleUk: 'Перший день: інструктаж у бригадира',
        titleRu: 'Первый день: инструктаж у бригадира',
        descPl: 'Zapoznanie ze stanowiskiem pracy, przepisami BHP i wymogami odzieży ochronnej.',
        descUk: 'Ознайомлення з робочим місцем, технікою безпеки (BHP) та захисним спецодягом.',
        descRu: 'Ознакомление с рабочим местом, техникой безопасности (BHP) и спецодеждой.',
        starterHintPl: 'Dzień dobry panie Januszu, zgłaszam się na pierwszą zmianę. Gdzie mogę pobrać ubranie robocze i kartę zakładową?',
        starterHintUk: 'Доброго дня, пане Януш, прибув на першу зміну. Де отримати спецодяг та перепустку?',
        starterHintRu: 'Добрый день, господин Януш, прибыл на первую смену. Где получить спецодежду и пропуск?',
        plotTwist: 'Okazuje się, że brakuje butów ze stalowym noskiem w twoim rozmiarze i trzeba iść do magazynu BHP.',
        vocab: ['brygadzista', 'BHP', 'linia produkcyjna', 'karta zakładowa', 'fartuch'],
        npcRole: 'Brygadzista zmiany na hali montażowej',
        setting: 'Głośna hala produkcyjna fabryki elektroniki użytkowej.',
        npcFirstStarterPl: 'Cześć! Jestem Janusz, twój brygadzista. Zanim podejdziesz do taśmy, musimy omówić zasady BHP. Masz buty ze stalowym noskiem i identyfikator?',
        npcFirstStarterUk: 'Привіт! Я Януш, твій бригадир. Перш ніж підійдеш до стрічки, обговоримо техніку безпеки. Маєш робоче взуття з металевим носком?',
        npcFirstStarterRu: 'Привет! Я Януш, твой бригадир. Прежде чем встать к конвейеру, обсудим технику безопасности. У тебя есть спецобувь с металлическим носком?',
      ),
      SubScenario(
        id: 'mfg_defect',
        titlePl: 'Kontrola jakości: błąd na taśmie i stop awaryjny',
        titleUk: 'Контроль якості: брак на стрічці та аварійна зупинка',
        titleRu: 'Контроль качества: брак на ленте и аварийный стоп',
        descPl: 'Wykrycie wadliwej partii wyrobów i wezwanie technika do usunięcia usterki.',
        descUk: 'Виявлення бракованої партії деталей та виклик техніка для налаштування верстата.',
        descRu: 'Обнаружение бракованной партии деталей и вызов наладчика для ремонта станка.',
        starterHintPl: 'Pani Grażyno, zatrzymałem taśmę, bo w tej partii zgrzewarka krzywo nakłada folię.',
        starterHintUk: 'Пані Гражино, я зупинив лінію, бо в цій партії запаювач криво клеїть плівку.',
        starterHintRu: 'Пани Гражина, я остановил конвейер, потому что в этой партии запайщик криво накладывает плёнку.',
        plotTwist: 'Kontrolerka podejrzewa, że wadliwa może być cała poprzednia paleta wyrobów.',
        vocab: ['kontrola jakości', 'brak', 'odrzut', 'stop awaryjny', 'awaria'],
        npcRole: 'Kontrolerka jakości z działu QA',
        setting: 'Stanowisko inspekcji wizualnej przy taśmie pakującej.',
        npcFirstStarterPl: 'Stój, zatrzymaj taśmę! Widzę pęknięcia na obudowach. Kiedy zauważyłeś pierwszy wadliwy element?',
        npcFirstStarterUk: 'Стій, зупини лінію! Бачу тріщини на корпусах. Коли ти помітив першу браковану деталь?',
        npcFirstStarterRu: 'Стой, останови ленту! Вижу трещины на корпусах. Когда ты заметил первую бракованную деталь?',
      ),
      SubScenario(
        id: 'mfg_schedule',
        titlePl: 'Kierownik produkcji: grafik i nadgodziny',
        titleUk: 'Начальник виробництва: графік та понаднормові',
        titleRu: 'Начальник производства: график и сверхурочные',
        descPl: 'Ustalenie planu pracy na kolejny miesiąc, zgoda na nadgodziny i premia akordowa.',
        descUk: 'Узгодження графіка змін на наступний місяць, понаднормові години та премія за виконання плану.',
        descRu: 'Согласование графика смен на следующий месяц, сверхурочные часы и премия за перевыполнение нормы.',
        starterHintPl: 'Dzień dobry panie kierowniku. Chciałbym zapytać o grafik na przyszły tydzień i możliwość wzięcia soboty.',
        starterHintUk: 'Доброго дня, пане керівнику. Хотів би запитати про графік на наступний тиждень та можливість вийти в суботу.',
        starterHintRu: 'Добрый день, господин начальник. Хотел спросить про график на следующую неделю и возможность выйти в субботу.',
        plotTwist: 'Kierownik oferuje dodatkową premię, jeśli zgodzisz się przejść na dwa tygodnie na nocki.',
        vocab: ['grafik', 'nadgodziny', 'norma', 'zmiana nocna', 'premia'],
        npcRole: 'Kierownik działu planowania produkcji',
        setting: 'Biuro mistrza produkcji z widokiem na halę fabryczną.',
        npcFirstStarterPl: 'Dzień dobry. Mamy duże zamówienie eksportowe. Szukam chętnych na dodatkowe nadgodziny w weekend. Jak u ciebie z dyspozycyjnością?',
        npcFirstStarterUk: 'Доброго дня. Маємо велике експортне замовлення. Шукаю охочих на додаткові зміни на вихідних. Як у тебе з графіком?',
        npcFirstStarterRu: 'Добрый день. У нас крупный экспортный заказ. Ищу желающих на дополнительные смены в выходные. Как у тебя со свободным временем?',
      ),
    ],
  ),
);""")

    # List of all 6 professions
    content.append("""
/// Полный список всех 6 ключевых профессиональных направлений в Польше
const kAllProfessions = <ProfessionItem>[
  professionLogistics,
  professionConstruction,
  professionGastronomy,
  professionCleaning,
  professionIT,
  professionManufacturing,
];
""")

    output = "\n".join(content)
    with open('lib/features/professions/professions_data.dart', 'w', encoding='utf-8') as f:
        f.write(output)
    print("Generated expanded professions_data.dart with 6 professions and 192 terms!")

if __name__ == '__main__':
    main()
