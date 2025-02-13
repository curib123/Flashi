import 'package:flashlearn/presentation/screen/onboarding%20screen/onboarding_screen.dart';
import 'package:flashlearn/presentation/widget/components/custom_drawer.dart';
import 'package:flashlearn/presentation/widget/components/custom_navigation_bar.dart';
import 'package:flashlearn/provider/bottom_navigation_provider.dart';
import 'package:flashlearn/provider/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  @override
  void initState() {
    super.initState();
    initialization();
  }

  initialization() {

    Appodeal.setUseSafeArea(true);

    Appodeal.setAdRevenueCallbacks(onAdRevenueReceive: (adRevenue) {
      print("onAdRevenueReceive: $adRevenue");
    });

    Appodeal.initialize(
      appKey: 'cd4bf368887f70c5a4af7a8dc95fe8147ec011c8dffd3dd9',
      adTypes: [
        AppodealAdType.RewardedVideo,
        AppodealAdType.Interstitial,
        AppodealAdType.Banner,
        AppodealAdType.MREC
      ],
      onInitializationFinished: (errors) {
        errors?.forEach((error) => print(error.description));
        print("onInitializationFinished: errors - ${errors?.length ?? 0}");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BottomNavigationProvider, OnboardingProvider>(
      builder: (context, bottomNavigationProvider, onboardingProvider, child) {
        return Scaffold(
          body: onboardingProvider.isFirstTime
              ? OnboardingScreen()
              : bottomNavigationProvider.getScreen(),
          drawer: onboardingProvider.isFirstTime
              ? null
              : const CustomDrawer(),
          bottomNavigationBar: onboardingProvider.isFirstTime
              ? null
              : CustomNavigationBar(
            currentIndex: bottomNavigationProvider.currentIndex,
            onTap: (index) {
              bottomNavigationProvider.toogleNavigation(index);
            },
          ),
        );
      },
    );
  }
}
