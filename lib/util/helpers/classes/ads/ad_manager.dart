import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() {
    return _instance;
  }

  AdManager._internal(); // Private constructor for singleton

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = Duration(hours: 1);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  BannerAd? _bannerAd1;
  BannerAd? _bannerAd2;
  BannerAd? _bannerAd3;
  BannerAd? _bannerAd4;
  BannerAd? _bannerAd5;
  BannerAd? _bannerAd6;
  BannerAd? _bannerAd7;
  double _bannerHeight = 150;
  bool _isBannerAd1Loaded = false;
  bool _isBannerAd2Loaded = false;
  bool _isBannerAd3Loaded = false;
  bool _isBannerAd4Loaded = false;
  bool _isBannerAd5Loaded = false;
  bool _isBannerAd6Loaded = false;
  bool _isBannerAd7Loaded = false;

  InterstitialAd? _interstitialAd;

  RewardedAd? _rewardedAd;

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  double get bannerHeight => _bannerHeight;

  /// Load an AppOpenAd.
  void loadOpenAppAd(String adUnitId) {
    AppOpenAd.load(
        adUnitId: adUnitId,
        request: AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenLoadTime = DateTime.now();
            _appOpenAd = ad;
          },
          onAdFailedToLoad: (error) {
            print('AppOpenAd failed to load: $error');
            // Handle the error.
          },
        ));
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  void showAdIfAvailable() {
    if (!isAdAvailable) {
      print('Tried to show ad before available.');
      loadOpenAppAd(AdUnitId.appOpenAdUnitId);
      return;
    }

    if (_isShowingAd) {
      print('Tried to show ad while already showing an ad.');
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      print('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadOpenAppAd(AdUnitId.appOpenAdUnitId);
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadOpenAppAd(AdUnitId.appOpenAdUnitId);
      },
    );
  }

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
          _bannerHeight = 150;
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
          _bannerHeight = 150;
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
          _bannerHeight = 150;
          _isBannerAd3Loaded = false;
        },
      ),
    );

    _bannerAd4 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerHeight = 180;
          _isBannerAd4Loaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _bannerHeight = 150;
          _isBannerAd4Loaded = false;
        },
      ),
    );

    _bannerAd5 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerHeight = 180;
          _isBannerAd5Loaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _bannerHeight = 150;
          _isBannerAd5Loaded = false;
        },
      ),
    );
    _bannerAd6 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerHeight = 180;
          _isBannerAd6Loaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _bannerHeight = 150;
          _isBannerAd6Loaded = false;
        },
      ),
    );
    _bannerAd7 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerHeight = 180;
          _isBannerAd7Loaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _bannerHeight = 150;
          _isBannerAd7Loaded = false;
        },
      ),
    );

    _bannerAd1?.load();
    _bannerAd2?.load();
    _bannerAd3?.load();
    _bannerAd4?.load();
    _bannerAd5?.load();
    _bannerAd6?.load();
    _bannerAd7?.load();
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

  Widget getFourthBannerAdWidget() {
    if (_bannerAd4 != null && _isBannerAd4Loaded) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: _bannerAd4!.size.width.toDouble(),
        height: _bannerAd4!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd4!),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget getFifthBannerAdWidget() {
    if (_bannerAd5 != null && _isBannerAd5Loaded) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: _bannerAd5!.size.width.toDouble(),
        height: _bannerAd5!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd5!),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget getSixthBannerAdWidget() {
    if (_bannerAd6 != null && _isBannerAd6Loaded) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: _bannerAd6!.size.width.toDouble(),
        height: _bannerAd6!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd6!),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget getSevenBannerAdWidget() {
    if (_bannerAd7 != null && _isBannerAd7Loaded) {
      return Container(
        width: _bannerAd7!.size.width.toDouble(),
        height: _bannerAd7!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd7!),
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
        adUnitId: adUnitId,
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
        ));
  }

  void showRewarded(BuildContext context, String whatRewards) {
    // Access the QuizProvider and SortProvider from the context
    final aiCreditProvider =
        Provider.of<AiCreditProvider>(context, listen: false);

    _rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      if (whatRewards == "energy") {
        aiCreditProvider.addCredits(5);
        aiCreditProvider.addAdsWatched();
      }
    });
  }

  void dispose() {
    _bannerAd1?.dispose();
    _bannerAd2?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
