import 'dart:io';

import 'package:flashi/core/config/app_environment.dart';

class AdUnitId {
  static bool isTest = AppEnvironment.useTestAds;
  static bool get isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return isTest
          ? 'ca-app-pub-3940256099942544/9214589741' // Test Ad Unit for Android
          : AppEnvironment.androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return isTest
          ? 'ca-app-pub-3940256099942544/2435281174'
          : AppEnvironment.iosBannerAdUnitId;
    } else {
      return 'default_banner_ad_unit_id';
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return isTest
          ? 'ca-app-pub-3940256099942544/1033173712' // Test Ad Unit for Android
          : AppEnvironment.androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return isTest
          ? 'ca-app-pub-3940256099942544/4411468910'
          : AppEnvironment.iosInterstitialAdUnitId;
    } else {
      return 'default_interstitial_ad_unit_id';
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return isTest
          ? 'ca-app-pub-3940256099942544/5224354917' // Test Ad Unit for Android
          : AppEnvironment.androidRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return isTest
          ? 'ca-app-pub-3940256099942544/1712485313'
          : AppEnvironment.iosRewardedAdUnitId;
    } else {
      return 'default_rewarded_ad_unit_id';
    }
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return isTest
          ? 'ca-app-pub-3940256099942544/9257395921' // Test Ad Unit for Android
          : AppEnvironment.androidAppOpenAdUnitId;
    } else if (Platform.isIOS) {
      return isTest
          ? 'ca-app-pub-3940256099942544/5575463023'
          : AppEnvironment.iosAppOpenAdUnitId;
    } else {
      return 'default_rewarded_ad_unit_id';
    }
  }

  // Private constructor to prevent instantiation
  AdUnitId._();
}
