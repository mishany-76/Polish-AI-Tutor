# -*- coding: utf-8 -*-
import json
import os
import re

print("Starting clean_all_drills.py...")

# 1. CLEAN FALSE FRIENDS
with open('assets/drills/false_friends.json', 'r', encoding='utf-8') as f:
    ff_raw = json.load(f)

clean_ff = []
seen_ff = set()
for item in ff_raw:
    pl = item.get('pl', '')
    ru = item.get('ru', '')
    uk = item.get('uk', '')
    # Skip synthetic garbage with '#' or 'w kontekście'
    if '#' in pl or '#' in ru or '#' in uk or 'w kontekście' in pl.lower() or 'употребление #' in ru:
        continue
    pl_clean = re.sub(r'\s*#\d+', '', pl).strip()
    key = pl_clean.lower()
    if key not in seen_ff and pl_clean:
        seen_ff.add(key)
        item['pl'] = pl_clean
        item['ru'] = re.sub(r'\s*#\d+', '', ru).strip()
        item['uk'] = re.sub(r'\s*#\d+', '', uk).strip()
        clean_ff.append(item)

print(f"False Friends: {len(ff_raw)} -> {len(clean_ff)} clean items.")
with open('assets/drills/false_friends.json', 'w', encoding='utf-8') as f:
    json.dump(clean_ff, f, ensure_ascii=False, indent=2)

# 2. CLEAN NUMBERS & PRICES
with open('assets/drills/numbers_prices.json', 'r', encoding='utf-8') as f:
    np_raw = json.load(f)

clean_np = []
seen_np = set()
for item in np_raw:
    sp = item.get('spokenPl', '')
    # Clean train departure suffix or hash
    sp = re.sub(r'\s*\(odjazd pociągu\s*#\d+\)', '', sp, flags=re.IGNORECASE)
    sp = re.sub(r'\s*#\d+', '', sp).strip()
    item['spokenPl'] = sp
    item['explainUk'] = re.sub(r'\s*#\d+', '', item.get('explainUk', '')).strip()
    item['explainRu'] = re.sub(r'\s*#\d+', '', item.get('explainRu', '')).strip()
    key = (sp.lower(), item.get('correct', ''))
    if key not in seen_np and sp:
        seen_np.add(key)
        clean_np.append(item)

print(f"Numbers & Prices: {len(np_raw)} -> {len(clean_np)} clean items.")
with open('assets/drills/numbers_prices.json', 'w', encoding='utf-8') as f:
    json.dump(clean_np, f, ensure_ascii=False, indent=2)

# 3. CLEAN & ENRICH AUDIO WORDS
with open('assets/drills/audio_words.json', 'r', encoding='utf-8') as f:
    audio_raw = json.load(f)

clean_audio = []
seen_audio = set()

# Preserve good genuine items from audio_raw
for item in audio_raw:
    pl = item.get('pl', '')
    ru = item.get('ru', '')
    uk = item.get('uk', '')
    if '#' in pl or '#' in ru or '#' in uk or 'początkowy etap' in pl.lower() or 'poczatkowy etap' in pl.lower():
        continue
    pl_clean = re.sub(r'\s*#\d+', '', pl).strip()
    key = pl_clean.lower()
    if key not in seen_audio and pl_clean:
        seen_audio.add(key)
        clean_audio.append({
            'pl': pl_clean,
            'uk': re.sub(r'\s*#\d+', '', uk).strip(),
            'ru': re.sub(r'\s*#\d+', '', ru).strip(),
            'distractorsUk': [re.sub(r'\s*#\d+', '', d).strip() for d in item.get('distractorsUk', [])],
            'distractorsRu': [re.sub(r'\s*#\d+', '', d).strip() for d in item.get('distractorsRu', [])]
        })

print(f"Base genuine audio items: {len(clean_audio)}")

# Add seed words from seed_words_data.dart
with open('lib/features/review/data/seed_words_data.dart', 'r', encoding='utf-8') as f:
    dart_text = f.read()

pattern = re.compile(r"SeedWord\s*\(\s*'([^']+)'\s*,\s*'([^']+)'\s*,\s*'([^']+)'\s*\)")
for match in pattern.finditer(dart_text):
    pl = match.group(1).strip()
    uk = match.group(2).strip()
    ru = match.group(3).strip()
    key = pl.lower()
    if key not in seen_audio and pl:
        seen_audio.add(key)
        clean_audio.append({
            'pl': pl,
            'uk': uk,
            'ru': ru,
            'distractorsUk': ['неправильний варіант', 'інша дія'],
            'distractorsRu': ['неправильный вариант', 'другое действие']
        })

print(f"Audio items after seed words: {len(clean_audio)}")

# Curated practical Polish spoken expressions & sentences for audio drill
curated_phrases = [
    # Приветствия и вежливость
    ("Dzień dobry", "Доброго дня", "Добрый день"),
    ("Dobry wieczór", "Добрий вечір", "Добрый вечер"),
    ("Do widzenia", "До побачення", "До свидания"),
    ("Do zobaczenia jutro", "До зустрічі завтра", "До завтра"),
    ("Na razie", "Бувай / До зустрічі", "Пока / До скорого"),
    ("Miłego dnia", "Гарного дня", "Хорошего дня"),
    ("Wzajemnie", "Взаємно", "Взаимно"),
    ("Dziękuję bardzo", "Дуже дякую", "Большое спасибо"),
    ("Proszę bardzo", "Будь ласка", "Пожалуйста"),
    ("Nie ma za co", "Нема за що", "Не за что"),
    ("Przepraszam bardzo", "Дуже перепрошую", "Очень извиняюсь"),
    ("Przepraszam, czy pan mówi po angielsku?", "Вибачте, чи ви говорите англійською?", "Извините, вы говорите по-английски?"),
    ("Słucham pana?", "Слухаю вас?", "Слушаю вас?"),
    ("Czy mogę o coś zapytać?", "Чи можу я про щось запитати?", "Могу я кое-что спросить?"),
    ("Bardzo mi miło", "Дуже приємно", "Очень приятно"),
    ("Wszystkiego najlepszego", "Всього найкращого", "Всего наилучшего"),
    ("Życzę smacznego", "Смачного", "Приятного аппетита"),
    ("Na zdrowie", "Будьте здорові / На здоров'я", "Будьте здоровы / За здоровье"),
    ("Powodzenia", "Успіхів / Хай щастить", "Удачи"),
    ("Przepraszam za spóźnienie", "Вибачте за запізнення", "Извините за опоздание"),
    ("Jestem już na miejscu", "Я вже на місці", "Я уже на месте"),
    ("Zadzwoń do mnie później", "Подзвони мені пізніше", "Позвони мне позже"),
    ("Nie rozumiem, proszę mówić wolniej", "Не розумію, будь ласка, говоріть повільніше", "Не понимаю, пожалуйста, говорите медленнее"),
    ("Jak to się pisze po polsku?", "Як це пишеться польською?", "Как это пишется по-польски?"),
    ("Czy może pan to powtórzyć?", "Чи можете ви це повторити?", "Можете ли вы это повторить?"),

    # Магазин, касса и покупки
    ("Czy ma pan aplikację?", "Чи маєте ви додаток?", "У вас есть приложение?"),
    ("Czy zbiera pan punkty?", "Чи збираєте ви бали?", "Вы собираете баллы?"),
    ("Płatność kartą czy gotówką?", "Оплата карткою чи готівкою?", "Оплата картой или наличными?"),
    ("Płatność zbliżeniowo, poproszę", "Оплата безконтактно, будь ласка", "Бесконтактная оплата, пожалуйста"),
    ("Poproszę reklamówkę", "Пакет, будь ласка", "Пакет, пожалуйста"),
    ("Czy potrzebuje pan potwierdzenia?", "Чи потрібен вам чек?", "Вам нужен чек?"),
    ("Paragon jest w środku", "Чек усередині", "Чек внутри"),
    ("Gdzie znajdę pieczywo?", "Де знайти хлібобулочні вироби?", "Где найти хлеб?"),
    ("Ile kosztuje ten ser?", "Скільки коштує цей сир?", "Сколько стоит этот сыр?"),
    ("Czy ten towar jest w promocji?", "Чи цей товар на акції?", "Этот товар по акции?"),
    ("Kasa jest nieczynna", "Каса не працює", "Касса закрыта"),
    ("Proszę przejść do kasy numer dwa", "Будь ласка, перейдіть до другої каси", "Пройдите на кассу номер два"),
    ("Kasa samoobsługowa przyjmuje tylko karty", "Каса самообслуговування приймає лише картки", "Касса самообслуживания принимает только карты"),
    ("Połóż artykuł w strefie pakowania", "Покладіть товар у зону пакування", "Положите товар в зону упаковки"),
    ("Wymagana pomoc asystenta", "Потрібна допомога співробітника", "Требуется помощь консультанта"),
    ("Zatwierdź płatność na terminalu", "Підтвердьте оплату на терміналі", "Подтвердите оплату на терминале"),
    ("Wpisz kod PIN", "Введіть пін-код", "Введите пин-код"),
    ("Transakcja odrzucona", "Транзакція відхилена", "Транзакция отклонена"),
    ("Brak środków na koncie", "Недостатньо коштів на рахунку", "Недостаточно средств на счете"),
    ("Odbierz paragon", "Заберіть чек", "Заберите чек"),

    # Транспорт и город
    ("Poproszę bilet 20-minutowy", "Квиток на 20 хвилин, будь ласка", "Билет на 20 минут, пожалуйста"),
    ("Bilet normalny na pierwszą strefę", "Звичайний квиток на першу зону", "Стандартный билет на первую зону"),
    ("Bilet ulgowy dla studenta", "Пільговий квиток для студента", "Льготный билет для студента"),
    ("Czy ten autobus jedzie na Dworzec Centralny?", "Цей автобус їде до Центрального вокзалу?", "Этот автобус едет на Центральный вокзал?"),
    ("Gdzie jest najbliższa stacja metra?", "Де найближча станція метро?", "Где ближайшая станция метро?"),
    ("Proszę skasować bilet w kasowniku", "Будь ласка, прокомпостуйте квиток у валідаторі", "Прокомпостируйте билет в валидаторе"),
    ("Pociąg ma 15 minut opóźnienia", "Потяг затримується на 15 хвилин", "Поезд опаздывает на 15 минут"),
    ("Następna stacja: Politechnika", "Наступна станція: Політехніка", "Следующая станция: Политехника"),
    ("Proszę zachować ostроżność", "Будьте обережні", "Соблюдайте осторожность"),
    ("Drzwi zamykają się", "Двері зачиняються", "Двери закрываются"),
    ("Kontrola biletów, proszę przygotować bilety", "Контроль квитків, підготуйте квитки", "Контроль билетов, приготовьте билеты"),
    ("Przystanek na żądanie", "Зупинка на вимогу", "Остановка по требованию"),
    ("Gdzie mogę doładować kartę miejską?", "Де можна поповнити міську картку?", "Где пополнить транспортную карту?"),
    ("Który peron na pociąg do Krakowa?", "Яка колія на потяг до Кракова?", "С какой платформы поезд на Краков?"),

    # Аренда жилья
    ("Dzwonię w sprawie ogłoszenia o wynajem", "Телефоную щодо оголошення про оренду", "Звоню по объявлению об аренде"),
    ("Czy mieszkanie jest jeszcze aktualne?", "Чи квартира ще здається?", "Квартира ещё сдается?"),
    ("Jaki jest koszt najmu wraz z opłatami?", "Яка вартість оренди з комунальними?", "Какова стоимость аренды со всеми счетами?"),
    ("Kiedy można obejrzeć mieszkanie?", "Коли можна подивитися квартиру?", "Когда можно посмотреть квартиру?"),
    ("Kaucja wynosi jednomiesięczny czynsz", "Застава дорівнює одномісячній оренді", "Залог равен аренде за один месяц"),
    ("Opłaty licznikowe według zużycia", "Оплата за лічильниками за споживанням", "Счета по счетчикам по потреблению"),
    ("Czynsz administracyjny do spółdzielni", "Комунальний внесок до кооперативу", "Административный сбор в кооператив"),
    ("Umowa najmu okazjonalnego", "Договір оказіональної оренди", "Договор оказионального найма"),
    ("Podpisanie protokołu zdawczo-odbiorczego", "Підписання акту прийому-передачі", "Подписание акта приема-передачи"),
    ("Zepsuta pralka w łazience", "Зламана пральна машина у ванній", "Сломанная стиральная машина в ванной"),
    ("Cieknący kran w kuchni", "Кран протікає на кухні", "Протекающий кран на кухне"),
    ("Ogrzewanie miejskie czy gazowe?", "Опалення міське чи газове?", "Отопление городское или газовое?"),

    # Банк и финансы
    ("Chciałbym otworzyć konto osobiste", "Я хотів би відкрити особистий рахунок", "Я хотел бы открыть личный счет"),
    ("Jaki jest kod BLIK?", "Який код БЛІК?", "Какой код БЛИК?"),
    ("Wygeneruj kod w aplikacji bankowej", "Згенеруйте код у додатку банку", "Сгенерируйте код в приложении банка"),
    ("Potwierdź przelew w aplikacji mobilnej", "Підтвердьте переказ у мобільному додатку", "Подтвердите перевод в мобильном приложении"),
    ("Maksymalny dzienny limit wypłaty", "Максимальний денний ліміт зняття", "Максимальный суточный лимит снятия"),
    ("Karta płatnicza została zablokowana", "Платіжна картка заблокована", "Платежная карта заблокирована"),
    ("Prowizja za przelew zagraniczny", "Комісія за закордонний переказ", "Комиссия за международный перевод"),
    ("Numer rachunku bankowego IBAN", "Номер банківського рахунку IBAN", "Номер банковского счета IBAN"),
    ("Wypłata gotówki z bankomatu bez prowizji", "Зняття готівки в банкоматі без комісії", "Снятие наличных в банкомате без комиссии"),
    ("Aktualny kurs euro w kantorze", "Поточний курс євро в обміннику", "Текущий курс евро в обменнике"),

    # Врач и аптека
    ("Chciałbym zarejestrować się do lekarza", "Я хотів би записатися до лікаря", "Я хотел бы записаться к врачу"),
    ("Czy ma pan numer PESEL?", "Чи маєте ви номер PESEL?", "У вас есть номер PESEL?"),
    ("Mam wysoką gorączkę i ból gardła", "У мене висока температура і біль у горлі", "У меня высокая температура и болит горло"),
    ("Od kiedy występują te objawy?", "Відколи з'явилися ці симптоми?", "С какого времени эти симптомы?"),
    ("Proszę brać te tabletki dwa razy dziennie", "Приймайте ці пігулки двічі на день", "Принимайте эти таблетки дважды в день"),
    ("Lek dostępny wyłącznie na receptę", "Ліки відпускаються лише за рецептом", "Препарат доступен только по рецепту"),
    ("Czy jest tańszy zamiennik tego leku?", "Чи є дешевший аналог цих ліків?", "Есть ли более дешевый аналог этого лекарства?"),
    ("Krople do nosa i syrop na kaszel", "Краплі в ніс та сироп від кашлю", "Капли в нос и сироп от кашля"),
    ("Proszę zmierzyć ciśnienie tętnicze", "Будь ласка, поміряйте тиск", "Пожалуйста, измерьте давление"),
    ("Zwolnienie lekarskie L4 dla pracodawcy", "Лікарняний L4 для роботодавця", "Больничный лист L4 для работодателя"),

    # Работа и ужонд
    ("Szukam pracy na pełny etat", "Шукаю роботу на повну ставку", "Ищу работу на полный день"),
    ("Umowa o pracę na czas określony", "Трудовий договір на визначений термін", "Трудовой договор на определенный срок"),
    ("Umowa zlecenie ze stawką godzinową", "Договір доручення з погодинною ставкою", "Договор поручения с почасовой ставкой"),
    ("Wynagrodzenie brutto i netto", "Зарплата до податків та на руки", "Зарплата до налогов и на руки"),
    ("Wniosek o zezwolenie na pobyt czasowy", "Заява на дозвіл на тимчасове проживання", "Заявление на ВНЖ (карта побыту)"),
    ("Wniosek o nadanie numeru PESEL", "Заява на отримання номера PESEL", "Заявление на получение номера PESEL"),
    ("Złożenie odcisków palców w urzędzie", "Здача відбитків пальців в ужонді", "Сдача отпечатков пальцев в учреждении"),
    ("Decyzja pozyтивна wojewody", "Позитивне рішення воєводи", "Положительное решение воеводы"),
    ("Odbiór karty pobytu w okienku", "Отримання карти побиту у віконці", "Получение карты побыту в окне выдачи"),
    ("Zeznanie podatkowe PIT-37", "Податкова декларація PIT-37", "Налоговая декларация PIT-37"),

    # Кафе и ресторан
    ("Poproszę stolik dla dwóch osób", "Столик на двох, будь ласка", "Столик на двоих, пожалуйста"),
    ("Czy możemy prosić o menu?", "Чи можна попросити меню?", "Можно меню, пожалуйста?"),
    ("Co pan poleca z dań głównych?", "Що ви порадите з основних страв?", "Что вы порекомендуете из основных блюд?"),
    ("Poproszę zupę dnia i herbatę", "Суп дня та чай, будь ласка", "Суп дня и чай, пожалуйста"),
    ("Czy ten sos jest ostry?", "Чи цей соус гострий?", "Этот соус острый?"),
    ("Poproszę rachunek", "Рахунок, будь ласка", "Счет, пожалуйста"),
    ("Będziemy płacić razem czy osobno?", "Будемо платити разом чи окремо?", "Будем платить вместе или раздельно?"),
    ("Reszty nie trzeba, dziękuję", "Решти не треба, дякую", "Сдачи не нужно, спасибо"),
    ("Jedzenie na miejscu czy na wynos?", "Тут чи з собою?", "Здесь или с собой?"),
    ("Kawa z mlekiem na wynos, poproszę", "Кава з молоком із собою, будь ласка", "Кофе с молоком с собой, пожалуйста")
]

for pl, uk, ru in curated_phrases:
    key = pl.lower().strip()
    if key not in seen_audio:
        seen_audio.add(key)
        clean_audio.append({
            'pl': pl.strip(),
            'uk': uk.strip(),
            'ru': ru.strip(),
            'distractorsUk': ['інша фраза', 'неправильна дія'],
            'distractorsRu': ['другая фраза', 'неверный вариант']
        })

print(f"Final clean Audio Words: {len(clean_audio)}")

with open('assets/drills/audio_words.json', 'w', encoding='utf-8') as f:
    json.dump(clean_audio, f, ensure_ascii=False, indent=2)

print("Done clean_all_drills.py!")
