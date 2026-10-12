import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Аккуратная анимированная звуковая волна (3-4 пульсирующие полоски).
/// Создает эффект живой человеческой речи при воспроизведении озвучки или TTS.
/// Энергоэффективна: использует легковесный контроллер и выгружается при остановке.
class TalkingWaveIndicator extends StatefulWidget {
  const TalkingWaveIndicator({
    super.key,
    this.color,
    this.height = 18.0,
    this.barCount = 4,
  });

  final Color? color;
  final double height;
  final int barCount;

  @override
  State<TalkingWaveIndicator> createState() => _TalkingWaveIndicatorState();
}

class _TalkingWaveIndicatorState extends State<TalkingWaveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            // Разная фаза для каждого столбца для естественной синусоидальной волны
            final phase = index * 0.75;
            final scale = (math.sin((t * 2 * math.pi) + phase) + 1.0) / 2.0;
            // Минимальная высота 4px, максимальная widget.height
            final barH = 4.0 + (widget.height - 4.0) * (0.25 + 0.75 * scale);

            return Container(
              width: 3.2,
              height: barH,
              margin: const EdgeInsets.symmetric(horizontal: 1.4),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            );
          }),
        );
      },
    );
  }
}

