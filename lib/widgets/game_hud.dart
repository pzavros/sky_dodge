import 'package:flutter/material.dart';

import 'coin_chip.dart';
import 'glass_panel.dart';
import 'primary_button.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.score,
    required this.runCoins,
    required this.shieldCount,
    required this.slowMoCount,
    required this.shieldArmed,
    required this.slowMoRemaining,
    required this.onShield,
    required this.onSlowMo,
  });

  final int score;
  final int runCoins;
  final int shieldCount;
  final int slowMoCount;
  final bool shieldArmed;
  final double slowMoRemaining;
  final VoidCallback onShield;
  final VoidCallback onSlowMo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassPanel(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.rocket_launch_rounded,
                    color: Color(0xFFBFEAFF),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Score $score',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              CoinChip(coins: runCoins, compact: true),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: shieldArmed
                    ? 'Shield ON x$shieldCount'
                    : 'Shield x$shieldCount',
                icon: Icons.shield_rounded,
                tone: ButtonTone.sky,
                height: 48,
                onPressed: !shieldArmed && shieldCount > 0 ? onShield : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PrimaryButton(
                label: slowMoRemaining > 0
                    ? 'Slow-mo ON x$slowMoCount'
                    : 'Slow-mo x$slowMoCount',
                icon: Icons.hourglass_bottom_rounded,
                tone: ButtonTone.candy,
                height: 48,
                onPressed: slowMoRemaining <= 0.05 && slowMoCount > 0
                    ? onSlowMo
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
