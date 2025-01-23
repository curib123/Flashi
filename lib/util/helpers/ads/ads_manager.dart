import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/provider/save_info_ads_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() {
    return _instance;
  }

  AdManager._internal();  // Private constructor for singleton

  BannerAd? _bannerAd1;
  BannerAd? _bannerAd2;
  BannerAd? _bannerAd3;
  double _bannerHeight = 100;
  bool _isBannerAd1Loaded = false;
  bool _isBannerAd2Loaded= false;
  bool _isBannerAd3Loaded= false;

  InterstitialAd? _interstitialAd;

  RewardedAd? _rewardedAd;


double get bannerHeight => _bannerHeight;

  void loadBannerAd(String id) {
    _bannerAd1 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerHeight = 180;
            _isBannerAd1Loaded = true;

        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _bannerHeight = 110;
            _isBannerAd1Loaded = false;

        },
      ),
    );

    _bannerAd2 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerHeight = 180;
            _isBannerAd2Loaded = true;

        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _bannerHeight = 110;
            _isBannerAd2Loaded = false;

        },
      ),
    );

    _bannerAd3 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerHeight = 180;
            _isBannerAd3Loaded = true;

        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _bannerHeight = 110;
            _isBannerAd3Loaded = false;

        },
      ),
    );

    _bannerAd1?.load();
    _bannerAd2?.load();
    _bannerAd3?.load();
  }

  Widget getFirstBannerAdWidget() {
    if (_bannerAd1 != null && _isBannerAd1Loaded) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: _bannerAd1!.size.width.toDouble(),
        height: _bannerAd1!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd1!),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget getSecondBannerAdWidget() {
    if (_bannerAd2 != null && _isBannerAd2Loaded) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: _bannerAd2!.size.width.toDouble(),
        height: _bannerAd2!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd2!),
      );
    } else {
      return SizedBox.shrink();
    }
  }
  Widget getThirdBannerAdWidget() {
    if (_bannerAd3 != null && _isBannerAd3Loaded) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: _bannerAd3!.size.width.toDouble(),
        height: _bannerAd3!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd3!),
      );
    } else {
      return SizedBox.shrink();
    }
  }



  // Preload interstitial ad
  void loadInterstitialAd(String adUnitId) {
    if (_interstitialAd != null) return;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  // Show interstitial ad
  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null; // Dispose of the ad after showing
    }
  }

  /// Loads a rewarded ad.
  void loadRewardedAd(String adUnitId) {

    RewardedAd.load(
        adUnitId: adUnitId ,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _rewardedAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
          },
        )
    );
  }

  void showRewarded(BuildContext context){
    // Access the QuizProvider and SortProvider from the context
    final quizProvider = Provider.of<QuizProvider>(context,listen: false);
    final saveInfoAdsProvider = Provider.of<SaveInfoAdsProvider>(context,listen: false);

    _rewardedAd?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      // Reward the user for watching an ad.
      quizProvider.updateQuizSetLimit();
      saveInfoAdsProvider.incrementAdsWatched();

    });
  }
  void dispose() {
    _bannerAd1?.dispose();
    _bannerAd2?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
