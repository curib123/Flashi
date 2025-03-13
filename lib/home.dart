import 'package:flashi/presentation/screen/onboarding%20screen/onboarding_screen.dart';
import 'package:flashi/presentation/widget/components/custom_drawer.dart';
import 'package:flashi/presentation/widget/components/custom_navigation_bar.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/provider/onboarding_provider.dart';
import 'package:flashi/provider/theme_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    listenToAuthChanges(context);
    // Load Google ads here
    AdManager adManager = AdManager();
    adManager.loadBannerAd(AdUnitId.bannerAdUnitId);
  }



  void listenToAuthChanges(BuildContext context) {

    supabase.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;

      if (session == null) {

      } else {
        // User is signed in
        print("User signed in: ${session.user.id}");
        // Navigate to home screen (optional)
       // quizProvider.updateQuizSets(quizProvider.quizSets,merge: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the theme provider to manage theme-related settings
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(themeProvider.fontScale), // Set text scale to 1.5x
      ),
      child: Consumer2<BottomNavigationProvider, OnboardingProvider>(
        builder: (context, bottomNavigationProvider, onboardingProvider, child) {
          return Scaffold(
            body: onboardingProvider.isFirstTime
                ? OnboardingScreen()
                : bottomNavigationProvider.getScreen(),
            drawer: onboardingProvider.isFirstTime ? null : const CustomDrawer(),
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
