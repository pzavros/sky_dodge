import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/ads_service.dart';
import 'services/audio_service.dart';
import 'services/app_state.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = await AppState.create(
    storage: StorageService(),
    adsService: const StubAdsService(),
    audioService: GameAudioService(),
  );

  runApp(SkyDropApp(appState: appState));
}

class SkyDropApp extends StatelessWidget {
  const SkyDropApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky Drop',
      debugShowCheckedModeBanner: false,
      theme: buildGameTheme(),
      home: HomeScreen(appState: appState),
    );
  }
}
