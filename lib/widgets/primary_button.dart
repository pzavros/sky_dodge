import 'package:flutter/material.dart';

enum ButtonTone { sky, sunset, candy }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = ButtonTone.sky,
    this.expand = true,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonTone tone;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForTone(tone);
    final disabled = onPressed == null;

    final button = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: disabled ? 0.0 : 0.36),
                blurRadius: 24,
                spreadRadius: -3,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon ?? Icons.play_arrow_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final wrapped = Opacity(opacity: disabled ? 0.5 : 1, child: button);
    if (!expand) return wrapped;

    return SizedBox(width: double.infinity, child: wrapped);
  }

  List<Color> _colorsForTone(ButtonTone tone) {
    switch (tone) {
      case ButtonTone.sky:
        return const [Color(0xFF2DC8FF), Color(0xFF2F6BFF)];
      case ButtonTone.sunset:
        return const [Color(0xFFFFC15D), Color(0xFFFF7A59)];
      case ButtonTone.candy:
        return const [Color(0xFFFF6FC8), Color(0xFF8C68FF)];
    }
  }
}
