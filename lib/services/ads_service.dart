import 'dart:async';
import 'dart:developer';

abstract class AdsService {
  Future<bool> showRewardedReviveAd();
  Future<void> showInterstitial();
}

class StubAdsService implements AdsService {
  const StubAdsService();

  @override
  Future<bool> showRewardedReviveAd() async {
    // Stub implementation for rewarded ads.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    log('[Ads] Rewarded revive ad simulated: success');
    return true;
  }

  @override
  Future<void> showInterstitial() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    log('[Ads] Interstitial simulated');
  }
}
