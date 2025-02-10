import 'package:flashlearn/presentation/screen/onboarding%20screen/onboarding_screen.dart';
import 'package:flashlearn/presentation/widget/components/custom_drawer.dart';
import 'package:flashlearn/presentation/widget/components/custom_navigation_bar.dart';
import 'package:flashlearn/provider/bottom_navigation_provider.dart';
import 'package:flashlearn/provider/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  @override
  void initState() {
    super.initState();
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
