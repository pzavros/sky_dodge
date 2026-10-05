import 'dart:math';

import 'package:flutter/material.dart';

import 'game_controller.dart';
import 'models/skin.dart';

class GamePainter extends CustomPainter {
  GamePainter({required this.controller}) : super(repaint: controller);

  final GameController controller;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintLanes(canvas, size);
    _paintObstacles(canvas);
    _paintPlayer(canvas);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Color(0xFF071225), Color(0xFF0F2E50), Color(0xFF2375A5)],
    );

    final basePaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, basePaint);

    final t = controller.timeSurvived;
    final nearShift = (t * 80) % size.height;
    final farShift = (t * 30) % size.height;

    final farPaint = Paint()..color = Colors.white.withValues(alpha: 0.10);
    final nearPaint = Paint()..color = Colors.white.withValues(alpha: 0.16);

    for (var i = 0; i < 24; i++) {
      final x = ((i * 37) % 100) / 100 * size.width;
      final y = ((i * 121) - farShift) % size.height;
      canvas.drawCircle(Offset(x, y), 1.6 + (i % 3) * 0.6, farPaint);
    }

    for (var i = 0; i < 8; i++) {
      final baseX = ((i * 89) + (sin(t + i) * 24)) % size.width;
      final y = ((i * 160) - nearShift) % size.height;
      final cloudRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(baseX, y), width: 82, height: 26),
        const Radius.circular(14),
      );
      canvas.drawRRect(cloudRect, nearPaint);
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.32)],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  void _paintLanes(Canvas canvas, Size size) {
    final laneWidth = size.width / GameController.laneCount;

    final laneGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.20),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size)
      ..strokeWidth = 1.2;

    for (var i = 1; i < GameController.laneCount; i++) {
      final x = laneWidth * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), laneGlow);

      for (var j = 0; j < 16; j++) {
        final y =
            (j * 70 + (controller.timeSurvived * 90)) % (size.height + 70);
        final marker = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: 6, height: 28),
          const Radius.circular(4),
        );
        canvas.drawRRect(
          marker,
          Paint()..color = Colors.white.withValues(alpha: 0.10),
        );
      }
    }
  }

  void _paintObstacles(Canvas canvas) {
    for (final obstacle in controller.obstacles) {
      final rect = controller.obstacleRect(obstacle);
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(14));

      final shadow = Paint()
        ..color = const Color(0xFFA82E43).withValues(alpha: 0.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(rRect.inflate(2), shadow);

      final fill = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF7B84), Color(0xFFD73D57)],
        ).createShader(rect);
      canvas.drawRRect(rRect, fill);

      final edge = Paint()
        ..color = Colors.white.withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRRect(rRect, edge);

      final stripe = Rect.fromCenter(
        center: Offset(rect.center.dx, rect.center.dy),
        width: rect.width * 0.75,
        height: 5,
      );
      canvas.drawRect(
        stripe,
        Paint()..color = Colors.white.withValues(alpha: 0.18),
      );
    }
  }

  void _paintPlayer(Canvas canvas) {
    final playerRect = controller.playerRect();
    final skin = SkinCatalog.byId(controller.appState.selectedSkinId);

    final trailRect = Rect.fromCenter(
      center: Offset(playerRect.center.dx, playerRect.bottom + 10),
      width: playerRect.width * 0.62,
      height: 22,
    );
    canvas.drawOval(
      trailRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFC272).withValues(alpha: 0.60),
            Colors.transparent,
          ],
        ).createShader(trailRect),
    );

    final bodyPaint = Paint()..color = skin.primaryColor;
    final accentPaint = Paint()..color = (skin.accentColor ?? Colors.white70);

    final body = RRect.fromRectAndRadius(playerRect, const Radius.circular(16));
    canvas.drawRRect(body, bodyPaint);

    final edge = Paint()
      ..color = Colors.white.withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawRRect(body, edge);

    if (skin.isAstronaut) {
      final visorRect = Rect.fromCenter(
        center: Offset(playerRect.center.dx, playerRect.center.dy - 6),
        width: playerRect.width * 0.62,
        height: playerRect.height * 0.34,
      );
      canvas.drawOval(visorRect, accentPaint..color = const Color(0xFF90B7D9));
    } else {
      final stripe = Rect.fromCenter(
        center: Offset(playerRect.center.dx, playerRect.center.dy),
        width: playerRect.width * 0.22,
        height: playerRect.height,
      );
      canvas.drawRect(stripe, accentPaint);
    }

    if (controller.shieldArmed) {
      final shield = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF80D0FF);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          playerRect.inflate(5),
          const Radius.circular(18),
        ),
        shield,
      );
    }

    if (controller.isInvulnerable) {
      final flash = Paint()..color = Colors.white.withValues(alpha: 0.24);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          playerRect.inflate(8),
          const Radius.circular(20),
        ),
        flash,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return false;
  }
}
