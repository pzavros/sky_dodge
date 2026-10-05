import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../game/models/boost.dart';
import '../game/models/skin.dart';
import 'ads_service.dart';
import 'audio_service.dart';
import 'storage_service.dart';

class EconomyConfig {
  static const int revivePrice = 100;
  static const int shieldPrice = 150;
  static const int slowMoPrice = 120;
  static const int interstitialEveryDeaths = 4;
}

class AppState extends ChangeNotifier {
  AppState._({
    required StorageService storage,
    required this.adsService,
    required this.audioService,
  }) : _storage = storage;

  final StorageService _storage;
  final AdsService adsService;
  final AudioService audioService;

  int coins = 0;
  int bestScore = 0;
  int selectedSkinId = 0;
  bool soundOn = true;
  int shieldCount = 0;
  int slowMoCount = 0;
  int totalDeaths = 0;
  final Set<int> _unlockedSkinIds = <int>{0};

  static Future<AppState> create({
    required StorageService storage,
    required AdsService adsService,
    required AudioService audioService,
  }) async {
    final appState = AppState._(
      storage: storage,
      adsService: adsService,
      audioService: audioService,
    );
    await appState._load();
    return appState;
  }

  UnmodifiableSetView<int> get unlockedSkinIds =>
      UnmodifiableSetView(_unlockedSkinIds);

  SkinModel get selectedSkin => SkinCatalog.byId(selectedSkinId);

  bool isSkinUnlocked(int skinId) => _unlockedSkinIds.contains(skinId);

  Future<void> _load() async {
    final profile = await _storage.loadProfile();
    coins = profile.coins;
    bestScore = profile.bestScore;
    selectedSkinId = profile.selectedSkinId;
    soundOn = profile.soundOn;
    shieldCount = profile.shieldCount;
    slowMoCount = profile.slowMoCount;
    totalDeaths = profile.totalDeaths;
    _unlockedSkinIds
      ..clear()
      ..addAll(profile.unlockedSkinIds);

    if (!_unlockedSkinIds.contains(selectedSkinId)) {
      selectedSkinId = 0;
    }
  }

  Future<void> _persist() {
    return _storage.saveProfile(
      StoredProfile(
        coins: coins,
        bestScore: bestScore,
        selectedSkinId: selectedSkinId,
        unlockedSkinIds: _unlockedSkinIds,
        soundOn: soundOn,
        shieldCount: shieldCount,
        slowMoCount: slowMoCount,
        totalDeaths: totalDeaths,
      ),
    );
  }

  Future<void> addCoins(int value) async {
    if (value <= 0) return;
    coins += value;
    await _persist();
    notifyListeners();
  }

  Future<bool> spendCoins(int value) async {
    if (value <= 0) return true;
    if (coins < value) return false;
    coins -= value;
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> updateBestScore(int score) async {
    if (score <= bestScore) return;
    bestScore = score;
    await _persist();
    notifyListeners();
  }

  Future<bool> buySkin(SkinModel skin) async {
    if (_unlockedSkinIds.contains(skin.id)) {
      return selectSkin(skin.id);
    }

    if (coins < skin.price) return false;

    coins -= skin.price;
    _unlockedSkinIds.add(skin.id);
    selectedSkinId = skin.id;
    await _persist();
    notifyListeners();
    return true;
  }

  Future<bool> selectSkin(int skinId) async {
    if (!_unlockedSkinIds.contains(skinId)) return false;
    if (selectedSkinId == skinId) return true;
    selectedSkinId = skinId;
    await _persist();
    notifyListeners();
    return true;
  }

  Future<bool> buyBoost(BoostType boostType) async {
    final price = _boostPrice(boostType);
    if (coins < price) return false;

    coins -= price;
    switch (boostType) {
      case BoostType.shield:
        shieldCount += 1;
      case BoostType.slowMo:
        slowMoCount += 1;
    }

    await _persist();
    notifyListeners();
    return true;
  }

  Future<bool> consumeBoost(BoostType boostType) async {
    switch (boostType) {
      case BoostType.shield:
        if (shieldCount <= 0) return false;
        shieldCount -= 1;
      case BoostType.slowMo:
        if (slowMoCount <= 0) return false;
        slowMoCount -= 1;
    }

    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> toggleSound() async {
    soundOn = !soundOn;
    await _persist();
    notifyListeners();
  }

  Future<void> registerDeath() async {
    totalDeaths += 1;
    await _persist();
    notifyListeners();

    if (totalDeaths % EconomyConfig.interstitialEveryDeaths == 0) {
      await adsService.showInterstitial();
    }
  }

  int _boostPrice(BoostType boostType) {
    switch (boostType) {
      case BoostType.shield:
        return EconomyConfig.shieldPrice;
      case BoostType.slowMo:
        return EconomyConfig.slowMoPrice;
    }
  }
}
