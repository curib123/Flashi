import 'dart:async';

import 'package:startapp_sdk/startapp.dart';

class StartIoService {
  final StartAppSdk _sdk = StartAppSdk();

  Future<void> configure({required bool testMode}) async {
    await _sdk.setTestAdsEnabled(testMode);
  }

  Future<bool> showRewarded({
    required Future<void> Function() onReward,
  }) async {
    final completion = Completer<bool>();
    var rewardCompleted = false;
    StartAppRewardedVideoAd? loadedAd;

    try {
      loadedAd = await _sdk.loadRewardedVideoAd(
        prefs: const StartAppAdPreferences(adTag: 'flashi_energy_reward'),
        onAdNotDisplayed: () {
          loadedAd?.dispose();
          loadedAd = null;
          if (!completion.isCompleted) completion.complete(false);
        },
        onAdHidden: () {
          loadedAd?.dispose();
          loadedAd = null;
          if (!rewardCompleted && !completion.isCompleted) {
            completion.complete(false);
          }
        },
        onVideoCompleted: () {
          rewardCompleted = true;
          Future<void>.sync(onReward).then((_) {
            if (!completion.isCompleted) completion.complete(true);
          }).catchError((_) {
            if (!completion.isCompleted) completion.complete(false);
          });
        },
      );

      final shown = await loadedAd.show();
      if (!shown && !completion.isCompleted) {
        loadedAd.dispose();
        loadedAd = null;
        completion.complete(false);
      }

      return completion.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          loadedAd?.dispose();
          loadedAd = null;
          return false;
        },
      );
    } catch (_) {
      loadedAd?.dispose();
      return false;
    }
  }
}
