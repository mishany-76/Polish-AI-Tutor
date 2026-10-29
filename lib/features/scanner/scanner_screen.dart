import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:permission_handler/permission_handler.dart';

import '../../core/achievements/achievement_service.dart';
import '../../core/ai_client/ai_client.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import 'doc_analysis_sheet.dart';
import 'menu_analysis_service.dart';
import 'menu_analysis_sheet.dart';
import 'ocr_service.dart';
import 'scanner_providers.dart';
import 'translation_service.dart';
import 'word_overlay.dart';
import 'word_sheet.dart';

enum TranslatorMode { camera, document, menu, text }

/// Модуль «Переводчик»: Камера, Документ / Галерея (PDF, фото), Ввод текста.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  TranslatorMode _mode = TranslatorMode.camera;

  // Режим: Камера
  CameraController? _camera;
  String? _error;
  bool _busy = false;
  bool _torch = false;

  String? _shotPath;
  OcrResult? _result;
  OcrWord? _selected;

  // Режим: Ввод текста
  final TextEditingController _textInputController = TextEditingController();
  bool _translatingText = false;
  String? _textTranslationResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _error = status.isPermanentlyDenied
          ? 'Доступ к камере запрещён. Включите его в настройках.'
          : 'Нужен доступ к камере для сканирования.');
      return;
    }
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _error = null;
      });
    } on CameraException catch (e) {
      setState(() => _error = 'Ошибка камеры: ${e.description ?? e.code}');
    } on StateError {
      setState(() => _error = 'Камера не найдена на устройстве.');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _camera;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      c.dispose();
      setState(() => _camera = null);
    } else if (state == AppLifecycleState.resumed && _shotPath == null && _mode == TranslatorMode.camera) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera?.dispose();
    _textInputController.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final c = _camera;
    if (c == null || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await c.takePicture();
      await _processImage(file.path);
    } on CameraException catch (e) {
      _toast('Не удалось сделать снимок: ${e.description ?? e.code}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _processImage(String path) async {
    setState(() => _busy = true);
    try {
      final result = await ref.read(ocrServiceProvider).recognize(path);
      if (!mounted) return;
      setState(() {
        _shotPath = path;
        _result = result;
        _selected = null;
      });
      if (result.words.isNotEmpty) {
        AchievementService.instance.increment('scans_done');
      }
      if (result.words.isEmpty) {
        _toast('Текст не найден. Попробуйте поближе или другой файл.');
      }
    } catch (e) {
      _toast('Ошибка распознавания: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDocumentOrImage() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      );
      if (files.isEmpty || files.first.path == null) return;

      final path = files.first.path!;
      final isPdf = path.toLowerCase().endsWith('.pdf');

      if (isPdf) {
        setState(() => _busy = true);
        try {
          final document = await pdfx.PdfDocument.openFile(path);
          final page = await document.getPage(1);
          final pageImage = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: pdfx.PdfPageImageFormat.jpeg,
          );
          await page.close();
          await document.close();

          if (pageImage != null) {
            final tempFile = File('${Directory.systemTemp.path}/pdf_page_1_${DateTime.now().millisecondsSinceEpoch}.jpg');
            await tempFile.writeAsBytes(pageImage.bytes);
            await _processImage(tempFile.path);
          } else {
            _toast('Не удалось преобразовать страницу PDF.');
          }
        } catch (e) {
          _toast('Ошибка чтения PDF: $e');
        } finally {
          if (mounted) setState(() => _busy = false);
        }
      } else {
        await _processImage(path);
      }
    } catch (e) {
      _toast('Ошибка выбора файла: $e');
    }
  }

  Future<void> _toggleTorch() async {
    final c = _camera;
    if (c == null) return;
    _torch = !_torch;
    await c.setFlashMode(_torch ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  void _retake() {
    setState(() {
      _shotPath = null;
      _result = null;
      _selected = null;
    });
  }

  Future<void> _onWordTap(OcrWord word) async {
    setState(() => _selected = word);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => WordSheet(word: word),
    );
    if (mounted) setState(() => _selected = null);
  }

  /// Умное пакетное извлечение и добавление ключевых слов в словарь через OmniRoute.
  Future<void> _batchAddWords(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _toast('Нет текста для добавления.');
      return;
    }

    final aiClient = ref.read(aiClientProvider);
    final db = ref.read(databaseProvider);
    final isUk = ref.read(settingsProvider).isUk;
    final targetLang = isUk ? 'Украинский' : 'Русский';

    if (aiClient.apiKey.trim().isEmpty) {
      _toast('⚠️ Укажите API-ключ в Настройках для умного извлечения слов.');
      return;
    }

    _toast('⏳ ИИ извлекает и переводит ключевые слова…');

    try {
      final sample = trimmed.length > 3000 ? trimmed.substring(0, 3000) : trimmed;

      final prompt =
          'Извлеки из этого польского текста ключевые полезные слова для изучения '
          '(исключи предлоги, союзы, цифры и междометия). Для каждого слова верни начальную форму '
          '(инфинитив для глаголов, именительный падеж ед.ч. для существительных/прилагательных) '
          'и его точный естественный перевод на $targetLang.\n'
          'Верни СТРОГО валидный JSON-массив без markdown-оберток:\n'
          '[{"lemma": "базовая_форма", "translation": "перевод", "pos": "часть_речи"}]\n\n'
          'Текст:\n$sample';

      final responseText = await aiClient.chat(
        [
          const ChatMessage(
            'system',
            'Ты — опытный лингвист-лексикограф польского языка. Отвечай ТОЛЬКО чистым валидным JSON-массивом.',
          ),
          ChatMessage('user', prompt),
        ],
        temperature: 0.2,
        timeout: const Duration(seconds: 35),
      );

      final list = extractJsonList(responseText);
      if (list == null || list.isEmpty) {
        _toast('ИИ не выделил новых слов из данного текста.');
        return;
      }

      final parsed = <({String lemma, String translation, String? pos})>[];
      for (final item in list) {
        if (item is Map) {
          final lemma = (item['lemma'] as String? ?? '').trim();
          final translation = (item['translation'] as String? ?? '').trim();
          final pos = (item['pos'] as String? ?? '').trim();
          if (lemma.isNotEmpty && translation.isNotEmpty) {
            parsed.add((
              lemma: lemma,
              translation: translation,
              pos: pos.isEmpty ? null : pos,
            ));
          }
        }
      }

      if (parsed.isEmpty) {
        _toast('Не удалось извлечь слова.');
        return;
      }

      final added = await db.batchAddAiWords(parsed, uk: isUk);
      if (added > 0) {
        AchievementService.instance.increment('words_added', by: added);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              added > 0
                  ? '✅ Добавлено $added новых словарных форм с переводом через ИИ'
                  : 'Все извлеченные слова (${parsed.length}) уже есть в словаре',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on AiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Ошибка ИИ-шлюза: ${e.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Не удалось извлечь слова: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Быстрый связный перевод всего текста.
  Future<void> _translateParagraph(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _toast('Нет текста для перевода.');
      return;
    }
    final strings = ref.read(appStringsProvider);
    final future = ref.read(translationServiceProvider).translate(trimmed);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      strings.originalText,
                      style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(trimmed),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.translate, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      strings.translationAi,
                      style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FutureBuilder<String>(
                  future: future,
                  builder: (_, snap) {
                    if (snap.hasError) {
                      return Text(
                        'Не удалось перевести. Проверьте интернет или настройки ИИ-шлюза.',
                        style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                      );
                    }
                    if (!snap.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                strings.translatingParagraph,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SelectableText(
                      snap.data!,
                      style: Theme.of(ctx).textTheme.titleMedium,
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _batchAddWords(trimmed);
                    },
                    icon: const Icon(Icons.bookmark_add, size: 20),
                    label: Text(strings.batchAddWordsBtn),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _analyzeDocument(trimmed);
                    },
                    icon: const Icon(
                      Icons.gavel_rounded,
                      size: 18,
                      color: AppTheme.primaryCarmine,
                    ),
                    label: Text(
                      strings.docAnalysisBtn,
                      style: const TextStyle(
                        color: AppTheme.primaryCarmine,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Глубокий юридическо-практический разбор польского документа (Smart Doc Scanner).
  Future<void> _analyzeDocument(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _toast(ref.read(appStringsProvider).isPl
          ? 'Brak tekstu do analizy.'
          : (ref.read(appStringsProvider).isUk
              ? 'Немає тексту для аналізу.'
              : 'Нет текста для анализа.'));
      return;
    }

    final aiClient = ref.read(aiClientProvider);
    if (aiClient.apiKey.trim().isEmpty) {
      _toast(ref.read(appStringsProvider).isPl
          ? '⚠️ Podaj klucz API w Ustawieniach, aby analizować dokumenty.'
          : (ref.read(appStringsProvider).isUk
              ? '⚠️ Вкажіть API-ключ у Налаштуваннях для аналізу документів.'
              : '⚠️ Укажите API-ключ в Настройках для анализа документов.'));
      return;
    }

    final strings = ref.read(appStringsProvider);
    final lang = ref.read(settingsProvider.select((s) => s.lang));

    // Показываем индикатор прогресса анализа
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: AppTheme.bgWarmMilk,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppTheme.primaryCarmine,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    strings.docAnalyzing,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final analysis = await ref.read(docAnalysisServiceProvider).analyze(
            text: trimmed,
            lang: lang,
          );

      // Закрываем диалог загрузки
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      AchievementService.instance.increment('scans_done');

      if (mounted) {
        await DocAnalysisSheet.show(context, analysis);
      }
    } on AiException catch (e) {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${e.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Ошибка анализа: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _analyzeMenu(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _toast(ref.read(appStringsProvider).isPl
          ? 'Brak tekstu menu do analizy.'
          : (ref.read(appStringsProvider).isUk
              ? 'Немає тексту меню для аналізу.'
              : 'Нет текста меню для анализа.'));
      return;
    }

    final lang = ref.read(settingsProvider).lang;
    final strings = ref.read(appStringsProvider);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: AppTheme.bgWarmMilk,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppTheme.primaryCarmine,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    strings.menuAnalyzing,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final analysis = await ref.read(menuAnalysisServiceProvider).analyze(
            text: trimmed,
            lang: lang,
          );

      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      AchievementService.instance.increment('scans_done');

      if (mounted) {
        await MenuAnalysisSheet.show(context, analysis);
      }
    } on AiException catch (e) {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${e.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Ошибка анализа меню: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openRestaurantCheatSheet() {
    final lang = ref.read(settingsProvider).lang;
    final phrases = lang == UiLang.uk
        ? kDefaultRestaurantPhrasesUk
        : (lang == UiLang.pl
            ? kDefaultRestaurantPhrasesPl
            : kDefaultRestaurantPhrasesRu);

    final dummyAnalysis = MenuAnalysis(
      restaurantName: null,
      cuisineType: lang == UiLang.pl
          ? 'Karta dań / Zwroty w lokalu'
          : (lang == UiLang.uk
              ? 'Фрази для спілкування в ресторані'
              : 'Фразы для общения в ресторане'),
      summary: lang == UiLang.pl
          ? 'Przydatne zwroty do składania zamówień, pytań o alergeny i płatności w lokalu.'
          : (lang == UiLang.uk
              ? 'Корисні фрази для замовлення страв, питань про алергени та оплату.'
              : 'Полезные фразы для заказа блюд, вопросов об аллергенах и оплаты.'),
      dishes: const [],
      orderPhrases: phrases,
      rawText: '',
    );

    MenuAnalysisSheet.show(context, dummyAnalysis);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          strings.tabTranslator,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          SegmentedButton<UiLang>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              selectedForegroundColor: theme.colorScheme.onPrimary,
              selectedBackgroundColor: theme.colorScheme.primary,
            ),
            segments: const [
              ButtonSegment(
                value: UiLang.uk,
                label: Text('🇺🇦 UK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              ButtonSegment(
                value: UiLang.ru,
                label: Text('🇷🇺 RU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              ButtonSegment(
                value: UiLang.pl,
                label: Text('🇵🇱 PL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
            selected: {lang},
            onSelectionChanged: (s) =>
                ref.read(settingsProvider.notifier).setLang(s.first),
          ),
          if (_mode == TranslatorMode.camera && _shotPath == null && _camera != null)
            IconButton(
              onPressed: _toggleTorch,
              icon: Icon(_torch ? Icons.flash_on : Icons.flash_off),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Вкладки режимов
          Container(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<TranslatorMode>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  selectedForegroundColor: theme.colorScheme.onPrimary,
                  selectedBackgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                segments: [
                  ButtonSegment(
                    value: TranslatorMode.camera,
                    label: Text(
                      strings.isPl ? '📷 Aparat' : (strings.isUk ? '📷 Камера' : '📷 Камера'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ButtonSegment(
                    value: TranslatorMode.document,
                    label: Text(
                      strings.isPl ? '📁 Plik' : (strings.isUk ? '📁 Файл' : '📁 Файл'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ButtonSegment(
                    value: TranslatorMode.menu,
                    label: Text(
                      strings.menuModeTitle,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ButtonSegment(
                    value: TranslatorMode.text,
                    label: Text(
                      strings.isPl ? '✍️ Tekst' : (strings.isUk ? '✍️ Текст' : '✍️ Текст'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) {
                  final newMode = s.first;
                  setState(() {
                    _mode = newMode;
                    _shotPath = null;
                    _result = null;
                  });
                  if (newMode == TranslatorMode.camera && _camera == null) {
                    _initCamera();
                  }
                },
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    if (_busy) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_mode) {
      case TranslatorMode.camera:
        final hasShot = _shotPath != null && _result != null;
        return Column(
          children: [
            Expanded(child: _buildViewport()),
            _buildCameraControls(hasShot),
          ],
        );

      case TranslatorMode.document:
        if (_shotPath != null && _result != null) {
          return Column(
            children: [
              Expanded(
                child: WordOverlay(
                  imagePath: _shotPath!,
                  image: FileImage(File(_shotPath!)),
                  result: _result!,
                  selected: _selected,
                  onWordTap: _onWordTap,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _analyzeDocument(_result!.fullText),
                        icon: const Icon(Icons.gavel_rounded, size: 18),
                        label: Text(strings.docAnalysisBtn),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryCarmine,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => _analyzeMenu(_result!.fullText),
                        icon: const Icon(Icons.restaurant_menu, size: 18),
                        label: Text(strings.menuAnalysisBtn),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => _translateParagraph(_result!.fullText),
                        icon: const Icon(Icons.translate, size: 18),
                        label: Text(strings.translateAll),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickDocumentOrImage,
                        icon: const Icon(Icons.folder_open, size: 18),
                        label: Text(
                          strings.isPl
                              ? 'Wybierz inny plik'
                              : (strings.isUk
                                  ? 'Обрати інший файл'
                                  : 'Выбрать другой файл'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.picture_as_pdf, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  strings.isPl
                      ? 'Wybierz dokument PDF lub zdjęcie z galerii do rozpoznania OCR'
                      : (strings.isUk
                          ? 'Оберіть PDF-документ або фото з галереї для OCR-розпізнавання'
                          : 'Выберите PDF-документ или фото из галереи для OCR-распознавания'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _pickDocumentOrImage,
                  icon: const Icon(Icons.file_upload),
                  label: Text(
                    strings.isPl
                        ? 'Wybierz plik (PDF / Zdjęcie)'
                        : (strings.isUk
                            ? 'Обрати файл (PDF / Фото)'
                            : 'Выбрать файл (PDF / Фото)'),
                  ),
                ),
              ],
            ),
          ),
        );

      case TranslatorMode.menu:
        if (_shotPath != null && _result != null) {
          return Column(
            children: [
              Expanded(
                child: WordOverlay(
                  imagePath: _shotPath!,
                  image: FileImage(File(_shotPath!)),
                  result: _result!,
                  selected: _selected,
                  onWordTap: _onWordTap,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _analyzeMenu(_result!.fullText),
                        icon: const Icon(Icons.restaurant_menu, size: 18),
                        label: Text(strings.menuAnalysisBtn),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryCarmine,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => _translateParagraph(_result!.fullText),
                        icon: const Icon(Icons.translate, size: 18),
                        label: Text(strings.translateAll),
                      ),
                      OutlinedButton.icon(
                        onPressed: _openRestaurantCheatSheet,
                        icon: const Icon(Icons.record_voice_over, size: 18),
                        label: Text(strings.menuCheatSheetBtn),
                      ),
                      IconButton.outlined(
                        tooltip: strings.isPl ? 'Inne menu' : 'Другое меню',
                        onPressed: _pickDocumentOrImage,
                        icon: const Icon(Icons.folder_open, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant_menu, size: 68, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  strings.menuSelectPrompt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _mode = TranslatorMode.camera;
                          _shotPath = null;
                          _result = null;
                        });
                        if (_camera == null) {
                          _initCamera();
                        }
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: Text(strings.menuTakePhotoBtn),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _pickDocumentOrImage,
                      icon: const Icon(Icons.photo_library),
                      label: Text(strings.menuPickPhotoBtn),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _openRestaurantCheatSheet,
                  icon: const Icon(Icons.record_voice_over, size: 18),
                  label: Text(strings.menuCheatSheetBtn),
                ),
              ],
            ),
          ),
        );

      case TranslatorMode.text:
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _textInputController,
                  maxLines: 5,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: strings.isPl
                        ? 'Wklej lub wpisz tekst po polsku do przetłumaczenia…'
                        : (strings.isUk
                            ? 'Вставте або введіть польський текст для перекладу…'
                            : 'Вставьте или введите польский текст для перевода…'),
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    suffixIcon: _textInputController.text.isNotEmpty
                        ? IconButton(
                            tooltip: strings.isPl
                                ? 'Wyczyść'
                                : (strings.isUk ? 'Очистити' : 'Очистить'),
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _textInputController.clear();
                              setState(() => _textTranslationResult = null);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryCarmine,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _translatingText
                        ? null
                        : () async {
                            final text = _textInputController.text.trim();
                            if (text.isEmpty) return;
                            setState(() {
                              _translatingText = true;
                              _textTranslationResult = null;
                            });
                            try {
                              final tr = await ref
                                  .read(translationServiceProvider)
                                  .translate(text);
                              setState(() => _textTranslationResult = tr);
                            } catch (e) {
                              _toast('Ошибка перевода: $e');
                            } finally {
                              setState(() => _translatingText = false);
                            }
                          },
                    icon: _translatingText
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.translate, size: 20),
                    label: Text(
                      _translatingText
                          ? (strings.isPl
                              ? 'Tłumaczę…'
                              : (strings.isUk ? 'Перекладаю…' : 'Перевожу…'))
                          : (strings.isPl
                              ? 'Przetłumacz tekst'
                              : (strings.isUk ? 'Перекласти текст' : 'Перевести текст')),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _analyzeDocument(_textInputController.text),
                          icon: const Icon(Icons.gavel_rounded, size: 18),
                          label: Text(
                            strings.isPl
                                ? 'Analiza dokumentu'
                                : (strings.isUk ? 'Аналіз документа' : 'Анализ документа'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _analyzeMenu(_textInputController.text),
                          icon: const Icon(Icons.restaurant_menu, size: 18),
                          label: Text(
                            strings.isPl
                                ? 'Menu restauracji'
                                : (strings.isUk ? 'Меню ресторану' : 'Меню ресторана'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_textTranslationResult != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: theme.colorScheme.surface,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.translate, size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                strings.isPl
                                    ? 'Tłumaczenie:'
                                    : (strings.isUk ? 'Переклад:' : 'Перевод:'),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _textTranslationResult!,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 18,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonalIcon(
                              onPressed: () =>
                                  _batchAddWords(_textInputController.text),
                              icon: const Icon(Icons.bookmark_add, size: 16),
                              label: Text(
                                strings.isPl
                                    ? '📥 Dodaj słowa kluczowe do słownika (AI)'
                                    : (strings.isUk
                                        ? '📥 Додати ключові слова до словника (ШІ)'
                                        : '📥 Добавить ключевые слова в словарь (ИИ)'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
    }
  }

  Widget _buildViewport() {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (await Permission.camera.isPermanentlyDenied) {
                    await openAppSettings();
                  } else {
                    _initCamera();
                  }
                },
                child: Text(strings.isPl
                    ? 'Powtórz'
                    : (strings.isUk ? 'Повторити' : 'Повторить')),
              ),
            ],
          ),
        ),
      );
    }
    if (_shotPath != null && _result != null) {
      return WordOverlay(
        imagePath: _shotPath!,
        image: FileImage(File(_shotPath!)),
        result: _result!,
        selected: _selected,
        onWordTap: _onWordTap,
      );
    }
    final c = _camera;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1 / c.value.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(c),
              if (_busy)
                const ColoredBox(
                  color: Colors.black38,
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraControls(bool hasShot) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: hasShot
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  _result!.words.isEmpty
                      ? (strings.isPl
                          ? 'Nie znaleziono słów'
                          : (strings.isUk ? 'Слів не знайдено' : 'Слов не найдено'))
                      : (strings.isPl
                          ? 'Słów: ${_result!.words.length} · dotknij słowa'
                          : (strings.isUk
                              ? 'Слів: ${_result!.words.length} · торкніться слова'
                              : 'Слов: ${_result!.words.length} · коснитесь слова')),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _result!.words.isEmpty
                          ? null
                          : () => _analyzeDocument(_result!.fullText),
                      icon: const Icon(Icons.gavel_rounded, size: 18),
                      label: Text(strings.docAnalysisBtn),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryCarmine,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _result!.words.isEmpty
                          ? null
                          : () => _analyzeMenu(_result!.fullText),
                      icon: const Icon(Icons.restaurant_menu, size: 18),
                      label: Text(strings.menuAnalysisBtn),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _result!.words.isEmpty
                          ? null
                          : () => _translateParagraph(_result!.fullText),
                      icon: const Icon(Icons.translate, size: 18),
                      label: Text(strings.translateAll),
                    ),
                    OutlinedButton.icon(
                      onPressed: _retake,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(strings.isPl
                          ? 'Zrób ponownie'
                          : (strings.isUk ? 'Зняти знову' : 'Снять заново')),
                    ),
                  ],
                ),
              ])
            : GestureDetector(
                onTap: _capture,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _busy ? Colors.grey : theme.colorScheme.primary,
                    border: Border.all(color: theme.colorScheme.surface, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                ),
              ),
      ),
    );
  }
}
