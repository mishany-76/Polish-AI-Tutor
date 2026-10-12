import 'dart:io';
import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Слово, найденное на снимке, с ограничивающим прямоугольником
/// в координатах исходного изображения (в пикселях).
class OcrWord {
  const OcrWord({required this.text, required this.box, this.lineText = ''});

  /// Текст как распознан (может содержать знаки препинания).
  final String text;
  final Rect box;

  /// Вся строка, в которой найдено слово (контекст для ИИ-разбора).
  final String lineText;

  /// Слово без знаков препинания по краям — для перевода и словаря.
  String get clean => text.replaceAll(
        RegExp(r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$', unicode: true),
        '',
      );
}

class OcrResult {
  const OcrResult({
    required this.words,
    required this.imageSize,
    required this.fullText,
  });

  final List<OcrWord> words;
  final Size imageSize;
  final String fullText;
}

/// Распознавание текста ML Kit (on-device, офлайн, латиница — подходит для польского).
class OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<OcrResult> recognize(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final size = Size(
      frame.image.width.toDouble(),
      frame.image.height.toDouble(),
    );
    frame.image.dispose();

    final recognized =
        await _recognizer.processImage(InputImage.fromFilePath(imagePath));

    final words = <OcrWord>[
      for (final block in recognized.blocks)
        for (final line in block.lines)
          for (final element in line.elements)
            if (element.text.trim().isNotEmpty)
              OcrWord(
                text: element.text,
                box: element.boundingBox,
                lineText: line.text,
              ),
    ];

    return OcrResult(words: words, imageSize: size, fullText: recognized.text);
  }

  Future<void> dispose() => _recognizer.close();
}

