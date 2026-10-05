import 'package:flutter/material.dart';

class CoinChip extends StatelessWidget {
  const CoinChip({super.key, required this.coins, this.compact = false});

  final int coins;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textStyle = compact
        ? Theme.of(context).textTheme.labelLarge
        : Theme.of(context).textTheme.titleMedium;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 11 : 15,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4A4), Color(0xFFFFC95B), Color(0xFFFF9F3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFEFC5), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB24C).withValues(alpha: 0.45),
            blurRadius: 18,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            size: 18,
            color: Color(0xFF6D4200),
          ),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: textStyle?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4C2A00),
            ),
          ),
        ],
      ),
    );
  }
}
