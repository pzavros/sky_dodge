import 'package:flutter/material.dart';

import '../game/models/skin.dart';

class SkinPreview extends StatelessWidget {
  const SkinPreview({
    super.key,
    required this.skin,
    this.size = 70,
    this.showGlow = true,
  });

  final SkinModel skin;
  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x66FFFFFF), Color(0x22FFFFFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
        boxShadow: [
          if (showGlow)
            BoxShadow(
              color: skin.primaryColor.withValues(alpha: 0.32),
              blurRadius: 18,
              spreadRadius: -4,
            ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.54,
          height: size * 0.64,
          decoration: BoxDecoration(
            color: skin.primaryColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.44)),
          ),
          child: skin.isAstronaut
              ? Center(
                  child: Container(
                    width: size * 0.28,
                    height: size * 0.15,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA6D9FF), Color(0xFF5E9FD8)],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    width: size * 0.13,
                    height: size * 0.65,
                    decoration: BoxDecoration(
                      color: skin.accentColor ?? Colors.white70,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
