import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/settings/app_settings.dart';
import '../../core/streak/streak_service.dart';
import '../../core/theme/app_theme.dart';
import '../review/quiz_builders.dart';
import '../review/quiz_screen.dart';
import '../review/review_screen.dart';
import '../scanner/translation_service.dart';
import '../tutor/roleplay_screen.dart';
import '../tutor/scenarios.dart';

/// Главный экран: тренажёр обучения (повторение, игры, ролевые диалоги).
class LearnDashboard extends ConsumerWidget {
  const LearnDashboard({super.key});

  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  static String _streakDayLabel(int n, bool isUk) {
    if (isUk) {
      if (n % 10 == 1 && n % 100 != 11) return 'день';
      if ([2, 3, 4].contains(n % 10) && ![12, 13, 14].contains(n % 100)) return 'дні';
      return 'днів';
    } else {
      if (n % 10 == 1 && n % 100 != 11) return 'день';
      if ([2, 3, 4].contains(n % 10) && ![12, 13, 14].contains(n % 100)) return 'дня';
      return 'дней';
    }
  }

  Future<void> _deferDueQueue(BuildContext context, WidgetRef ref) async {
    final isUk = ref.read(settingsProvider).isUk;
    final count = await ref.read(databaseProvider).deferDueWordsToTomorrow();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isUk
              ? '⏰ Чергу повторень на сьогодні очищено (відкладено на завтра: $count)'
              : '⏰ Очередь повторений на сегодня очищена (отложено на завтра: $count)',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final due = ref.watch(dueCountProvider);
    final total = ref.watch(wordsProvider).value?.length ?? 0;
    final settings = ref.watch(settingsProvider);
    final streak = ref.watch(streakProvider).value ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🇵🇱 Polish AI Tutor'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$streak ${_streakDayLabel(streak, settings.isUk)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Инструкция',
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showUserGuide(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Повторение ---
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Слов на повторение сегодня',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('$due',
                      style: theme.textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Всего в колоде: $total',
                      style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: due > 0
                            ? () => _push(context, const ReviewScreen())
                            : () => ref.read(currentTabProvider.notifier).setTab(1),
                        icon: Icon(due > 0 ? Icons.play_arrow : Icons.document_scanner),
                        label: Text(
                          due == 0
                              ? (total == 0
                                  ? 'Сканировать слова'
                                  : 'На сегодня всё 🎉')
                              : 'Начать повторение',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        onPressed: () => _showManualWordDialog(context, ref),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text(
                          '✍️ Ввести вручную',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (due > 0)
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            minimumSize: const Size(46, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          tooltip: 'Отложить очередь на завтра',
                          icon: const Icon(Icons.snooze, size: 20),
                          onPressed: () => _deferDueQueue(context, ref),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Игры ---
          Text('Тренировки', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          _DrillTile(
            icon: Icons.edit_note,
            title: 'Угадай правильное окончание',
            subtitle: 'chleb / chleba / chlebem — падежи в живых фразах',
            onTap: () async {
              final lang = ref.read(settingsProvider).lang;
              final q = await buildAdaptiveEndingsQuiz(lang);
              if (!context.mounted) return;
              _push(
                context,
                QuizScreen(
                  title: 'Окончания',
                  category: 'endings',
                  questions: q,
                  onGenerateNextRound: () =>
                      buildAdaptiveEndingsQuiz(ref.read(settingsProvider).lang),
                ),
              );
            },
          ),
          _DrillTile(
            icon: Icons.headphones,
            title: 'Аудио-тренажёр',
            subtitle: 'Слушаем слово — выбираем перевод',
            onTap: () async {
              final deck = await ref.read(databaseProvider).allWords();
              final lang = ref.read(settingsProvider).lang;
              final q = await buildAdaptiveAudioQuiz(deck, lang);
              if (!context.mounted) return;
              _push(
                context,
                QuizScreen(
                  title: 'Аудио',
                  category: 'audio',
                  questions: q,
                  onGenerateNextRound: () {
                    final d = ref.read(wordsProvider).value ?? deck;
                    return buildAdaptiveAudioQuiz(d, ref.read(settingsProvider).lang);
                  },
                ),
              );
            },
          ),
          _DrillTile(
            icon: Icons.warning_amber,
            title: 'Осторожно, ложные друзья!',
            subtitle: 'zapomnieć, owoce, sklep… слова-обманки',
            onTap: () async {
              final lang = ref.read(settingsProvider).lang;
              final q = await buildAdaptiveFalseFriendsQuiz(lang);
              if (!context.mounted) return;
              _push(
                context,
                QuizScreen(
                  title: 'Ложные друзья',
                  category: 'false_friends',
                  questions: q,
                  onGenerateNextRound: () =>
                      buildAdaptiveFalseFriendsQuiz(ref.read(settingsProvider).lang),
                ),
              );
            },
          ),
          _DrillTile(
            icon: Icons.payments_outlined,
            title: 'Числа, ціни та рахунок',
            subtitle: 'Слухаємо польські суми, копійки, години та рахунки на касі',
            onTap: () async {
              final lang = ref.read(settingsProvider).lang;
              final q = await buildAdaptiveNumbersPricesQuiz(lang);
              if (!context.mounted) return;
              _push(
                context,
                QuizScreen(
                  title: 'Числа та ціни',
                  category: 'numbers_prices',
                  questions: q,
                  onGenerateNextRound: () =>
                      buildAdaptiveNumbersPricesQuiz(ref.read(settingsProvider).lang),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // --- Диалоги ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Ролевые диалоги',
                  style: theme.textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (settings.hasKey)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Готов',
                        style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            settings.hasKey
                ? 'ИИ играет поляка — отвечайте голосом или текстом'
                : '⚠️ Укажите API-ключ шлюза в «Настройки», чтобы начать диалоги',
            style: TextStyle(
              fontSize: 13,
              color: settings.hasKey ? theme.textTheme.bodySmall?.color : theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
            children: [
              for (final s in scenarios)
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () =>
                        _push(context, RoleplayScreen(scenario: s)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.emoji, style: const TextStyle(fontSize: 28)),
                          const Spacer(),
                          Text(
                            s.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(s.level, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showManualWordDialog(BuildContext context, WidgetRef ref) {
    final wordController = TextEditingController();
    final transController = TextEditingController();
    final noteController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('✍️ Новое слово'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: wordController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Польское слово *',
                    hintText: 'например, dworzec',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: transController,
                  decoration: const InputDecoration(
                    labelText: 'Перевод *',
                    hintText: 'например, вокзал',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Контекст / заметка (опционально)',
                    hintText: 'например, Idę na dworzec kolejowy',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () async {
                final pl = wordController.text.trim();
                final tr = transController.text.trim();
                if (pl.isEmpty || tr.isEmpty) return;

                final uk = ref.read(settingsProvider).isUk;
                final added = await ref.read(databaseProvider).addManualWord(
                  lemma: pl,
                  translation: tr,
                  uk: uk,
                  example: noteController.text.trim(),
                  note: noteController.text.trim(),
                );

                if (dialogCtx.mounted) {
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(added
                        ? '✅ Слово "$pl" добавлено в колоду'
                        : '⚠️ Слово "$pl" уже есть в словаре'),
                  ));
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _showUserGuide(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) {
        return Consumer(
          builder: (context, ref, _) {
            final lang = ref.watch(settingsProvider.select((s) => s.lang));
            final isUk = lang == UiLang.uk;
            final theme = Theme.of(context);

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, scrollCtrl) {
                return ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                isUk ? '📖 Керівництво користувача' : '📖 Руководство пользователя',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(sheetCtx).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<UiLang>(
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            segments: const [
                              ButtonSegment(
                                value: UiLang.uk,
                                label: Text('🇺🇦 Українська', style: TextStyle(fontSize: 13)),
                              ),
                              ButtonSegment(
                                value: UiLang.ru,
                                label: Text('🇷🇺 Русский', style: TextStyle(fontSize: 13)),
                              ),
                            ],
                            selected: {lang},
                            onSelectionChanged: (s) =>
                                ref.read(settingsProvider.notifier).setLang(s.first),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Карточка 1: Навчання & SRS
                    _GuideCard(
                      icon: Icons.psychology,
                      color: Colors.blue,
                      title: isUk ? '1. 🧠 Навчання та алгоритм SRS' : '1. 🧠 Обучение и алгоритм SRS',
                      body: isUk
                          ? '• Картка дня працює за алгоритмом SM-2: слова пропонуються для повторення через 1, 6, 14 днів, запобігаючи забуванню.\n'
                            '• Кнопка «✍️ Ввести слово вручну» дозволяє зберегти будь-яке почуте слово з контекстом.\n'
                            '• Тренажери «Закінчення», «Аудіо» та «Хибні друзі» тренують відмінки, слух та слова-обманки.'
                          : '• Блок дня работает по алгоритму SM-2: слова повторяются с интервалами 1, 6, 14 дней для надежного закрепления.\n'
                            '• Кнопка «✍️ Ввести слово вручную» позволяет сохранить любое незнакомое слово с контекстом.\n'
                            '• Тренажеры «Окончания», «Аудио» и «Ложные друзья» тренируют падежи, слух и слова-ловушки.',
                    ),
                    const SizedBox(height: 12),

                    // Карточка 2: Рольові діалоги
                    _GuideCard(
                      icon: Icons.forum,
                      color: const Color(0xFF8C1D2F),
                      title: isUk ? '2. 💬 Рольові діалоги з ШІ' : '2. 💬 Ролевые диалоги с ИИ',
                      body: isUk
                          ? '• Тьютор Kasia грає жителя Польщі в 6 життєвих сценаріях (магазин, ужонд, кафе, лікар, вокзал, оренда житла).\n'
                            '• Значок 🌐 біля кожної репліки відкриває синхронний переклад українською.\n'
                            '• Підказка (Podpowiedź) містить польську фразу та курсивний переклад. Натисніть її, щоб вставити в поле введення.\n'
                            '• Підтримується відповідь голосом через мікрофон.'
                          : '• Тьютор Kasia играет жителя Польши в 6 реальных ситуациях (магазин, ужонд, кафе, поликлиника, вокзал, аренда жилья).\n'
                            '• Кнопка 🌐 возле каждой фразы открывает перевод на русский язык.\n'
                            '• Плашка «Подсказка» содержит польский ответ и курсивный перевод. Клик вставляет её в строку ввода.\n'
                            '• Поддерживается ответ голосом через микрофон.',
                    ),
                    const SizedBox(height: 12),

                    // Карточка 3: Перекладач
                    _GuideCard(
                      icon: Icons.document_scanner,
                      color: Colors.teal,
                      title: isUk ? '3. 📷 Багатофункціональний Перекладач' : '3. 📷 Многофункциональный Переводчик',
                      body: isUk
                          ? '• Режим 📷 Камера: миттєвий захват польського тексту з вивісок, чеків, документів через ML Kit.\n'
                            '• Режим 📁 Файл/PDF: імпорт фото та багатосторінкових PDF-документів із гортанням сторінок.\n'
                            '• Режим ✍️ Текст: швидкий переклад будь-яких фраз.\n'
                            '• Кнопка 📥 «Додати всі слова в словник» зберігає всі незнайомі слова з документа в колоду.'
                          : '• Режим 📷 Камера: мгновенный захват польского текста с вывесок, чеков и писем через ML Kit.\n'
                            '• Режим 📁 Файл/PDF: импорт фото и многостраничных PDF-документов с перелистыванием страниц.\n'
                            '• Режим ✍️ Текст: быстрый перевод любых введенных фраз.\n'
                            '• Кнопка 📥 «Добавить все слова в словарь» сохраняет все слова документа в колоду повторения.',
                    ),
                    const SizedBox(height: 12),

                    // Карточка 4: Словник
                    _GuideCard(
                      icon: Icons.menu_book,
                      color: Colors.orange,
                      title: isUk ? '4. 📚 Словник та Налаштування' : '4. 📚 Словарь и Настройки',
                      body: isUk
                          ? '• Переглядайте картки слів, статус вивчення, транскрипцію та приклади.\n'
                            '• Озвучування слів в один дотик рідним синтезатором Google TTS.\n'
                            '• У Налаштуваннях підключається власний шлюз OmniRoute (швидка модель anti/gemini-3.8-flash-high).'
                          : '• Просматривайте карточки слов, интервалы повторения, транскрипцию и примеры.\n'
                            '• Озвучивание слов в одно касание синтезатором Google TTS.\n'
                            '• В Настройках настраивается ИИ-шлюз OmniRoute (быстрая модель anti/gemini-3.8-flash-high).',
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      child: Text(isUk ? 'Зрозуміло, до навчання! 🚀' : 'Понятно, к обучению! 🚀'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(fontSize: 13, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrillTile extends StatelessWidget {
  const _DrillTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 26, color: theme.colorScheme.primary),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

