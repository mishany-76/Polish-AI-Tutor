import '../scanner/translation_service.dart' show UiLang;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/di/providers.dart';
import '../../core/settings/app_settings.dart';
import 'primer_data.dart';
import 'primer_models.dart';

/// Главный экран «Polski Elementarz (Польский Букварь A0)»
class PrimerScreen extends ConsumerStatefulWidget {
  const PrimerScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const PrimerScreen()),
    );
  }

  @override
  ConsumerState<PrimerScreen> createState() => _PrimerScreenState();
}

class _PrimerScreenState extends ConsumerState<PrimerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final FlutterTts _tts = FlutterTts();
  double _ttsRate = 0.45; // комфортный темп для новичка

  // Для вкладки чисел
  int _calculatorValue = 42;

  // Для вкладки слов
  String _selectedCategory = 'polite';
  String _searchQuery = '';

  // Для вкладки игр
  int _quizScore = 0;
  int _currentQuizIdx = 0;
  bool _hasAnswered = false;
  bool _wasAnswerCorrect = false;
  String? _selectedOption;
  // 
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('pl-PL');
      await _tts.setSpeechRate(_ttsRate);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.setLanguage('pl-PL');
      await _tts.setSpeechRate(_ttsRate);
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(settingsProvider.select((s) => s.lang));
    final theme = Theme.of(context);
    final isUk = lang == UiLang.uk;
    final isPl = lang == UiLang.pl;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPl
                  ? '🔤 Polski Elementarz'
                  : (isUk ? '🔤 Польський Буквар' : '🔤 Польский Букварь'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              isPl
                  ? 'Krok zerowy: od dźwięku do słowa'
                  : (isUk ? 'Крок нульовий: від звуку до слова' : 'Шаг нулевой: от звука к слову'),
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _ttsRate < 0.5 ? 'Темп: Медленно' : 'Темп: Обычный',
            icon: Icon(
              _ttsRate < 0.5 ? Icons.slow_motion_video : Icons.speed,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _ttsRate = _ttsRate < 0.5 ? 0.55 : 0.35;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_ttsRate < 0.5
                      ? (isUk ? 'Уповільнена вимова 0.35x' : 'Замедленное произношение 0.35x')
                      : (isUk ? 'Звичайна вимова 0.55x' : 'Обычное произношение 0.55x')),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(
                height: 56,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.spellcheck, size: 20),
                    const SizedBox(height: 3),
                    Text(
                      isPl ? 'Alfabet' : (isUk ? 'Абетка' : 'Азбука'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Tab(
                height: 56,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pin, size: 20),
                    const SizedBox(height: 2),
                    Text(
                      isPl ? 'Liczby\n0-1000' : 'Числа\n0-1000',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 10.5, height: 1.05, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Tab(
                height: 56,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.grid_view, size: 20),
                    const SizedBox(height: 2),
                    Text(
                      isPl ? '250\nsłów' : (isUk ? '250\nслів' : '250\nслов'),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 10.5, height: 1.05, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Tab(
                height: 56,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sports_esports, size: 20),
                    const SizedBox(height: 3),
                    Text(
                      isPl ? 'Trening' : (isUk ? 'Тренінг' : 'Тренинг'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildAlphabetTab(theme, lang),
          _buildNumbersTab(theme, lang),
          _buildWordsTab(theme, lang),
          _buildQuizTab(theme, lang),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. ВКЛАДКА: АЛФАВИТ И ЗВУКИ
  // ===========================================================================
  Widget _buildAlphabetTab(ThemeData theme, UiLang lang) {
    final isUk = lang == UiLang.uk;
    final isPl = lang == UiLang.pl;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Правило ударения
        Card(
          elevation: 0,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPl
                            ? 'Złota zasada akcentu w języku polskim:'
                            : (isUk
                                ? 'Золоте правило наголосу в польській мові:'
                                : 'Золотое правило ударения в польском языке:'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPl
                            ? 'Akcent ZAWSZE pada na przedostatnią sylabę! (np. ka-PU-sta, war-SZA-wa).'
                            : (isUk
                                ? 'Наголос ЗАВЖДИ падає на передостанній склад! (напр., ка-ПУ-ста, вар-ША-ва).'
                                : 'Ударение ВСЕГДА падает на предпоследний слог! (напр., ка-ПУ-ста, вар-ША-ва).'),
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          isPl ? 'Dotknij litery, aby usłyszeć dźwięk i poznać regułę:' : (isUk ? 'Натисніть на літеру, щоб почути звук і пояснення:' : 'Нажмите на букву, чтобы услышать звук и подсказку:'),
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Сетка букв
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.95,
          ),
          itemCount: kAllLettersAndSounds.length,
          itemBuilder: (context, idx) {
            final item = kAllLettersAndSounds[idx];
            final isSpecial = item.isDiacritic || item.isDigraph;

            return InkWell(
              onTap: () {
                _speak('${item.letter}. ${item.exampleWord}');
                _showLetterDetail(context, item, lang, theme);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: isSpecial
                      ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.4)
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSpecial
                        ? theme.colorScheme.secondary.withValues(alpha: 0.5)
                        : theme.colorScheme.outlineVariant,
                    width: isSpecial ? 1.5 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.letter,
                      style: TextStyle(
                        fontSize: item.isDigraph ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: isSpecial
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.soundTranscript,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.exampleWord,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showLetterDetail(BuildContext context, LetterItem item, UiLang lang, ThemeData theme) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.letter,
                      style: TextStyle(
                        fontSize: item.isDigraph ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Звук: ${item.soundTranscript}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          item.isDigraph
                              ? 'Польський диграф (двубуквенное сочетание)'
                              : (item.isDiacritic ? 'Польська буква з діакритикою' : 'Базова буква алфавіту'),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => _speak(item.letter),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                item.desc(lang),
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: ListTile(
                  leading: const Icon(Icons.record_voice_over),
                  title: Text(item.exampleWord, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(item.exampleTr(lang)),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_fill, size: 28),
                    color: theme.colorScheme.primary,
                    onPressed: () => _speak(item.exampleWord),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 2. ВКЛАДКА: СЧЁТ 0 - 1000
  // ===========================================================================
  Widget _buildNumbersTab(ThemeData theme, UiLang lang) {
    final isUk = lang == UiLang.uk;
    final isPl = lang == UiLang.pl;
    final calculatedWords = NumberBuilderHelper.toPolishWords(_calculatorValue);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Интерактивный генератор чисел
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isPl ? '🔢 Generator liczb (0-1000):' : (isUk ? '🔢 Генератор чисел (0-1000):' : '🔢 Генератор чисел (0-1000):'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '$_calculatorValue',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _calculatorValue.toDouble(),
                  min: 0,
                  max: 1000,
                  divisions: 1000,
                  onChanged: (v) {
                    setState(() => _calculatorValue = v.toInt());
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          calculatedWords,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _speak(calculatedWords),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        Text(
          isPl ? '📚 Zasady budowy liczb:' : (isUk ? '📚 Правила побудови польських чисел:' : '📚 Правила построения польских чисел:'),
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Список основных опорных чисел
        ...kAllNumbers.map((numItem) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${numItem.number}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              title: Row(
                children: [
                  Text(numItem.word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(width: 8),
                  Text(numItem.transcript, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                ],
              ),
              subtitle: Text(numItem.rule(lang), style: theme.textTheme.bodySmall),
              trailing: IconButton(
                icon: const Icon(Icons.volume_up_outlined),
                onPressed: () => _speak(numItem.word),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // 3. ВКЛАДКА: 250 КИРПИЧИКОВ
  // ===========================================================================
  Widget _buildWordsTab(ThemeData theme, UiLang lang) {
    final isUk = lang == UiLang.uk;
    final isPl = lang == UiLang.pl;

    final filtered = kAllPrimerBricks.where((item) {
      if (item.categoryId != _selectedCategory) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return item.polishWord.toLowerCase().contains(q) ||
            item.translationUk.toLowerCase().contains(q) ||
            item.translationRu.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Поиск
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: isPl ? 'Szukaj słowa...' : (isUk ? 'Пошук слова...' : 'Поиск слова...'),
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),

        // Категории
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kAllPrimerCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final cat = kAllPrimerCategories[idx];
              final isSel = cat.id == _selectedCategory;

              return ChoiceChip(
                selected: isSel,
                avatar: Text(cat.icon),
                label: Text(cat.title(lang), style: const TextStyle(fontSize: 12)),
                onSelected: (_) => setState(() => _selectedCategory = cat.id),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Кнопка пакетного импорта темы в словарь
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filtered.length} ${isPl ? 'słów' : (isUk ? 'слів' : 'слов')}',
                style: theme.textTheme.bodySmall,
              ),
              TextButton.icon(
                icon: const Icon(Icons.playlist_add, size: 18),
                label: Text(
                  isPl ? 'Dodaj do słownika' : (isUk ? 'Додати тему в словник' : 'Добавить тему в словарь'),
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: () => _importCategoryToDb(context, filtered, isUk),
              ),
            ],
          ),
        ),

        // Список слов
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final item = filtered[idx];

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.polishWord,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item.transcript,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up, size: 24),
                            color: theme.colorScheme.primary,
                            onPressed: () => _speak(item.polishWord),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.translation(lang),
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Divider(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${item.examplePl} — ${item.exampleTr(lang)}',
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.play_circle_outline, size: 18),
                            onPressed: () => _speak(item.examplePl),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _importCategoryToDb(BuildContext context, List<PrimerBrickItem> items, bool isUk) async {
    final db = ref.read(databaseProvider);
    int added = 0;
    for (final item in items) {
      final ok = await db.addScanWord(
        form: item.polishWord.split('(').first.trim(),
        translation: isUk ? item.translationUk : item.translationRu,
        uk: isUk,
        examplePl: item.examplePl,
        source: 'primer_a0',
      );
      if (ok) added++;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isUk
              ? 'Додано $added нових слів у ваш словник SM-2!'
              : 'Добавлено $added новых слов в ваш словарь SM-2!'),
        ),
      );
    }
  }

  // ===========================================================================
  // 4. ВКЛАДКА: МИНИ-ИГРЫ ПЕРВОКЛАШКИ (ТРЕНИНГ)
  // ===========================================================================
  Widget _buildQuizTab(ThemeData theme, UiLang lang) {
    final isUk = lang == UiLang.uk;
    final isPl = lang == UiLang.pl;

    final items = kPrimerQuizItems;
    final current = items[_currentQuizIdx % items.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPl ? '🎯 Trening ucha' : (isUk ? '🎯 Фонетичний тир' : '🎯 Фонетический тир'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_currentQuizIdx + 1} / ${items.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      '${isPl ? 'Wynik' : (isUk ? 'Рахунок' : 'Счёт')}: $_quizScore',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPl
                ? 'Posłuchaj wymowy i odgadnij brakującą literę lub dwuznak:'
                : (isUk
                    ? 'Послухайте вимову та відгадайте пропущену літеру або диграф:'
                    : 'Послушайте произношение и отгадайте пропущенную букву или диграф:'),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 18),

          // Карточка вопроса (БЕЗ подсказок, со скрытой буквой и переводом)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  IconButton.filled(
                    iconSize: 42,
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => _speak(current.word),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isPl
                        ? 'Kliknij, aby posłuchać wymowy'
                        : (isUk ? 'Натисніть для прослуховування' : 'Нажмите для прослушивания'),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  // Замаскированное слово крупным шрифтом
                  Text(
                    _hasAnswered ? current.word : current.masked,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: _hasAnswered
                          ? (_wasAnswerCorrect ? Colors.green.shade700 : Colors.red.shade700)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Перевод слова и эмодзи
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${current.emoji} ${current.meaning(lang)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Варианты ответов
          Row(
            children: current.options.map((opt) {
              final isSelected = _selectedOption == opt;
              final isCorrectOpt = opt == current.correct;

              Color? btnBg;
              Color borderCol = theme.colorScheme.primary;

              if (_hasAnswered) {
                if (isCorrectOpt) {
                  btnBg = Colors.green.withValues(alpha: 0.2);
                  borderCol = Colors.green;
                } else if (isSelected && !_wasAnswerCorrect) {
                  btnBg = Colors.red.withValues(alpha: 0.2);
                  borderCol = Colors.red;
                }
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: btnBg,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: borderCol, width: 2),
                      ),
                      onPressed: _hasAnswered
                          ? null
                          : () {
                              final isCorrect = opt == current.correct;
                              setState(() {
                                _hasAnswered = true;
                                _selectedOption = opt;
                                _wasAnswerCorrect = isCorrect;
                                if (isCorrect) _quizScore++;
                              });
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_hasAnswered && isCorrectOpt) ...[
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 6),
                          ] else if (_hasAnswered && isSelected && !_wasAnswerCorrect) ...[
                            const Icon(Icons.cancel, color: Colors.red, size: 20),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            opt,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Блок объяснения и кнопка Далее при ответе
          if (_hasAnswered) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _wasAnswerCorrect
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _wasAnswerCorrect
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.red.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _wasAnswerCorrect ? Icons.check_circle : Icons.info_outline,
                        color: _wasAnswerCorrect ? Colors.green.shade700 : Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _wasAnswerCorrect
                            ? (isUk ? 'Чудово! Правильно!' : (isPl ? 'Świetnie! Prawidłowo!' : 'Отлично! Верно!'))
                            : (isUk ? 'Помилка! Правильна літера: ${current.correct}' : (isPl ? 'Błąd! Prawidłowa litera: ${current.correct}' : 'Ошибка! Правильная буква: ${current.correct}')),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _wasAnswerCorrect ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    current.note(lang),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        isPl
                            ? 'Następne słowo →'
                            : (isUk ? 'Наступне слово →' : 'Следующее слово →'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      onPressed: () {
                        setState(() {
                          _hasAnswered = false;
                          _selectedOption = null;
                          _currentQuizIdx = (_currentQuizIdx + 1) % items.length;
                        });
                        _speak(items[_currentQuizIdx % items.length].word);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(isPl ? 'Zresetuj wynik' : (isUk ? 'Скинути рахунок' : 'Сбросить счёт')),
            onPressed: () {
              setState(() {
                _quizScore = 0;
                _currentQuizIdx = 0;
                _hasAnswered = false;
                _selectedOption = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
