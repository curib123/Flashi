abstract final class AppEnvironment {
  static const mistralApiKey = String.fromEnvironment(
    'MISTRAL_API_KEY',
    defaultValue: '',
  );
  static const mistralApiUrl = String.fromEnvironment(
    'MISTRAL_API_URL',
    defaultValue: 'https://api.mistral.ai/v1/chat/completions',
  );
  static const releaseConfigUrl = String.fromEnvironment(
    'RELEASE_CONFIG_URL',
    defaultValue: 'https://curib123.github.io/flashi_/flashi.json',
  );
  static const triviaApiUrl = String.fromEnvironment(
    'TRIVIA_API_URL',
    defaultValue: 'https://the-trivia-api.com/api/questions?limit=30',
  );
  static const privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://curib123.github.io/flashi_/privacy_policy.html',
  );
  static const termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://curib123.github.io/flashi_/terms%26condition.html',
  );

  static const useTestAds = bool.fromEnvironment(
    'USE_TEST_ADS',
    defaultValue: true,
  );
  static const androidBannerAdUnitId = String.fromEnvironment(
    'ANDROID_BANNER_AD_UNIT_ID',
    defaultValue: '',
  );
  static const androidInterstitialAdUnitId = String.fromEnvironment(
    'ANDROID_INTERSTITIAL_AD_UNIT_ID',
    defaultValue: '',
  );
  static const androidRewardedAdUnitId = String.fromEnvironment(
    'ANDROID_REWARDED_AD_UNIT_ID',
    defaultValue: '',
  );
  static const androidAppOpenAdUnitId = String.fromEnvironment(
    'ANDROID_APP_OPEN_AD_UNIT_ID',
    defaultValue: '',
  );
  static const iosBannerAdUnitId = String.fromEnvironment(
    'IOS_BANNER_AD_UNIT_ID',
    defaultValue: '',
  );
  static const iosInterstitialAdUnitId = String.fromEnvironment(
    'IOS_INTERSTITIAL_AD_UNIT_ID',
    defaultValue: '',
  );
  static const iosRewardedAdUnitId = String.fromEnvironment(
    'IOS_REWARDED_AD_UNIT_ID',
    defaultValue: '',
  );
  static const iosAppOpenAdUnitId = String.fromEnvironment(
    'IOS_APP_OPEN_AD_UNIT_ID',
    defaultValue: '',
  );
}
