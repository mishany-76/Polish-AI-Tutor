import 'package:flutter/material.dart';

import 'ocr_service.dart';

/// Показывает снимок и подсвеченные боксы слов; тап по слову вызывает [onWordTap].
class WordOverlay extends StatelessWidget {
  const WordOverlay({
    super.key,
    required this.imagePath,
    required this.image,
    required this.result,
    required this.selected,
    required this.onWordTap,
  });

  final ImageProvider image;
  final String imagePath;
  final OcrResult result;
  final OcrWord? selected;
  final ValueChanged<OcrWord> onWordTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final view = constraints.biggest;
      final src = result.imageSize;
      // BoxFit.contain: единый масштаб + центрирование.
      final scale = (view.width / src.width) < (view.height / src.height)
          ? view.width / src.width
          : view.height / src.height;
      final dx = (view.width - src.width * scale) / 2;
      final dy = (view.height - src.height * scale) / 2;

      Rect toView(Rect r) => Rect.fromLTRB(
            dx + r.left * scale,
            dy + r.top * scale,
            dx + r.right * scale,
            dy + r.bottom * scale,
          );

      return Stack(
        fit: StackFit.expand,
        children: [
          Image(image: image, fit: BoxFit.contain),
          for (final w in result.words)
            if (w.clean.isNotEmpty)
              Positioned.fromRect(
                rect: toView(w.box).inflate(2),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onWordTap(w),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: (identical(w, selected)
                              ? Colors.amber
                              : Colors.lightBlueAccent)
                          .withValues(alpha: identical(w, selected) ? 0.45 : 0.25),
                      border: Border.all(
                        color: identical(w, selected)
                            ? Colors.amber
                            : Colors.lightBlueAccent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
        ],
      );
    });
  }
}

