import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';

class StartIoService {
  final StartAppSdk _sdk = StartAppSdk();

  Future<void> configure({required bool testMode}) =>
      _sdk.setTestAdsEnabled(testMode);

  Future<StartAppBannerAd> loadLibraryBanner() => _sdk.loadBannerAd(
        StartAppBannerType.BANNER,
        prefs: const StartAppAdPreferences(adTag: 'flashi_library'),
      );
}

class StartIoBannerSlot extends StatefulWidget {
  final StartIoService service;
  const StartIoBannerSlot({super.key, required this.service});

  @override
  State<StartIoBannerSlot> createState() => _StartIoBannerSlotState();
}

class _StartIoBannerSlotState extends State<StartIoBannerSlot> {
  StartAppBannerAd? _ad;

  @override
  void initState() {
    super.initState();
    widget.service.loadLibraryBanner().then((ad) {
      if (mounted) {
        setState(() => _ad = ad);
      }
    }).catchError((_) {
      // Ads are optional and must never block studying.
    });
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null) return const SizedBox.shrink();
    return Semantics(
      label: 'Advertisement',
      child: Center(child: StartAppBanner(ad)),
    );
  }
}
