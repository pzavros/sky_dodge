import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../widgets/arcade_background.dart';
import '../widgets/coin_chip.dart';
import '../widgets/glass_panel.dart';
import '../widgets/primary_button.dart';
import '../widgets/skin_preview.dart';
import 'game_screen.dart';
import 'shop_screen.dart';
import 'skins_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArcadeBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              final skin = appState.selectedSkin;
              return LayoutBuilder(
                builder: (context, viewport) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 430,
                          minHeight: viewport.maxHeight - 24,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  CoinChip(coins: appState.coins),
                                  const Spacer(),
                                  GlassPanel(
                                    borderRadius: 999,
                                    padding: const EdgeInsets.all(6),
                                    child: IconButton(
                                      tooltip: appState.soundOn
                                          ? 'Sound on (tap to mute)'
                                          : 'Sound off (tap to unmute)',
                                      onPressed: appState.toggleSound,
                                      icon: Icon(
                                        appState.soundOn
                                            ? Icons.volume_up_rounded
                                            : Icons.volume_off_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              const _SkyDropTitle(),
                              const SizedBox(height: 4),
                              Text(
                                'Swipe, dodge, survive.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 18),
                              GlassPanel(
                                glowColor: skin.primaryColor,
                                child: Row(
                                  children: [
                                    SkinPreview(skin: skin, size: 66),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pilot Skin',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            skin.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(fontSize: 24),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: Color(0xFFFFE6A1),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              PrimaryButton(
                                label: 'Play',
                                icon: Icons.play_arrow_rounded,
                                tone: ButtonTone.sky,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          GameScreen(appState: appState),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              PrimaryButton(
                                label: 'Skins',
                                icon: Icons.style_rounded,
                                tone: ButtonTone.candy,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          SkinsScreen(appState: appState),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              PrimaryButton(
                                label: 'Shop',
                                icon: Icons.storefront_rounded,
                                tone: ButtonTone.sunset,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          ShopScreen(appState: appState),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              GlassPanel(
                                borderRadius: 16,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Text(
                                  'Best Score: ${appState.bestScore}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SkyDropTitle extends StatelessWidget {
  const _SkyDropTitle();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.displayLarge?.copyWith(
      fontSize: 56,
      fontWeight: FontWeight.w900,
      shadows: const [
        Shadow(color: Color(0xA6000000), blurRadius: 16, offset: Offset(0, 8)),
      ],
    );

    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDEFDFF), Color(0xFF7CD8FF), Color(0xFFFFCA6D)],
        ).createShader(bounds);
      },
      child: Text(
        'Sky Drop',
        textAlign: TextAlign.center,
        style: style?.copyWith(color: Colors.white),
      ),
    );
  }
}
