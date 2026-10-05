# Sky Drop (Flutter MVP)

Offline hyper-casual mobile game (iOS + Android) built with pure Flutter widgets + a ticker-driven game loop.

## Features

- 3-lane infinite dodger gameplay (swipe/tap left-right)
- Smooth lane snap movement
- Obstacle rows spawning from patterns (never all 3 lanes blocked)
- Collision + game over + one revive per run
- Score + best score persistence
- Local economy:
  - Coins earned each run (`score ~/ 5`)
  - Revive for coins or rewarded ad stub
  - Boosts: Shield and Slow-mo (consumables)
  - Skins: unlock/select locally
- Interstitial stub every N deaths
- Background music + hit/lose SFX
- No backend, no auth, offline-only

## Project Structure

- `lib/main.dart`
- `lib/screens/`
  - `home_screen.dart`
  - `game_screen.dart`
  - `game_over_screen.dart`
  - `skins_screen.dart`
  - `shop_screen.dart`
- `lib/game/`
  - `game_controller.dart`
  - `game_painter.dart`
  - `models/`
- `lib/services/`
  - `storage_service.dart`
  - `app_state.dart`
  - `ads_service.dart`
  - `audio_service.dart`
- `lib/widgets/`
  - `primary_button.dart`
  - `coin_chip.dart`
  - `game_hud.dart`
  - `skin_preview.dart`
- `assets/audio/`
  - `bgm_loop.wav`
  - `hit.wav`
  - `lose.wav`

## Run

1. Install Flutter stable.
2. From project root:

```bash
flutter pub get
flutter run
```

Run on Android emulator or iOS simulator with your normal Flutter tooling.

## Audio

- Audio is controlled by `soundOn` in app settings and wired through `lib/services/audio_service.dart`.
- Current bundled audio files are placeholder WAVs in `assets/audio/`.
- Replace them with your own files using the same names/paths, or update paths in `audio_service.dart`.

## AdMob Integration Hook

Replace `StubAdsService` in `lib/services/ads_service.dart` with your AdMob-backed implementation:

- `showRewardedReviveAd()` for revive flow
- `showInterstitial()` for periodic interstitial display

Then change the service wiring in `lib/main.dart` to use your real ads service.
