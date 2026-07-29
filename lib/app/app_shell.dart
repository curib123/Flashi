import 'package:flashi/app/widgets/app_bottom_navigation.dart';
import 'package:flashi/app/widgets/app_mobile_drawer.dart';
import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/provider/onboarding_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/theme_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  static void openNavigation() {
    scaffoldKey.currentState?.openDrawer();
  }

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
    final themeProvider = context.watch<ThemeProvider>();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
            themeProvider.fontScale), // Set text scale to 1.5x
      ),
      child:
          Consumer3<BottomNavigationProvider, OnboardingProvider, QuizProvider>(
        builder: (context, navigation, onboarding, quiz, child) {
          if (onboarding.isFirstTime) {
            return const Scaffold(body: OnboardingPage());
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final showSidebar = constraints.maxWidth >= AppBreakpoints.medium;
              final extendSidebar =
                  constraints.maxWidth >= AppBreakpoints.expanded;

              if (showSidebar) {
                return Scaffold(
                  body: Row(
                    children: [
                      AppSideNavigation(
                        selectedIndex: navigation.currentIndex,
                        onDestinationSelected: navigation.toogleNavigation,
                        quizProvider: quiz,
                        extended: extendSidebar,
                      ),
                      Expanded(child: navigation.getScreen()),
                    ],
                  ),
                );
              }

              return Scaffold(
                key: AppShell.scaffoldKey,
                body: navigation.getScreen(),
                drawer: const AppMobileDrawer(),
                bottomNavigationBar: AppBottomNavigation(
                  currentIndex: navigation.currentIndex,
                  onDestinationSelected: navigation.toogleNavigation,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
