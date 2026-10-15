import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:permission_handler/permission_handler.dart';

import '../../core/ai_client/ai_client.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import 'ocr_service.dart';
import 'scanner_providers.dart';
import 'translation_service.dart';
import 'word_overlay.dart';
import 'word_sheet.dart';

enum TranslatorMode { camera, document, text }

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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(settingsProvider.select((s) => s.lang));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Переводчик'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          SegmentedButton<UiLang>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: Colors.white70,
              selectedForegroundColor: Colors.black,
              selectedBackgroundColor: Colors.white,
            ),
            segments: const [
              ButtonSegment(value: UiLang.uk, label: Text('🇺🇦 UK')),
              ButtonSegment(value: UiLang.ru, label: Text('🇷🇺 RU')),
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
            color: Colors.grey.shade900,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<TranslatorMode>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white70,
                ),
                segments: const [
                  ButtonSegment(
                    value: TranslatorMode.camera,
                    label: Text('📷 Камера', style: TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: TranslatorMode.document,
                    label: Text('📁 Файл/PDF', style: TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: TranslatorMode.text,
                    label: Text('✍️ Текст', style: TextStyle(fontSize: 12)),
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
                    spacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _translateParagraph(_result!.fullText),
                        icon: const Icon(Icons.translate),
                        label: const Text('📄 Перевести весь текст'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickDocumentOrImage,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Выбрать другой файл'),
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
                const Icon(Icons.picture_as_pdf, size: 64, color: Colors.white70),
                const SizedBox(height: 16),
                const Text(
                  'Выберите PDF-документ или фото из галереи для OCR-распознавания',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _pickDocumentOrImage,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Выбрать файл (PDF / Фото)'),
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
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Вставьте или введите польский текст для перевода…',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.black45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
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
                        icon: const Icon(Icons.translate),
                        label: Text(_translatingText ? 'Перевожу…' : 'Перевести'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Очистить',
                      onPressed: () {
                        _textInputController.clear();
                        setState(() => _textTranslationResult = null);
                      },
                      icon: const Icon(Icons.clear, color: Colors.white70),
                    ),
                  ],
                ),
                if (_textTranslationResult != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.grey.shade900,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.translate, size: 16, color: Colors.white70),
                              const SizedBox(width: 6),
                              const Text('Перевод:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _textTranslationResult!,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonalIcon(
                              onPressed: () =>
                                  _batchAddWords(_textInputController.text),
                              icon: const Icon(Icons.bookmark_add, size: 16),
                              label: const Text('📥 Добавить ключевые слова в словарь (ИИ)'),
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
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (await Permission.camera.isPermanentlyDenied) {
                    await openAppSettings();
                  } else {
                    _initCamera();
                  }
                },
                child: const Text('Повторить'),
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
    return Center(
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
    );
  }

  Widget _buildCameraControls(bool hasShot) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: hasShot
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  _result!.words.isEmpty
                      ? 'Слов не найдено'
                      : 'Слов: ${_result!.words.length} · коснитесь слова',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _result!.words.isEmpty ? null : () => _translateParagraph(_result!.fullText),
                      icon: const Icon(Icons.translate),
                      label: const Text('📄 Перевести весь абзац'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _retake,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Снять заново'),
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
                    color: _busy ? Colors.grey : Colors.white,
                    border: Border.all(color: Colors.white54, width: 4),
                  ),
                ),
              ),
      ),
    );
  }
}
