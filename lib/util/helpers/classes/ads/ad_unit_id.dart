import 'dart:io';

class AdUnitId {
  static bool isTest = true; // Change this flag to switch between test and real ads

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return isTest
          ? 'ca-app-pub-3940256099942544/9214589741'  // Test Ad Unit for Android
          : 'ca-app-pub-3608052107276973/3779236597'; // Real Ad Unit for Android
    } else if (Platform.isIOS) {
      return isTest
          ? 'your_ios_test_banner_ad_unit_id_here'  // Test Ad Unit for iOS
          : 'your_ios_real_banner_ad_unit_id_here'; // Real Ad Unit for iOS
    } else {
      return 'default_banner_ad_unit_id';
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return isTest
          ? 'ca-app-pub-3940256099942544/1033173712'  // Test Ad Unit for Android
          : 'ca-app-pub-3608052107276973/5369620055'; // Real Ad Unit for Android
    } else if (Platform.isIOS) {
      return isTest
          ? 'your_ios_test_interstitial_ad_unit_id_here'  // Test Ad Unit for iOS
          : 'your_ios_real_interstitial_ad_unit_id_here'; // Real Ad Unit for iOS
    } else {
      return 'default_interstitial_ad_unit_id';
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return isTest
          ? 'ca-app-pub-3940256099942544/5224354917'  // Test Ad Unit for Android
          : 'ca-app-pub-3608052107276973/2522597885'; // Real Ad Unit for Android
    } else if (Platform.isIOS) {
      return isTest
          ? 'your_ios_test_rewarded_ad_unit_id_here'  // Test Ad Unit for iOS
          : 'your_ios_real_rewarded_ad_unit_id_here'; // Real Ad Unit for iOS
    } else {
      return 'default_rewarded_ad_unit_id';
    }
  }

  // Private constructor to prevent instantiation
  AdUnitId._();
}
