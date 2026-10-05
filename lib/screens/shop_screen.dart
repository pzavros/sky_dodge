import 'package:flutter/material.dart';

import '../game/models/boost.dart';
import '../services/app_state.dart';
import '../widgets/arcade_background.dart';
import '../widgets/coin_chip.dart';
import '../widgets/glass_panel.dart';
import '../widgets/primary_button.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boost Shop')),
      body: ArcadeBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                children: [
                  Row(
                    children: [
                      Text(
                        'Balance',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(width: 10),
                      CoinChip(coins: appState.coins),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _BoostCard(
                    title: 'Shield',
                    description: 'Ignore one collision when active.',
                    price: EconomyConfig.shieldPrice,
                    count: appState.shieldCount,
                    colorA: const Color(0xFF56D1FF),
                    colorB: const Color(0xFF3C8CFF),
                    onBuy: () => _buyBoost(context, BoostType.shield),
                  ),
                  const SizedBox(height: 12),
                  _BoostCard(
                    title: 'Slow-mo',
                    description: 'Slows obstacles for 3 seconds.',
                    price: EconomyConfig.slowMoPrice,
                    count: appState.slowMoCount,
                    colorA: const Color(0xFFFF76CC),
                    colorB: const Color(0xFF8D65FF),
                    onBuy: () => _buyBoost(context, BoostType.slowMo),
                  ),
                  const SizedBox(height: 14),
                  GlassPanel(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      'Boosts are consumables. Activate them during a run from the top HUD.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _buyBoost(BuildContext context, BoostType type) async {
    final success = await appState.buyBoost(type);
    if (!context.mounted || success) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Not enough coins.')));
  }
}

class _BoostCard extends StatelessWidget {
  const _BoostCard({
    required this.title,
    required this.description,
    required this.price,
    required this.count,
    required this.colorA,
    required this.colorB,
    required this.onBuy,
  });

  final String title;
  final String description;
  final int price;
  final int count;
  final Color colorA;
  final Color colorB;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 20,
      glowColor: colorA,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colorA, colorB]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.50)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Owned: $count',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFFFEEA9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 112,
            child: PrimaryButton(
              label: 'Buy $price',
              icon: Icons.shopping_basket_rounded,
              tone: ButtonTone.sunset,
              height: 46,
              onPressed: onBuy,
            ),
          ),
        ],
      ),
    );
  }
}
