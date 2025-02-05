import 'dart:io';

class AdUnitIds {
  // Platform-specific ad unit IDs
  static String get bannerAdUnitId{
    if (Platform.isAndroid) {
      return 'ca-app-pub-3608052107276973/3779236597'; // Test Banner Ad Unit for Android
    } else if (Platform.isIOS) {
      return 'your_ios_banner_ad_unit_id_here'; // Replace with your iOS banner ad unit ID
    } else {
      return 'default_banner_ad_unit_id'; // Default banner ad unit
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3608052107276973/5369620055'; // Test Interstitial Ad Unit for Android
    } else if (Platform.isIOS) {
      return 'your_ios_interstitial_ad_unit_id_here'; // Replace with your iOS interstitial ad unit ID
    } else {
      return 'default_interstitial_ad_unit_id'; // Default interstitial ad unit
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3608052107276973/2522597885'; // Test Rewarded Ad Unit for Android
    } else if (Platform.isIOS) {
      return 'your_ios_rewarded_ad_unit_id_here'; // Replace with your iOS rewarded ad unit ID
    } else {
      return 'default_rewarded_ad_unit_id'; // Default rewarded ad unit
    }
  }

  // Private constructor to prevent instantiation
  AdUnitIds._();
}
