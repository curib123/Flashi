import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';

class AppLifecycleReactor {
  final AdManager adManager;

  AppLifecycleReactor({required this.adManager});

  void listenToAppStateChanges() {
    // Start.io return ads are intentionally disabled. Study sessions should
    // never be interrupted just because the app returns to the foreground.
  }
}
