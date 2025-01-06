import 'package:flashlearn/provider/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatelessWidget {
  final List<PageViewModel> pages = [
    PageViewModel(
      title: "Welcome to FlashLearn",
      body: "The ultimate flashcard app for mastering any subject!",
      image: Center(child: Icon(Icons.school, size: 100, color: Colors.teal)),
      decoration: PageDecoration(
        titleTextStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
        bodyTextStyle: TextStyle(fontSize: 18, color: Colors.teal.shade400),
        imagePadding: EdgeInsets.only(bottom: 16),

      ),
    ),
    PageViewModel(
      title: "Create & Customize",
      body: "Easily create and customize your own flashcards.",
      image: Center(child: Icon(Icons.create, size: 100, color: Colors.teal)),
      decoration: PageDecoration(
        titleTextStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
        bodyTextStyle: TextStyle(fontSize: 18, color: Colors.teal.shade400),
        imagePadding: EdgeInsets.only(bottom: 16),

      ),
    ),
    PageViewModel(
      title: "Learn Anytime, Anywhere",
      body: "Study on the go and memorize anytime anywhere.",
      image: Center(child: Icon(Icons.mobile_friendly, size: 100, color: Colors.teal)),
      decoration: PageDecoration(
        titleTextStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
        bodyTextStyle: TextStyle(fontSize: 18, color: Colors.teal.shade400),
        imagePadding: EdgeInsets.only(bottom: 16),

      ),
    ),
    PageViewModel(
      title: "Notes Section",
      body: "Keep track of important notes to enhance your learning experience.",
      image: Center(child: Icon(Icons.note, size: 100, color: Colors.teal)),
      decoration: PageDecoration(
        titleTextStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
        bodyTextStyle: TextStyle(fontSize: 18, color: Colors.teal.shade400),
        imagePadding: EdgeInsets.only(bottom: 16),

      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroductionScreen(
        globalBackgroundColor: Colors.teal.shade50,
        pages: pages,
        onDone: () => _navigateToHome(context),
        onSkip: () => _navigateToHome(context),
        showSkipButton: true,
        skip: Text("Skip", style: TextStyle(color: Colors.teal)),
        next: Icon(Icons.arrow_forward, color: Colors.teal),
        done: Text("Get Started", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal)),
        dotsDecorator: DotsDecorator(
          size: Size(10, 10),
          color: Colors.grey,
          activeSize: Size(20, 10),
          activeColor: Colors.teal,
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    // Complete the onboarding process
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    onboardingProvider.completeOnboarding();

  }
}
