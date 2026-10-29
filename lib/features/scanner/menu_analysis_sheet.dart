import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import 'menu_analysis_service.dart';

/// Визуальная модальная панель разбора ресторанного меню и блюд польской кухни.
class MenuAnalysisSheet extends ConsumerStatefulWidget {
  const MenuAnalysisSheet({
    super.key,
    required this.analysis,
  });

  final MenuAnalysis analysis;

  static Future<void> show(BuildContext context, MenuAnalysis analysis) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MenuAnalysisSheet(analysis: analysis),
    );
  }

  @override
  ConsumerState<MenuAnalysisSheet> createState() => _MenuAnalysisSheetState();
}

class _MenuAnalysisSheetState extends ConsumerState<MenuAnalysisSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  final Set<String> _addedDishNames = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await ref.read(ttsProvider).speak(text);
    } catch (_) {}
  }

  Future<void> _addDishToDeck(MenuItemDish dish) async {
    if (_addedDishNames.contains(dish.namePl)) return;

    final db = ref.read(databaseProvider);
    final isUk = ref.read(settingsProvider).isUk;

    final added = await db.addScanWord(
      form: dish.namePl,
      translation: dish.translation,
      uk: isUk,
      examplePl: dish.orderPhrase,
    );

    if (added) {
      AchievementService.instance.increment('words_added');
    }

    if (mounted) {
      setState(() => _addedDishNames.add(dish.namePl));
      final strings = ref.read(appStringsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.isPl
                ? '✅ Dodano „${dish.namePl}” do słownika'
                : (strings.isUk
                    ? '✅ Додано «${dish.namePl}» до словника'
                    : '✅ Добавлено «${dish.namePl}» в словарь'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _copyPhrase(String phrase) {
    Clipboard.setData(ClipboardData(text: phrase));
    final strings = ref.read(appStringsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          strings.isPl
              ? '📋 Skopiowano: „$phrase”'
              : (strings.isUk
                  ? '📋 Скопійовано: «$phrase»'
                  : '📋 Скопировано: «$phrase»'),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<MenuItemDish> get _filteredDishes {
    final all = widget.analysis.dishes;
    if (_selectedFilter == 'all') return all;
    if (_selectedFilter == 'veg') return all.where((d) => d.isVegetarian).toList();
    return all
        .where((d) =>
            d.category.toLowerCase().contains(_selectedFilter.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final a = widget.analysis;

    final maxH = MediaQuery.of(context).size.height * 0.92;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Полоска-ручка drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Заголовок и тип кухни
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPastel,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: AppTheme.primaryCarmine,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.restaurantName ??
                              (strings.isPl
                                  ? 'Karta dań / Menu'
                                  : (strings.isUk
                                      ? 'Карта страв / Меню'
                                      : 'Карта блюд / Меню')),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Text('🇵🇱 ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(
                                a.cuisineType,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Вкладки: «Блюда» и «Разговорник с официантом»
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.fastfood_outlined, size: 18),
                    text: strings.isPl
                        ? 'Dania (${a.dishes.length})'
                        : (strings.isUk
                            ? 'Страви (${a.dishes.length})'
                            : 'Блюда (${a.dishes.length})'),
                  ),
                  Tab(
                    icon: const Icon(Icons.record_voice_over_outlined, size: 18),
                    text: strings.isPl
                        ? 'Zwroty w lokalu (${a.orderPhrases.length})'
                        : (strings.isUk
                            ? 'Фрази в закладі (${a.orderPhrases.length})'
                            : 'Фразы в заведении (${a.orderPhrases.length})'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Тело вкладок
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDishesTab(theme, strings),
                  _buildPhrasesTab(theme, strings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishesTab(ThemeData theme, AppStrings strings) {
    final filtered = _filteredDishes;

    return Column(
      children: [
        // Резюме меню
        if (widget.analysis.summary.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.analysis.summary,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Фильтр категорий
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('all', strings.isPl ? 'Wszystkie' : (strings.isUk ? 'Всі' : 'Все')),
              const SizedBox(width: 6),
              _buildFilterChip('Zupy', strings.isPl ? 'Zupy' : (strings.isUk ? 'Супи' : 'Супы')),
              const SizedBox(width: 6),
              _buildFilterChip('Dania', strings.isPl ? 'Główne' : (strings.isUk ? 'Основні' : 'Основные')),
              const SizedBox(width: 6),
              _buildFilterChip('Przystawki', strings.isPl ? 'Przystawki' : (strings.isUk ? 'Закуски' : 'Закуски')),
              const SizedBox(width: 6),
              _buildFilterChip('Desery', strings.isPl ? 'Desery' : (strings.isUk ? 'Десерти' : 'Десерты')),
              const SizedBox(width: 6),
              _buildFilterChip('veg', '🌱 Veg'),
            ],
          ),
        ),

        // Список блюд
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    strings.isPl
                        ? 'Brak dań w tej kategorii'
                        : (strings.isUk
                            ? 'Немає страв у цій категорії'
                            : 'Нет блюд в этой категории'),
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _buildDishCard(filtered[i], theme, strings),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final theme = Theme.of(context);
    final selected = _selectedFilter == key;

    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilter = key),
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildDishCard(
    MenuItemDish dish,
    ThemeData theme,
    AppStrings strings,
  ) {
    final inDeck = _addedDishNames.contains(dish.namePl);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название и цена
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (dish.isTraditionalPolish)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPastel,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '🇵🇱 PL',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryCarmine,
                                ),
                              ),
                            ),
                          if (dish.isVegetarian)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🌱 Veg',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              dish.namePl,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dish.translation,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (dish.price != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      dish.price!,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Описание блюда
            if (dish.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                dish.description,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],

            // Ингредиенты
            if (dish.ingredients.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: dish.ingredients
                    .map((ing) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ing,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],

            // Аллергены
            if (dish.allergens.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 14, color: Colors.amber.shade800),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${strings.isPl ? 'Alergeny:' : (strings.isUk ? 'Алергени:' : 'Аллергены:')} ${dish.allergens.join(', ')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Кнопки: Заказать (озвучить) + В словарь
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      _speak(dish.orderPhrase);
                      _copyPhrase(dish.orderPhrase);
                    },
                    icon: const Icon(Icons.record_voice_over, size: 16),
                    label: Text(
                      strings.isPl
                          ? 'Zamów danie'
                          : (strings.isUk ? 'Замовити' : 'Заказать'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: inDeck
                      ? (strings.isPl
                          ? 'Już w słowniku'
                          : (strings.isUk ? 'Вже в словнику' : 'Уже в словаре'))
                      : (strings.isPl
                          ? 'Dodaj do słownika'
                          : (strings.isUk ? 'В словник' : 'В словарь')),
                  onPressed: inDeck ? null : () => _addDishToDeck(dish),
                  icon: Icon(
                    inDeck ? Icons.bookmark_added : Icons.bookmark_add_outlined,
                    color: inDeck
                        ? Colors.green
                        : theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhrasesTab(ThemeData theme, AppStrings strings) {
    final phrases = widget.analysis.orderPhrases;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: phrases.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final p = phrases[i];
        return Card(
          elevation: 0,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => _speak(p.phrasePl),
                  icon: const Icon(Icons.volume_up, size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Озвучить',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          p.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.phrasePl,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.translation,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _copyPhrase(p.phrasePl),
                  icon: const Icon(Icons.copy, size: 18),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Скопировать',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
