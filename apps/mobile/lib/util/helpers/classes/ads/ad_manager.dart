import 'dart:async';

import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() => _instance;

  AdManager._internal();

  final Duration maxCacheDuration = const Duration(hours: 1);

  DateTime? _appOpenLoadTime;
  AppOpenAd? _appOpenAd;
  bool _isShowingOpenAd = false;
  bool _showOpenWhenLoaded = false;

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
  bool _showInterstitialWhenLoaded = false;

  RewardedAd? _rewardedAd;
  Future<bool>? _rewardedLoadFuture;

  double get bannerHeight => _bannerHeight;
  bool get isAdAvailable => _appOpenAd != null;
  bool get isRewardedAdAvailable => _rewardedAd != null;

  void loadOpenAppAd(String adUnitId) {
    if (_appOpenAd != null) return;

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;

          if (_showOpenWhenLoaded) {
            _showOpenWhenLoaded = false;
            _showOpenAd();
          }
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _appOpenLoadTime = null;
          _showOpenWhenLoaded = false;
          debugPrint('App-open ad failed to load: $error');
        },
      ),
    );
  }

  void showAdIfAvailable() {
    if (_isShowingOpenAd) return;

    if (!isAdAvailable || _appOpenLoadTime == null) {
      _showOpenWhenLoaded = true;
      loadOpenAppAd(AdUnitId.appOpenAdUnitId);
      return;
    }

    final expired = DateTime.now()
        .subtract(maxCacheDuration)
        .isAfter(_appOpenLoadTime!);

    if (expired) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _appOpenLoadTime = null;
      _showOpenWhenLoaded = true;
      loadOpenAppAd(AdUnitId.appOpenAdUnitId);
      return;
    }

    _showOpenAd();
  }

  void _showOpenAd() {
    final ad = _appOpenAd;
    if (ad == null || _isShowingOpenAd) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _isShowingOpenAd = true;
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        debugPrint('App-open ad failed to show: $error');
        _isShowingOpenAd = false;
        failedAd.dispose();
        _appOpenAd = null;
        _appOpenLoadTime = null;
        loadOpenAppAd(AdUnitId.appOpenAdUnitId);
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        _isShowingOpenAd = false;
        dismissedAd.dispose();
        _appOpenAd = null;
        _appOpenLoadTime = null;
        loadOpenAppAd(AdUnitId.appOpenAdUnitId);
      },
    );

    ad.show();
  }

  void loadBannerAd(String id) {
    _disposeBanners();

    BannerAd buildBanner(
      void Function() onLoaded,
      void Function() onFailed,
    ) {
      return BannerAd(
        adUnitId: id,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            _bannerHeight = 180;
            onLoaded();
          },
          onAdFailedToLoad: (ad, error) {
            _bannerHeight = 150;
            onFailed();
            ad.dispose();
            debugPrint('Banner ad failed to load: $error');
          },
        ),
      );
    }

    _bannerAd1 = buildBanner(
      () => _isBannerAd1Loaded = true,
      () => _isBannerAd1Loaded = false,
    );
    _bannerAd2 = buildBanner(
      () => _isBannerAd2Loaded = true,
      () => _isBannerAd2Loaded = false,
    );
    _bannerAd3 = buildBanner(
      () => _isBannerAd3Loaded = true,
      () => _isBannerAd3Loaded = false,
    );
    _bannerAd4 = buildBanner(
      () => _isBannerAd4Loaded = true,
      () => _isBannerAd4Loaded = false,
    );
    _bannerAd5 = buildBanner(
      () => _isBannerAd5Loaded = true,
      () => _isBannerAd5Loaded = false,
    );
    _bannerAd6 = buildBanner(
      () => _isBannerAd6Loaded = true,
      () => _isBannerAd6Loaded = false,
    );
    _bannerAd7 = buildBanner(
      () => _isBannerAd7Loaded = true,
      () => _isBannerAd7Loaded = false,
    );

    _bannerAd1?.load();
    _bannerAd2?.load();
    _bannerAd3?.load();
    _bannerAd4?.load();
    _bannerAd5?.load();
    _bannerAd6?.load();
    _bannerAd7?.load();
  }

  Widget getFirstBannerAdWidget() => _bannerWidget(
        _bannerAd1,
        _isBannerAd1Loaded,
      );

  Widget getSecondBannerAdWidget() => _bannerWidget(
        _bannerAd2,
        _isBannerAd2Loaded,
      );

  Widget getThirdBannerAdWidget() => _bannerWidget(
        _bannerAd3,
        _isBannerAd3Loaded,
      );

  Widget getFourthBannerAdWidget() => _bannerWidget(
        _bannerAd4,
        _isBannerAd4Loaded,
      );

  Widget getFifthBannerAdWidget() => _bannerWidget(
        _bannerAd5,
        _isBannerAd5Loaded,
      );

  Widget getSixthBannerAdWidget() => _bannerWidget(
        _bannerAd6,
        _isBannerAd6Loaded,
      );

  Widget getSevenBannerAdWidget() => _bannerWidget(
        _bannerAd7,
        _isBannerAd7Loaded,
        addMargin: false,
      );

  Widget _bannerWidget(
    BannerAd? ad,
    bool loaded, {
    bool addMargin = true,
  }) {
    if (ad == null || !loaded) return const SizedBox.shrink();

    return Container(
      margin: addMargin
          ? const EdgeInsets.symmetric(vertical: 5)
          : EdgeInsets.zero,
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }

  void loadInterstitialAd(String adUnitId) {
    if (_interstitialAd != null) return;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;

          if (_showInterstitialWhenLoaded) {
            _showInterstitialWhenLoaded = false;
            _showLoadedInterstitial();
          }
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _showInterstitialWhenLoaded = false;
          debugPrint('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      _showInterstitialWhenLoaded = true;
      return;
    }

    _showLoadedInterstitial();
  }

  void _showLoadedInterstitial() {
    final ad = _interstitialAd;
    if (ad == null) return;

    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        debugPrint('Interstitial ad failed to show: $error');
        failedAd.dispose();
      },
    );
    ad.show();
  }

  Future<bool> loadRewardedAd(String adUnitId) {
    if (_rewardedAd != null) return Future<bool>.value(true);
    if (_rewardedLoadFuture != null) return _rewardedLoadFuture!;

    final completer = Completer<bool>();
    _rewardedLoadFuture = completer.future;

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoadFuture = null;
          completer.complete(true);
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _rewardedLoadFuture = null;
          debugPrint('Rewarded ad failed to load: $error');
          completer.complete(false);
        },
      ),
    );

    return completer.future;
  }

  bool showRewarded(BuildContext context, String whatRewards) {
    final ad = _rewardedAd;
    if (ad == null) return false;

    final credits = Provider.of<AiCreditProvider>(
      context,
      listen: false,
    );

    _rewardedAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        debugPrint('Rewarded ad failed to show: $error');
        failedAd.dispose();
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
      },
    );

    ad.show(
      onUserEarnedReward: (_, reward) {
        if (whatRewards == 'energy') {
          credits.addCredits(5);
          credits.addAdsWatched();
        }
      },
    );

    return true;
  }

  void _disposeBanners() {
    _bannerAd1?.dispose();
    _bannerAd2?.dispose();
    _bannerAd3?.dispose();
    _bannerAd4?.dispose();
    _bannerAd5?.dispose();
    _bannerAd6?.dispose();
    _bannerAd7?.dispose();

    _bannerAd1 = null;
    _bannerAd2 = null;
    _bannerAd3 = null;
    _bannerAd4 = null;
    _bannerAd5 = null;
    _bannerAd6 = null;
    _bannerAd7 = null;

    _isBannerAd1Loaded = false;
    _isBannerAd2Loaded = false;
    _isBannerAd3Loaded = false;
    _isBannerAd4Loaded = false;
    _isBannerAd5Loaded = false;
    _isBannerAd6Loaded = false;
    _isBannerAd7Loaded = false;
  }

  void dispose() {
    _disposeBanners();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();

    _interstitialAd = null;
    _rewardedAd = null;
    _appOpenAd = null;
  }
}
