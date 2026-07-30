import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/core/ads/ad_unit_id.dart';
import 'package:flashi/core/design_system/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('interstitial cooldown allows only properly spaced natural breaks', () {
    final now = DateTime(2026, 1, 1, 12);

    expect(
      AdManager.canShowInterstitial(now: now),
      isTrue,
    );
    expect(
      AdManager.canShowInterstitial(
        now: now,
        lastShownAt: now.subtract(const Duration(minutes: 2)),
      ),
      isFalse,
    );
    expect(
      AdManager.canShowInterstitial(
        now: now,
        lastShownAt: now.subtract(AdManager.interstitialCooldown),
      ),
      isTrue,
    );
  });

  testWidgets('banner slot safely collapses on unsupported platforms',
      (tester) async {
    if (AdUnitId.isSupportedPlatform) return;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: AdBannerSlot(placement: 'test'),
        ),
      ),
    );

    expect(find.byType(AdBannerSlot), findsOneWidget);
    expect(find.byType(SizedBox), findsWidgets);
  });
}
