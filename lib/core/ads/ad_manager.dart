import 'dart:developer' as developer;

import 'package:flashi/core/ads/ad_unit_id.dart';
import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class AdManager {
  factory AdManager() => _instance;

  AdManager._internal();

  static final AdManager _instance = AdManager._internal();

  static const Duration interstitialCooldown = Duration(minutes: 3);

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  DateTime? _lastInterstitialShownAt;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;
  bool _isShowingFullScreenAd = false;

  bool get isRewardedReady => _rewardedAd != null;

  static bool canShowInterstitial({
    required DateTime now,
    DateTime? lastShownAt,
  }) {
    return lastShownAt == null ||
        now.difference(lastShownAt) >= interstitialCooldown;
  }

  Widget getFirstBannerAdWidget() =>
      const AdBannerSlot(placement: 'dashboard-library');

  Widget getSecondBannerAdWidget() =>
      const AdBannerSlot(placement: 'favorites-library');

  Widget getThirdBannerAdWidget() =>
      const AdBannerSlot(placement: 'notes-library');

  Widget getFourthBannerAdWidget() => const AdBannerSlot(placement: 'reserved');

  Widget getFifthBannerAdWidget() =>
      const AdBannerSlot(placement: 'quiz-library');

  Widget getSixthBannerAdWidget() =>
      const AdBannerSlot(placement: 'quiz-cards');

  Widget getSevenBannerAdWidget() =>
      const AdBannerSlot(placement: 'generation-history');

  void loadInterstitialAd([String? adUnitId]) {
    if (!AdUnitId.isSupportedPlatform ||
        _interstitialAd != null ||
        _isInterstitialLoading) {
      return;
    }
    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: adUnitId ?? AdUnitId.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isInterstitialLoading = false;
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          developer.log('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  bool showInterstitialAd() {
    final now = DateTime.now();
    if (_isShowingFullScreenAd ||
        !canShowInterstitial(
          now: now,
          lastShownAt: _lastInterstitialShownAt,
        )) {
      return false;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      loadInterstitialAd();
      return false;
    }

    _interstitialAd = null;
    _isShowingFullScreenAd = true;
    _lastInterstitialShownAt = now;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: _finishInterstitial,
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log('Interstitial ad failed to show: $error');
        _finishInterstitial(ad);
      },
    );
    ad.show();
    return true;
  }

  void _finishInterstitial(InterstitialAd ad) {
    ad.dispose();
    _isShowingFullScreenAd = false;
    loadInterstitialAd();
  }

  void loadRewardedAd([String? adUnitId]) {
    if (!AdUnitId.isSupportedPlatform ||
        _rewardedAd != null ||
        _isRewardedLoading) {
      return;
    }
    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: adUnitId ?? AdUnitId.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isRewardedLoading = false;
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          developer.log('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  bool showRewarded(BuildContext context, String rewardType) {
    if (_isShowingFullScreenAd) return false;
    final ad = _rewardedAd;
    if (ad == null) {
      loadRewardedAd();
      return false;
    }

    _rewardedAd = null;
    _isShowingFullScreenAd = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: _finishRewarded,
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log('Rewarded ad failed to show: $error');
        _finishRewarded(ad);
      },
    );
    ad.show(
      onUserEarnedReward: (ad, reward) {
        if (rewardType != 'energy' || !context.mounted) return;
        final credits = context.read<AiCreditProvider>();
        credits.addCredits(5);
        credits.addAdsWatched();
      },
    );
    return true;
  }

  void showRewardedOrNotify(BuildContext context, String rewardType) {
    if (showRewarded(context, rewardType)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text('The reward ad is still loading. Try again shortly.'),
            ),
          ],
        ),
      ),
    );
  }

  void _finishRewarded(RewardedAd ad) {
    ad.dispose();
    _isShowingFullScreenAd = false;
    loadRewardedAd();
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }
}

class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({
    required this.placement,
    super.key,
  });

  final String placement;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? _ad;
  int? _requestedWidth;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (!AdUnitId.isSupportedPlatform) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.floor().clamp(320, 1200);
        if (_requestedWidth != width && !_isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _load(width));
        }
        final ad = _ad;
        if (ad == null) return const SizedBox.shrink();

        final colors = Theme.of(context).colorScheme;
        return Semantics(
          label: 'Sponsored advertisement',
          container: true,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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

  Future<void> _load(int width) async {
    if (!mounted || _isLoading || _requestedWidth == width) return;
    _isLoading = true;
    _requestedWidth = width;
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) {
      _isLoading = false;
      return;
    }

    final previous = _ad;
    final ad = BannerAd(
      adUnitId: AdUnitId.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted) {
            loadedAd.dispose();
            return;
          }
          previous?.dispose();
          setState(() {
            _ad = loadedAd as BannerAd;
            _isLoading = false;
          });
        },
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();
          developer.log(
            'Banner ${widget.placement} failed to load: $error',
          );
          if (mounted) setState(() => _isLoading = false);
        },
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }
}
