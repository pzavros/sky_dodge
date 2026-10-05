import 'dart:ui';

import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 22,
    this.glowColor,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? glowColor;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.20),
                Colors.white.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.40),
              width: 1.2,
            ),
            boxShadow: [
              if (glowColor != null)
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.36),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin == null) return panel;
    return Padding(padding: margin!, child: panel);
  }
}
