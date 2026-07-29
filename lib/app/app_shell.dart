import 'package:flashi/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flashi/presentation/widget/components/custom_drawer.dart';
import 'package:flashi/presentation/widget/components/custom_navigation_bar.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/provider/onboarding_provider.dart';
import 'package:flashi/provider/theme_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    // Load Google ads here
    AdManager adManager = AdManager();
    adManager.loadBannerAd(AdUnitId.bannerAdUnitId);
  }

  @override
  Widget build(BuildContext context) {
    // Access the theme provider to manage theme-related settings
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
            themeProvider.fontScale), // Set text scale to 1.5x
      ),
      child: Consumer2<BottomNavigationProvider, OnboardingProvider>(
        builder:
            (context, bottomNavigationProvider, onboardingProvider, child) {
          return Scaffold(
            body: onboardingProvider.isFirstTime
                ? const OnboardingPage()
                : bottomNavigationProvider.getScreen(),
            drawer:
                onboardingProvider.isFirstTime ? null : const CustomDrawer(),
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
      ),
    );
  }
}
