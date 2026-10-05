import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../widgets/coin_chip.dart';
import '../widgets/glass_panel.dart';
import '../widgets/primary_button.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    super.key,
    required this.score,
    required this.bestScore,
    required this.coinsEarned,
    required this.coinsSpent,
    required this.netCoins,
    required this.currentCoins,
    required this.balanceAfterClaim,
    required this.canRevive,
    required this.onRetry,
    required this.onHome,
    this.onReviveCoins,
    this.onReviveAd,
    this.busy = false,
  });

  final int score;
  final int bestScore;
  final int coinsEarned;
  final int coinsSpent;
  final int netCoins;
  final int currentCoins;
  final int balanceAfterClaim;
  final bool canRevive;
  final bool busy;
  final Future<void> Function() onRetry;
  final Future<void> Function() onHome;
  final Future<void> Function()? onReviveCoins;
  final Future<void> Function()? onReviveAd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF071225).withValues(alpha: 0.58),
                    const Color(0xFF120A29).withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
          ),
        ),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.92, end: 1),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: GlassPanel(
                margin: const EdgeInsets.all(18),
                borderRadius: 24,
                glowColor: const Color(0xFFFF6A77),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.crisis_alert_rounded,
                          color: Color(0xFFFFD98C),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Game Over',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ScoreStrip(score: score, bestScore: bestScore),
                    const SizedBox(height: 8),
                    GlassPanel(
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Run Reward +$coinsEarned',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const Spacer(),
                          const Text('Wallet now'),
                          const SizedBox(width: 8),
                          CoinChip(coins: currentCoins, compact: true),
                        ],
                      ),
                    ),
                    if (coinsSpent > 0) ...[
                      const SizedBox(height: 8),
                      GlassPanel(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text('Revive spent'),
                                const Spacer(),
                                Text('-$coinsSpent'),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Text('Net this run'),
                                const Spacer(),
                                Text(
                                  netCoins >= 0 ? '+$netCoins' : '$netCoins',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Balance after claim: $balanceAfterClaim',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFFFEEA9),
                      ),
                    ),
                    if (canRevive) ...[
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: 'Revive (-${EconomyConfig.revivePrice})',
                        icon: Icons.favorite_rounded,
                        tone: ButtonTone.sky,
                        onPressed: busy ? null : () => onReviveCoins?.call(),
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Revive (Watch Ad)',
                        icon: Icons.ondemand_video_rounded,
                        tone: ButtonTone.candy,
                        onPressed: busy ? null : () => onReviveAd?.call(),
                      ),
                    ],
                    const SizedBox(height: 10),
                    PrimaryButton(
                      label: 'Retry',
                      icon: Icons.replay_rounded,
                      tone: ButtonTone.sunset,
                      onPressed: busy ? null : onRetry,
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: 'Home',
                      icon: Icons.home_rounded,
                      tone: ButtonTone.sky,
                      onPressed: busy ? null : onHome,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreStrip extends StatelessWidget {
  const _ScoreStrip({required this.score, required this.bestScore});

  final int score;
  final int bestScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassPanel(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [
                Text(
                  'Score',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.white70),
                ),
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                    color: const Color(0xFFBEE9FF),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassPanel(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [
                Text(
                  'Best',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.white70),
                ),
                Text(
                  '$bestScore',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                    color: const Color(0xFFFFD58F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
