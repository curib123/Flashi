import 'dart:io';

class AdUnitId {
  // Platform-specific ad unit IDs
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/9214589741'; // Test Banner Ad Unit for Android
    } else if (Platform.isIOS) {
      return 'your_ios_banner_ad_unit_id_here'; // Replace with your iOS banner ad unit ID
    } else {
      return 'default_banner_ad_unit_id'; // Default banner ad unit
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Interstitial Ad Unit for Android
    } else if (Platform.isIOS) {
      return 'your_ios_interstitial_ad_unit_id_here'; // Replace with your iOS interstitial ad unit ID
    } else {
      return 'default_interstitial_ad_unit_id'; // Default interstitial ad unit
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test Rewarded Ad Unit for Android
    } else if (Platform.isIOS) {
      return 'your_ios_rewarded_ad_unit_id_here'; // Replace with your iOS rewarded ad unit ID
    } else {
      return 'default_rewarded_ad_unit_id'; // Default rewarded ad unit
    }
  }

  // Private constructor to prevent instantiation
  AdUnitId._();
}