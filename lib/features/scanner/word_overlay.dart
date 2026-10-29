import 'package:flutter/material.dart';

import 'ocr_service.dart';

/// Показывает снимок и подсвеченные боксы слов с возможностью интерактивного зума (pinch-to-zoom).
/// Тап по слову вызывает [onWordTap].
class WordOverlay extends StatefulWidget {
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
  State<WordOverlay> createState() => _WordOverlayState();
}

class _WordOverlayState extends State<WordOverlay> {
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformed);
  }

  void _onTransformed() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.05) {
      setState(() => _currentScale = scale);
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformed);
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
      _currentScale = 1.0;
    });
  }

  void _zoomIn() {
    final current = _transformationController.value.getMaxScaleOnAxis();
    final next = (current * 1.5).clamp(1.0, 6.0);
    _applyScale(next);
  }

  void _zoomOut() {
    final current = _transformationController.value.getMaxScaleOnAxis();
    final next = (current / 1.5).clamp(1.0, 6.0);
    if (next <= 1.08) {
      _resetZoom();
    } else {
      _applyScale(next);
    }
  }

  void _applyScale(double targetScale) {
    setState(() {
      _transformationController.value =
          Matrix4.diagonal3Values(targetScale, targetScale, 1.0);
      _currentScale = targetScale;
    });
  }

  void _handleDoubleTap(Offset tapPosition) {
    if (_currentScale > 1.2) {
      _resetZoom();
    } else {
      const targetScale = 2.5;
      final tx = -tapPosition.dx * (targetScale - 1);
      final ty = -tapPosition.dy * (targetScale - 1);
      final m = Matrix4.diagonal3Values(targetScale, targetScale, 1.0)
        ..setTranslationRaw(tx, ty, 0.0);
      setState(() {
        _transformationController.value = m;
        _currentScale = targetScale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final view = constraints.biggest;
      final src = widget.result.imageSize;
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
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 1.0,
            maxScale: 6.0,
            panEnabled: true,
            scaleEnabled: true,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: view.width,
              height: view.height,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTapDown: (d) => _handleDoubleTap(d.localPosition),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(image: widget.image, fit: BoxFit.contain),
                    for (final w in widget.result.words)
                      if (w.clean.isNotEmpty)
                        Positioned.fromRect(
                          rect: toView(w.box).inflate(2),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.onWordTap(w),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: (identical(w, widget.selected)
                                        ? Colors.amber
                                        : Colors.lightBlueAccent)
                                    .withValues(
                                        alpha: identical(w, widget.selected)
                                            ? 0.55
                                            : 0.28),
                                border: Border.all(
                                  color: identical(w, widget.selected)
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
                ),
              ),
            ),
          ),
          // Панель быстрого зума и сброса масштаба
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out, color: Colors.white, size: 20),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Уменьшить',
                      onPressed: _currentScale > 1.08 ? _zoomOut : null,
                    ),
                    InkWell(
                      onTap: _currentScale > 1.08 ? _resetZoom : _zoomIn,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text(
                          '${_currentScale.toStringAsFixed(1)}x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Увеличить',
                      onPressed: _currentScale < 5.8 ? _zoomIn : null,
                    ),
                    if (_currentScale > 1.08) ...[
                      const SizedBox(width: 2),
                      IconButton(
                        icon: const Icon(Icons.restart_alt, color: Colors.amberAccent, size: 20),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Сбросить масштаб (1.0x)',
                        onPressed: _resetZoom,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Подсказка о жесте pinch-to-zoom внизу
          if (_currentScale <= 1.08)
            Positioned(
              bottom: 12,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pinch_outlined, color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Масштабируйте пальцами или кнопками зума',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
