import 'dart:developer' as developer;

import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/core/ads/ad_unit_id.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_spacing.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() {
    return _instance;
  }

  AdManager._internal(); // Private constructor for singleton

  /// Maximum duration allowed between loading and showing the ad.
  static const Duration maxCacheDuration = Duration(hours: 1);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  BannerAd? _bannerAd1;
  BannerAd? _bannerAd2;
  BannerAd? _bannerAd3;
  BannerAd? _bannerAd4;
  BannerAd? _bannerAd5;
  BannerAd? _bannerAd6;
  BannerAd? _bannerAd7;
  bool _isBannerAd1Loaded = false;
  bool _isBannerAd2Loaded = false;
  bool _isBannerAd3Loaded = false;
  bool _isBannerAd4Loaded = false;
  bool _isBannerAd5Loaded = false;
  bool _isBannerAd6Loaded = false;
  bool _isBannerAd7Loaded = false;

  InterstitialAd? _interstitialAd;
  DateTime? _lastInterstitialShownAt;
  static const Duration interstitialCooldown = Duration(minutes: 3);

  RewardedAd? _rewardedAd;

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Load an AppOpenAd.
  void loadOpenAppAd(String adUnitId) {
    AppOpenAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenLoadTime = DateTime.now();
            _appOpenAd = ad;
          },
          onAdFailedToLoad: (error) {
            developer.log('AppOpenAd failed to load: $error');
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
      developer.log('Tried to show ad before available.');
      loadOpenAppAd(AdUnitId.appOpenAdUnitId);
      return;
    }

    if (_isShowingAd) {
      developer.log('Tried to show ad while already showing an ad.');
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      developer.log('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadOpenAppAd(AdUnitId.appOpenAdUnitId);
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        developer.log('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        developer.log('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadOpenAppAd(AdUnitId.appOpenAdUnitId);
      },
    );
  }

  void loadBannerAds(String id) {
    _bannerAd1 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _isBannerAd1Loaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _isBannerAd1Loaded = false;
        },
      ),
    );

    _bannerAd2 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _isBannerAd2Loaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _isBannerAd2Loaded = false;
        },
      ),
    );

    _bannerAd3 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _isBannerAd3Loaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _isBannerAd3Loaded = false;
        },
      ),
    );

    _bannerAd4 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _isBannerAd4Loaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _isBannerAd4Loaded = false;
        },
      ),
    );

    _bannerAd5 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _isBannerAd5Loaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _isBannerAd5Loaded = false;
        },
      ),
    );
    _bannerAd6 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _isBannerAd6Loaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _isBannerAd6Loaded = false;
        },
      ),
    );
    _bannerAd7 = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _isBannerAd7Loaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
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
    return _bannerWidget(_bannerAd1, _isBannerAd1Loaded);
  }

  Widget getSecondBannerAdWidget() {
    return _bannerWidget(_bannerAd2, _isBannerAd2Loaded);
  }

  Widget getThirdBannerAdWidget() {
    return _bannerWidget(_bannerAd3, _isBannerAd3Loaded);
  }

  Widget getFourthBannerAdWidget() {
    return _bannerWidget(_bannerAd4, _isBannerAd4Loaded);
  }

  Widget getFifthBannerAdWidget() {
    return _bannerWidget(_bannerAd5, _isBannerAd5Loaded);
  }

  Widget getSixthBannerAdWidget() {
    return _bannerWidget(_bannerAd6, _isBannerAd6Loaded);
  }

  Widget getSevenBannerAdWidget() {
    return _bannerWidget(_bannerAd7, _isBannerAd7Loaded);
  }

  Widget _bannerWidget(BannerAd? ad, bool isLoaded) {
    if (ad == null || !isLoaded) return const SizedBox.shrink();
    return Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return Semantics(
          label: 'Sponsored advertisement',
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: AppRadii.medium,
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SPONSORED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          letterSpacing: 1.1,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: ad.size.width.toDouble(),
                  height: ad.size.height.toDouble(),
                  child: AdWidget(ad: ad),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Preload interstitial ad
  void loadInterstitialAd(String adUnitId) {
    if (_interstitialAd != null) return;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          developer.log('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  // Show interstitial ad
  bool showInterstitialAd() {
    final now = DateTime.now();
    final lastShown = _lastInterstitialShownAt;
    if (lastShown != null && now.difference(lastShown) < interstitialCooldown) {
      return false;
    }
    final ad = _interstitialAd;
    if (ad == null) return false;
    _lastInterstitialShownAt = now;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd(AdUnitId.interstitialAdUnitId);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd(AdUnitId.interstitialAdUnitId);
      },
    );
    _interstitialAd = null;
    ad.show();
    return true;
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
    _bannerAd3?.dispose();
    _bannerAd4?.dispose();
    _bannerAd5?.dispose();
    _bannerAd6?.dispose();
    _bannerAd7?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
  }
}
