import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_dodge/main.dart';
import 'package:sky_dodge/services/ads_service.dart';
import 'package:sky_dodge/services/audio_service.dart';
import 'package:sky_dodge/services/app_state.dart';
import 'package:sky_dodge/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home screen renders', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final appState = await AppState.create(
      storage: StorageService(),
      adsService: const StubAdsService(),
      audioService: const NoopAudioService(),
    );

    await tester.pumpWidget(SkyDropApp(appState: appState));

    expect(find.text('Sky Drop'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });
}
