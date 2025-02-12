import 'package:flutter/material.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class PersistentBannerAd extends StatefulWidget {
  final String placement; // Allow nullable placement

  const PersistentBannerAd({super.key, required this.placement});

  @override
  _PersistentBannerAdState createState() => _PersistentBannerAdState();
}

class _PersistentBannerAdState extends State<PersistentBannerAd> {

  @override
  void initState() {
    super.initState();
    Appodeal.setBannerCallbacks(
      onBannerLoaded: (isPrecache) {

      },
      onBannerFailedToLoad: () {

      },
      onBannerExpired: () {

      },
    );


  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: true,
      child:  AppodealBanner(
        adSize: AppodealBannerSize.BANNER,
        placement: widget.placement,// Ensure correct case
      ),
    );
  }
}
