import 'package:flashi/presentation/screen/onboarding%20screen/onboarding_screen.dart';
import 'package:flashi/presentation/widget/components/custom_navigation_bar.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/provider/onboarding_provider.dart';
import 'package:flashi/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(themeProvider.fontScale),
      ),
      child: Consumer2<BottomNavigationProvider, OnboardingProvider>(
        builder: (context, navigation, onboarding, child) {
          if (onboarding.isFirstTime) {
            return const OnboardingScreen();
          }

          return Scaffold(
            body: navigation.getScreen(),
            bottomNavigationBar: CustomNavigationBar(
              currentIndex: navigation.currentIndex,
              onTap: navigation.toogleNavigation,
            ),
          );
        },
      ),
    );
  }
}
