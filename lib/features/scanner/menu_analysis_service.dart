import 'dart:convert';

import '../../core/ai_client/ai_client.dart';
import '../../core/db/app_database.dart';
import 'translation_service.dart';

/// Блюдо или напиток из меню.
class MenuItemDish {
  const MenuItemDish({
    required this.namePl,
    required this.translation,
    required this.category,
    required this.description,
    this.ingredients = const [],
    this.allergens = const [],
    this.price,
    this.isVegetarian = false,
    this.isTraditionalPolish = false,
    required this.orderPhrase,
  });

  final String namePl;
  final String translation;
  final String category;
  final String description;
  final List<String> ingredients;
  final List<String> allergens;
  final String? price;
  final bool isVegetarian;
  final bool isTraditionalPolish;
  final String orderPhrase;

  Map<String, dynamic> toJson() => {
        'name_pl': namePl,
        'translation': translation,
        'category': category,
        'description': description,
        'ingredients': ingredients,
        'allergens': allergens,
        'price': price,
        'is_vegetarian': isVegetarian,
        'is_traditional_polish': isTraditionalPolish,
        'order_phrase': orderPhrase,
      };

  factory MenuItemDish.fromJson(Map<String, dynamic> j) {
    String s(dynamic v) => (v?.toString() ?? '').trim();
    final ingList = <String>[];
    if (j['ingredients'] is List) {
      for (final i in j['ingredients'] as List) {
        final str = s(i);
        if (str.isNotEmpty) ingList.add(str);
      }
    }
    final allList = <String>[];
    if (j['allergens'] is List) {
      for (final a in j['allergens'] as List) {
        final str = s(a);
        if (str.isNotEmpty) allList.add(str);
      }
    }

    final p = s(j['price']);
    final name = s(j['name_pl']).isNotEmpty ? s(j['name_pl']) : s(j['name']);

    return MenuItemDish(
      namePl: name.isNotEmpty ? name : 'Danie',
      translation: s(j['translation']).isNotEmpty ? s(j['translation']) : name,
      category: s(j['category']).isNotEmpty ? s(j['category']) : 'Dania główne',
      description: s(j['description']),
      ingredients: ingList,
      allergens: allList,
      price: (p.isNotEmpty && p != 'null') ? p : null,
      isVegetarian: j['is_vegetarian'] == true || j['vegetarian'] == true,
      isTraditionalPolish: j['is_traditional_polish'] == true ||
          j['traditional'] == true ||
          j['polish_classic'] == true,
      orderPhrase: s(j['order_phrase']).isNotEmpty
          ? s(j['order_phrase'])
          : 'Poproszę $name',
    );
  }
}

/// Полезная разговорная фраза для официанта.
class MenuPhraseItem {
  const MenuPhraseItem({
    required this.phrasePl,
    required this.translation,
    this.category = 'Zamówienie',
  });

  final String phrasePl;
  final String translation;
  final String category;

  Map<String, String> toJson() => {
        'phrase_pl': phrasePl,
        'translation': translation,
        'category': category,
      };

  factory MenuPhraseItem.fromJson(Map<String, dynamic> j) {
    return MenuPhraseItem(
      phrasePl: (j['phrase_pl'] as String? ?? '').trim(),
      translation: (j['translation'] as String? ?? '').trim(),
      category: (j['category'] as String? ?? 'Zamówienie').trim(),
    );
  }
}

/// Базовый список разговорных фраз для ресторана (доступен всегда офлайн).
const List<MenuPhraseItem> kDefaultRestaurantPhrasesUk = [
  MenuPhraseItem(
    phrasePl: 'Poproszę menu / kartę dań.',
    translation: 'Будь ласка, принесіть меню.',
    category: 'Початок',
  ),
  MenuPhraseItem(
    phrasePl: 'Co Pan / Pani poleca z tradycyjnych dań?',
    translation: 'Що ви порадите з традиційних страв?',
    category: 'Вибір',
  ),
  MenuPhraseItem(
    phrasePl: 'Czy to danie jest pikantne / ostre?',
    translation: 'Ця страва гостра?',
    category: 'Уточнення',
  ),
  MenuPhraseItem(
    phrasePl: 'Poproszę bez cebuli / bez kolendry.',
    translation: 'Будь ласка, без цибулі / без кінзи.',
    category: 'Вподобання',
  ),
  MenuPhraseItem(
    phrasePl: 'Czy w tym daniu jest gluten lub nabiał?',
    translation: 'Чи містить ця страва глютен або лактозу?',
    category: 'Алергени',
  ),
  MenuPhraseItem(
    phrasePl: 'Poproszę wodę niegazowaną z cytryną.',
    translation: 'Будь ласка, негазовану воду з лимоном.',
    category: 'Напої',
  ),
  MenuPhraseItem(
    phrasePl: 'Poproszę rachunek. Płatność kartą / BLIKiem.',
    translation: 'Будь ласка, рахунок. Оплата карткою / БЛІКом.',
    category: 'Оплата',
  ),
  MenuPhraseItem(
    phrasePl: 'Dziękuję, wszystko było bardzo pyszne!',
    translation: 'Дякую, все було дуже смачно!',
    category: 'Подяка',
  ),
];

const List<MenuPhraseItem> kDefaultRestaurantPhrasesRu = [
  MenuPhraseItem(
    phrasePl: 'Poproszę menu / kartę dań.',
    translation: 'Пожалуйста, меню / карту блюд.',
    category: 'Начало',
  ),
  MenuPhraseItem(
    phrasePl: 'Co Pan / Pani poleca z tradycyjnych dań?',
    translation: 'Что вы порекомендуете из традиционных блюд?',
    category: 'Выбор',
  ),
  MenuPhraseItem(
    phrasePl: 'Czy to danie jest pikantne / ostre?',
    translation: 'Это блюдо острое?',
    category: 'Уточнение',
  ),
  MenuPhraseItem(
    phrasePl: 'Poproszę bez cebuli / bez kolendry.',
    translation: 'Пожалуйста, без лука / без кинзы.',
    category: 'Предпочтения',
  ),
  MenuPhraseItem(
    phrasePl: 'Czy w tym daniu jest gluten lub nabiał?',
    translation: 'Содержит ли это блюдо глютен или лактозу?',
    category: 'Аллергены',
  ),
  MenuPhraseItem(
    phrasePl: 'Poproszę wodę niegazowaną z cytryną.',
    translation: 'Пожалуйста, негазированную воду с лимоном.',
    category: 'Напитки',
  ),
  MenuPhraseItem(
    phrasePl: 'Poproszę rachunek. Płatność kartą / BLIKiem.',
    translation: 'Пожалуйста, счёт. Оплата картой / БЛИКом.',
    category: 'Оплата',
  ),
  MenuPhraseItem(
    phrasePl: 'Dziękuję, wszystko było bardzo pyszne!',
    translation: 'Спасибо, всё было очень вкусно!',
    category: 'Благодарность',
  ),
];

const List<MenuPhraseItem> kDefaultRestaurantPhrasesPl = [
  MenuPhraseItem(
    phrasePl: 'Poproszę menu / kartę dań.',
    translation: 'Prośba o podanie menu.',
    category: 'Początek',
  ),
  MenuPhraseItem(
    phrasePl: 'Co Pan / Pani poleca ze specjałów lokalu?',
    translation: 'Pytanie o polecane dania.',
    category: 'Wybór',
  ),
  MenuPhraseItem(
    phrasePl: 'Czy to danie jest pikantne / ostre?',
    translation: 'Pytanie o ostrość potrawy.',
    category: 'Pytania',
  ),
  MenuPhraseItem(
    phrasePl: 'Poproszę bez cebuli / bez kolendry.',
    translation: 'Modyfikacja składników dania.',
    category: 'Składniki',
  ),
  MenuPhraseItem(
    phrasePl: 'Czy w tym daniu jest gluten lub nabiał?',
    translation: 'Informacja o alergenach.',
    category: 'Alergeny',
  ),
  MenuPhraseItem(
    phrasePl: 'Poproszę wodę niegazowaną ze świeżą cytryną.',
    translation: 'Zamówienie napoju.',
    category: 'Napoje',
  ),
  MenuPhraseItem(
    phrasePl: 'Poproszę rachunek. Płatność kartą / BLIKiem.',
    translation: 'Płatność i prośba o rachunek.',
    category: 'Płatność',
  ),
  MenuPhraseItem(
    phrasePl: 'Dziękuję serdecznie, wszystko było wyśmienite!',
    translation: 'Pochwała i podziękowanie obsłudze.',
    category: 'Podziękowanie',
  ),
];

/// Результат полного анализа меню польского заведения.
class MenuAnalysis {
  const MenuAnalysis({
    this.restaurantName,
    required this.cuisineType,
    required this.summary,
    required this.dishes,
    required this.orderPhrases,
    required this.rawText,
  });

  final String? restaurantName;
  final String cuisineType;
  final String summary;
  final List<MenuItemDish> dishes;
  final List<MenuPhraseItem> orderPhrases;
  final String rawText;

  factory MenuAnalysis.fromJson(
    Map<String, dynamic> j,
    String rawText,
    UiLang lang,
  ) {
    String? s(dynamic v) {
      final t = v?.toString().trim();
      return (t == null || t.isEmpty || t == 'null') ? null : t;
    }

    final dishesList = <MenuItemDish>[];
    if (j['dishes'] is List) {
      for (final item in j['dishes'] as List) {
        if (item is Map<String, dynamic>) {
          final dish = MenuItemDish.fromJson(item);
          if (dish.namePl.isNotEmpty) dishesList.add(dish);
        }
      }
    }

    final phrasesList = <MenuPhraseItem>[];
    if (j['order_phrases'] is List) {
      for (final p in j['order_phrases'] as List) {
        if (p is Map<String, dynamic>) {
          final phrase = MenuPhraseItem.fromJson(p);
          if (phrase.phrasePl.isNotEmpty) phrasesList.add(phrase);
        }
      }
    }

    if (phrasesList.isEmpty) {
      phrasesList.addAll(lang == UiLang.uk
          ? kDefaultRestaurantPhrasesUk
          : (lang == UiLang.pl
              ? kDefaultRestaurantPhrasesPl
              : kDefaultRestaurantPhrasesRu));
    }

    return MenuAnalysis(
      restaurantName: s(j['restaurant_name']),
      cuisineType: s(j['cuisine_type']) ??
          (lang == UiLang.pl
              ? 'Kuchnia polska / europejska'
              : (lang == UiLang.uk
                  ? 'Польська / європейська кухня'
                  : 'Польская / европейская кухня')),
      summary: s(j['summary']) ??
          (lang == UiLang.pl
              ? 'Rozpoznano pozycje z karty dań.'
              : (lang == UiLang.uk
                  ? 'Розпізнано позиції з меню ресторану.'
                  : 'Распознаны позиции из ресторанного меню.')),
      dishes: dishesList,
      orderPhrases: phrasesList,
      rawText: rawText,
    );
  }

  static MenuAnalysis fallbackHeuristic(String text, UiLang lang) =>
      buildOfflineAnalysis(text, lang);

  static MenuAnalysis buildOfflineAnalysis(String text, UiLang lang) =>
      MenuAnalysisService.buildOfflineAnalysis(text, lang);

  Map<String, dynamic> toJson() => {
        'restaurant_name': restaurantName,
        'cuisine_type': cuisineType,
        'summary': summary,
        'dishes': dishes.map((d) => d.toJson()).toList(),
        'order_phrases': orderPhrases.map((p) => p.toJson()).toList(),
        'raw_text': rawText,
      };
}

/// Сервис анализа ресторанного меню через OmniRoute и резервную энциклопедию.
class MenuAnalysisService {
  MenuAnalysisService({required this.aiClient, required this.db});

  final AiClient aiClient;
  final AppDatabase db;

  Future<MenuAnalysis> analyze({
    required String text,
    required UiLang lang,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw AiException('Текст меню порожній або не розпізнаний.');
    }

    final cacheKey =
        'menu_v2_${lang.name}_${trimmed.hashCode}_${trimmed.length}';
    final cached = await db.cacheGet(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final j = jsonDecode(cached) as Map<String, dynamic>;
        return MenuAnalysis.fromJson(j, trimmed, lang);
      } catch (_) {}
    }

    final targetLangName = lang == UiLang.uk
        ? 'украинском'
        : (lang == UiLang.pl ? 'польском' : 'русском');

    if (aiClient.apiKey.trim().isNotEmpty) {
      try {
        final sample =
            trimmed.length > 4000 ? trimmed.substring(0, 4000) : trimmed;

        final systemPrompt = '''
Ты — ведущий кулинарный эксперт и шеф-повар традиционной и современной польской гастрономии.
Твоя задача — тщательно разобрать текст ресторанного меню на польском языке и вернуть структурированный JSON для удобного выбора и заказа блюд на $targetLangName языке.

Правила:
1. Распознай название ресторана (если есть) и тип кухни (например: "Tradycyjna kuchnia polska", "Polska i włoska", "Pierogarnia").
2. Для каждого блюда извлеки:
   - "name_pl": точное оригинальное польское название (например: "Żurek staropolski w chlebku", "Pierogi ruskie ze skwarkami", "Kotlet schabowy z kapustą zasmażaną i ziemniakami").
   - "translation": точный и понятный перевод названия на $targetLangName язык.
   - "category": одна из категорий: "Zupy" (супы), "Dania główne" (основные блюда), "Przystawki" (закуски), "Desery" (десерты), "Napoje" (напитки), "Inne".
   - "description": аппетитное и точное описание, как блюдо приготовлено и с чем подается.
   - "ingredients": массив основных ингредиентов (например: ["zakwas żytni", "biała kiełbasa", "jajko", "majeranek"]).
   - "allergens": массив потенциальных аллергенов (например: ["gluten", "nabiał", "jajka", "seler"]). Если нет — пустой массив.
   - "price": цена (например: "36 zł" или "24.50 PLN"), если видна в тексте.
   - "is_vegetarian": true если блюдо вегетарианское (без мяса и рыбы), иначе false.
   - "is_traditional_polish": true если это традиционная польская классика (żurek, flaki, barszcz, pierogi, bigos, schabowy, placki, tatar, gołąbki, kwaśnica, oscypek, sernik, szarlotka).
   - "order_phrase": готовая вежливая фраза на польском для заказа этого конкретного блюда официанту (например: "Poproszę żurek staropolski w chlebku").
3. В поле "summary" напиши краткое общее резюме о меню на $targetLangName языке (что преобладает, ценовой диапазон, фирменные блюда).
4. В поле "order_phrases" дай 5-7 полезных фраз для общения с официантом на $targetLangName языке (вопрос о блюде дня, аллергены, раздельный счёт, оплата картой/BLIK).

Отвечай СТРОГО валидным JSON-объектом без каких-либо вводных слов, тегов и markdown-ограждений:
{
  "restaurant_name": "Название или null",
  "cuisine_type": "Тип кухни",
  "summary": "Краткая выжимка меню",
  "dishes": [
    {
      "name_pl": "Żurek staropolski w chlebku",
      "translation": "Старопольский жур в хлебе",
      "category": "Zupy",
      "description": "Традиционный суп на ржаной закваске с белой колбасой, копченостями и вареным яйцом, подается в буханке хрустящего хлеба.",
      "ingredients": ["zakwas żytni", "biała kiełbasa", "jajko", "chrzan", "majeranek"],
      "allergens": ["gluten", "jajka"],
      "price": "32 zł",
      "is_vegetarian": false,
      "is_traditional_polish": true,
      "order_phrase": "Poproszę żurek staropolski w chlebku"
    }
  ],
  "order_phrases": [
    {
      "phrase_pl": "Poproszę menu / kartę dań.",
      "translation": "Пожалуйста, меню.",
      "category": "Zamówienie"
    }
  ]
}
''';

        final response = await aiClient.chat(
          [
            ChatMessage('system', systemPrompt),
            ChatMessage('user', 'Текст меню:\n$sample'),
          ],
          temperature: 0.2,
          timeout: const Duration(seconds: 40),
        );

        final jsonMap = extractJson(response);
        if (jsonMap != null && jsonMap['dishes'] is List) {
          final analysis = MenuAnalysis.fromJson(jsonMap, trimmed, lang);
          if (analysis.dishes.isNotEmpty) {
            await db.cachePut(cacheKey, jsonEncode(analysis.toJson()));
            return analysis;
          }
        }
      } catch (e) {
        // Fallback на автономный распознаватель польских блюд
      }
    }

    // Автономный эвристический разбор по встроенной энциклопедии блюд
    final offlineAnalysis = buildOfflineAnalysis(trimmed, lang);
    return offlineAnalysis;
  }

  /// Резервный офлайн-анализ традиционных польских блюд без сети/ключа.
  static MenuAnalysis buildOfflineAnalysis(String text, UiLang lang) {
    final lower = text.toLowerCase();
    final detected = <MenuItemDish>[];

    void check(
      List<String> keywords,
      String namePl,
      String trUk,
      String trRu,
      String trPl,
      String cat,
      String descUk,
      String descRu,
      String descPl,
      List<String> ing,
      List<String> all,
      bool veg,
      bool trad,
      String order,
    ) {
      if (keywords.any((k) => lower.contains(k))) {
        // Попытка найти цену рядом
        String? foundPrice;
        for (final k in keywords) {
          final idx = lower.indexOf(k);
          if (idx != -1) {
            final sub = lower.substring(
              idx,
              (idx + 60).clamp(0, lower.length),
            );
            final m = RegExp(r'(\d+[,.]?\d*)\s*(zł|pln)').firstMatch(sub);
            if (m != null) {
              foundPrice = '${m.group(1)} zł';
              break;
            }
          }
        }

        detected.add(MenuItemDish(
          namePl: namePl,
          translation: lang == UiLang.uk
              ? trUk
              : (lang == UiLang.pl ? trPl : trRu),
          category: cat,
          description: lang == UiLang.uk
              ? descUk
              : (lang == UiLang.pl ? descPl : descRu),
          ingredients: ing,
          allergens: all,
          price: foundPrice,
          isVegetarian: veg,
          isTraditionalPolish: trad,
          orderPhrase: order,
        ));
      }
    }

    // Классические польские блюда
    check(
      ['żurek', 'zurek', 'zur staropolski'],
      'Żurek staropolski',
      'Журек старопольський',
      'Журек старопольский',
      'Żurek staropolski',
      'Zupy',
      'Суп на житній заквасці з білою ковбасою, яйцем та майораном.',
      'Суп на ржаной закваске с белой колбасой, вареным яйцом и майораном.',
      'Tradycyjna zupa na zakwasie żytnim z białą kiełbasą i jajkiem.',
      ['zakwas żytni', 'biała kiełbasa', 'jajko', 'majeranek'],
      ['gluten', 'jajka'],
      false,
      true,
      'Poproszę tradycyjny żurek staropolski.',
    );

    check(
      ['pierogi', 'ruskie', 'pierogarnia'],
      'Pierogi ruskie / z mięsem',
      'Вареники (русські або з м\'ясом)',
      'Вареники (русские или с мясом)',
      'Pierogi ruskie lub z mięsem',
      'Dania główne',
      'Польські вареники з сиром і картоплею (ruskie) або соковитим м\'ясним фаршем.',
      'Польские вареники с творогом и картофелем (ruskie) или сочным мясным фаршем.',
      'Klasyczne pierogi z serem i ziemniakami lub z mięsem podane z okrasą.',
      ['mąka', 'ziemniaki', 'twaróg', 'cebula'],
      ['gluten', 'nabiał'],
      true,
      true,
      'Poproszę porcję pierogów ruskich z okrasą z cebulki.',
    );

    check(
      ['schabowy', 'kotlet schabowy'],
      'Kotlet schabowy z kapustą',
      'Свиняча відбивна з тушкованою капустою',
      'Свиная отбивная с тушеной капустой',
      'Kotlet schabowy z kapustą zasmażaną',
      'Dania główne',
      'Золотава свиняча відбивна у хрусткій паніровці з теплою тушкованою капустою.',
      'Золотистая свиная отбивная в панировке с теплой тушеной капустой.',
      'Chrupiący panierowany kotlet schabowy podany z kapustą zasmażaną.',
      ['schab wieprzowy', 'bułka tarta', 'kapusta', 'ziemniaki'],
      ['gluten', 'jajka'],
      false,
      true,
      'Poproszę kotleta schabowego z ziemniakami i kapustą.',
    );

    check(
      ['barszcz', 'barszczyk'],
      'Barszcz czerwony z uszkami',
      'Червоний борщ з вушками',
      'Красный борщ с ушками',
      'Barszcz czerwony z uszkami',
      'Zupy',
      'Прозорий рубіновий буряковий бульйон з мініатюрними вареничками (вушками).',
      'Прозрачный рубиновый свекольный бульон с миниатюрными вареничками (ушками).',
      'Klarowny barszcz z buraków podawany z drobnymi uszkami.',
      ['buraki', 'grzyby leśne', 'ciasto na uszka'],
      ['gluten'],
      true,
      true,
      'Poproszę barszcz czerwony z uszkami.',
    );

    check(
      ['bigos', 'staropolski'],
      'Bigos staropolski',
      'Бігос старопольський',
      'Бигос старопольский',
      'Bigos staropolski',
      'Dania główne',
      'Тушкована квашена і свіжа капуста з кількома видами м\'яса, чорносливом та грибами.',
      'Тушеная квашеная и свежая капуста с несколькими сортами мяса, черносливом и грибами.',
      'Długo duszona kapusta kiszona z mięsem, wędlinami i suszonymi grzybami.',
      ['kapusta kiszona', 'wieprzowina', 'grzyby suszone', 'śliwki'],
      [],
      false,
      true,
      'Poproszę porcję bigosu staropolskiego z pieczywem.',
    );

    check(
      ['placki', 'ziemniaczane'],
      'Placki ziemniaczane',
      'Деруни (пляцки картопляні)',
      'Драники (пляцки картофельные)',
      'Placki ziemniaczane',
      'Dania główne',
      'Хрусткі картопляні оладки, подаються зі сметаною або м\'ясним гуляшем.',
      'Хрустящие картофельные оладьи, подаются со сметаной или мясным гуляшом.',
      'Chrupiące placki z tartych ziemniaków podawane ze śmietaną lub gulaszem.',
      ['ziemniaki', 'cebula', 'śmietana'],
      ['nabiał'],
      true,
      true,
      'Poproszę placki ziemniaczane ze śmietaną.',
    );

    check(
      ['flaki', 'flaczki'],
      'Flaki po warszawsku',
      'Фляки по-варшавськи',
      'Фляки по-варшавски',
      'Flaki po warszawsku',
      'Zupy',
      'Пікантний густий яловичий суп з рубців з майораном та овочами.',
      'Пикантный густой говяжий суп из рубцов с майораном и овощами.',
      'Aromatyczna tradycyjna zupa z wołowych żołądków z imbirem i majerankiem.',
      ['żołądki wołowe', 'marchew', 'seler', 'majeranek'],
      ['seler'],
      false,
      true,
      'Poproszę porcję flaków po warszawsku.',
    );

    check(
      ['tatar', 'wołow'],
      'Tatar wołowy',
      'Тартар з яловичини',
      'Тартар из говядины',
      'Tatar wołowy',
      'Przystawki',
      'Дрібно рубана свіжа яловичина з яєчним жовтком, цибулею та маринованими грибами.',
      'Мелко рубленная свежая говядина с яичным желтком, луком и маринованными огурчиками/грибами.',
      'Świeża siekana wołowina z żółtkiem, cebulką i piklami.',
      ['wołowina', 'żółtko', 'ogórek kiszony', 'cebula'],
      ['jajka'],
      false,
      true,
      'Poproszę tatara wołowego.',
    );

    check(
      ['sernik', 'szarlotka'],
      'Sernik po krakowsku / Szarlotka',
      'Сирник по-краківськи / Шарлотка',
      'Сырник по-краковски / Шарлотка',
      'Sernik tradycyjny / Szarlotka z jabłkami',
      'Desery',
      'Ніжний запечений сирний пиріг або тепла яблучна шарлотка з корицею.',
      'Нежный запеченный творожный пирог или теплая яблочная шарлотка с корицей.',
      'Domowy sernik z twarogu lub ciepła szarlotka z polskich jabłek.',
      ['twaróg', 'jabłka', 'cynamon', 'kruche ciasto'],
      ['gluten', 'nabiał', 'jajka'],
      true,
      true,
      'Poproszę sernik i kawę.',
    );

    // Если ничего специфического не выделилось, формируем общую запись
    if (detected.isEmpty) {
      detected.add(MenuItemDish(
        namePl: 'Zestaw obiadowy / Danie dnia',
        translation: lang == UiLang.uk
            ? 'Обідній комплекс / Страва дня'
            : (lang == UiLang.pl
                ? 'Zestaw obiadowy / Danie dnia'
                : 'Обеденный комплекс / Блюдо дня'),
        category: 'Dania główne',
        description: lang == UiLang.uk
            ? 'Позиція з меню закладу. Рекомендуємо запитати у офіціанта подробиці щодо свіжих інгредієнтів.'
            : (lang == UiLang.pl
                ? 'Pozycja z menu lokalu. Zapytaj obsługę o szczegóły składników.'
                : 'Позиция из меню заведения. Рекомендуем уточнить у официанта подробности о свежих ингредиентах.'),
        orderPhrase: 'Co Pan / Pani poleca jako danie dnia?',
      ));
    }

    final phrases = lang == UiLang.uk
        ? kDefaultRestaurantPhrasesUk
        : (lang == UiLang.pl
            ? kDefaultRestaurantPhrasesPl
            : kDefaultRestaurantPhrasesRu);

    return MenuAnalysis(
      restaurantName: null,
      cuisineType: lang == UiLang.pl
          ? 'Kuchnia polska'
          : (lang == UiLang.uk ? 'Польська кухня' : 'Польская кухня'),
      summary: lang == UiLang.uk
          ? 'Розпізнано польські страви та позиції меню.'
          : (lang == UiLang.pl
              ? 'Rozpoznano dania z karty dań.'
              : 'Распознаны польские блюда и позиции меню.'),
      dishes: detected,
      orderPhrases: phrases,
      rawText: text,
    );
  }
}
