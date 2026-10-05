import 'package:flutter/material.dart';

import '../game/models/skin.dart';
import '../services/app_state.dart';
import '../widgets/arcade_background.dart';
import '../widgets/coin_chip.dart';
import '../widgets/glass_panel.dart';
import '../widgets/primary_button.dart';
import '../widgets/skin_preview.dart';

class SkinsScreen extends StatelessWidget {
  const SkinsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skins')),
      body: ArcadeBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CoinChip(coins: appState.coins),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        itemCount: SkinCatalog.all.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.84,
                            ),
                        itemBuilder: (context, index) {
                          final skin = SkinCatalog.all[index];
                          final unlocked = appState.isSkinUnlocked(skin.id);
                          final selected = appState.selectedSkinId == skin.id;

                          return _SkinCard(
                            skin: skin,
                            unlocked: unlocked,
                            selected: selected,
                            onTap: () async {
                              if (selected) return;
                              if (unlocked) {
                                await appState.selectSkin(skin.id);
                                return;
                              }

                              final success = await appState.buySkin(skin);
                              if (!context.mounted || success) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Not enough coins.'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SkinCard extends StatelessWidget {
  const _SkinCard({
    required this.skin,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final SkinModel skin;
  final bool unlocked;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glowColor = selected ? skin.primaryColor : null;

    return GlassPanel(
      borderRadius: 20,
      glowColor: glowColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            child: SkinPreview(skin: skin, size: 74, showGlow: selected),
          ),
          const SizedBox(height: 8),
          Text(
            skin.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (selected)
            PrimaryButton(
              label: 'Selected',
              icon: Icons.check_circle_rounded,
              tone: ButtonTone.sky,
              onPressed: null,
              height: 44,
            )
          else if (unlocked)
            PrimaryButton(
              label: 'Select',
              icon: Icons.touch_app_rounded,
              tone: ButtonTone.candy,
              onPressed: onTap,
              height: 44,
            )
          else
            PrimaryButton(
              label: 'Unlock ${skin.price}',
              icon: Icons.lock_open_rounded,
              tone: ButtonTone.sunset,
              onPressed: onTap,
              height: 44,
            ),
        ],
      ),
    );
  }
}
