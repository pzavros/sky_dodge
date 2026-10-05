import 'package:shared_preferences/shared_preferences.dart';

class StoredProfile {
  const StoredProfile({
    required this.coins,
    required this.bestScore,
    required this.selectedSkinId,
    required this.unlockedSkinIds,
    required this.soundOn,
    required this.shieldCount,
    required this.slowMoCount,
    required this.totalDeaths,
  });

  final int coins;
  final int bestScore;
  final int selectedSkinId;
  final Set<int> unlockedSkinIds;
  final bool soundOn;
  final int shieldCount;
  final int slowMoCount;
  final int totalDeaths;
}

class StorageService {
  static const String _coinsKey = 'coins';
  static const String _bestScoreKey = 'best_score';
  static const String _selectedSkinKey = 'selected_skin';
  static const String _unlockedSkinsKey = 'unlocked_skins';
  static const String _soundOnKey = 'sound_on';
  static const String _shieldCountKey = 'shield_count';
  static const String _slowMoCountKey = 'slowmo_count';
  static const String _totalDeathsKey = 'total_deaths';

  Future<StoredProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedSkinStrings =
        prefs.getStringList(_unlockedSkinsKey) ?? <String>['0'];
    final unlockedSkins = unlockedSkinStrings
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    unlockedSkins.add(0);

    return StoredProfile(
      coins: prefs.getInt(_coinsKey) ?? 0,
      bestScore: prefs.getInt(_bestScoreKey) ?? 0,
      selectedSkinId: prefs.getInt(_selectedSkinKey) ?? 0,
      unlockedSkinIds: unlockedSkins,
      soundOn: prefs.getBool(_soundOnKey) ?? true,
      shieldCount: prefs.getInt(_shieldCountKey) ?? 0,
      slowMoCount: prefs.getInt(_slowMoCountKey) ?? 0,
      totalDeaths: prefs.getInt(_totalDeathsKey) ?? 0,
    );
  }

  Future<void> saveProfile(StoredProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, profile.coins);
    await prefs.setInt(_bestScoreKey, profile.bestScore);
    await prefs.setInt(_selectedSkinKey, profile.selectedSkinId);
    await prefs.setStringList(
      _unlockedSkinsKey,
      profile.unlockedSkinIds.map((id) => '$id').toList(),
    );
    await prefs.setBool(_soundOnKey, profile.soundOn);
    await prefs.setInt(_shieldCountKey, profile.shieldCount);
    await prefs.setInt(_slowMoCountKey, profile.slowMoCount);
    await prefs.setInt(_totalDeathsKey, profile.totalDeaths);
  }
}
