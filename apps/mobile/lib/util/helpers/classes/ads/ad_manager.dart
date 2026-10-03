import 'dart:async';

import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() => _instance;

  AdManager._internal();

  double get bannerHeight => 0;
  bool get isAdAvailable => false;
  bool get isRewardedAdAvailable => true;

  void loadOpenAppAd(String adUnitId) {}

  void showAdIfAvailable() {}

  void loadBannerAd(String id) {}

  Widget getFirstBannerAdWidget() => const SizedBox.shrink();
  Widget getSecondBannerAdWidget() => const SizedBox.shrink();
  Widget getThirdBannerAdWidget() => const SizedBox.shrink();
  Widget getFourthBannerAdWidget() => const SizedBox.shrink();
  Widget getFifthBannerAdWidget() => const SizedBox.shrink();
  Widget getSixthBannerAdWidget() => const SizedBox.shrink();
  Widget getSevenBannerAdWidget() => const SizedBox.shrink();

  void loadInterstitialAd(String adUnitId) {}

  void showInterstitialAd() {}

  Future<bool> loadRewardedAd(String adUnitId) async => true;

  bool showRewarded(BuildContext context, String whatRewards) {
    if (whatRewards != 'energy') return false;

    unawaited(
      context.read<AiCreditProvider>().earnReward(),
    );
    return true;
  }

  void dispose() {}
}
