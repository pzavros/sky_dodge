import 'dart:math';

import 'package:flutter/material.dart';

class ArcadeBackground extends StatelessWidget {
  const ArcadeBackground({
    super.key,
    required this.child,
    this.topGlowColor = const Color(0xFF1DAEFF),
    this.bottomGlowColor = const Color(0xFFFFB347),
  });

  final Widget child;
  final Color topGlowColor;
  final Color bottomGlowColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF081427), Color(0xFF0F2B4A), Color(0xFF1C5B86)],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _ArcadeSkyPainter(
              topGlowColor: topGlowColor,
              bottomGlowColor: bottomGlowColor,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _ArcadeSkyPainter extends CustomPainter {
  const _ArcadeSkyPainter({
    required this.topGlowColor,
    required this.bottomGlowColor,
  });

  final Color topGlowColor;
  final Color bottomGlowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [topGlowColor.withValues(alpha: 0.30), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.18, size.height * 0.08),
              radius: size.width * 0.55,
            ),
          );

    final bottomGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              bottomGlowColor.withValues(alpha: 0.22),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.84, size.height * 0.85),
              radius: size.width * 0.65,
            ),
          );

    canvas.drawRect(Offset.zero & size, topGlow);
    canvas.drawRect(Offset.zero & size, bottomGlow);

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.42);
    for (var i = 0; i < 90; i++) {
      final x = ((i * 73) % 100) / 100 * size.width;
      final y = ((i * 97) % 100) / 100 * size.height;
      final radius = 0.8 + (i % 4) * 0.35;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    final streakPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 18; i++) {
      final y = (i / 18) * size.height;
      final startX = sin(i * 0.7) * 12;
      canvas.drawLine(
        Offset(startX, y),
        Offset(size.width + 30, y + 26),
        streakPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcadeSkyPainter oldDelegate) {
    return oldDelegate.topGlowColor != topGlowColor ||
        oldDelegate.bottomGlowColor != bottomGlowColor;
  }
}
