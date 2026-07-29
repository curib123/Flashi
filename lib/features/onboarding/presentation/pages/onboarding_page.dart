import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:flashi/features/onboarding/application/onboarding_provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const _animatedTextStyle =
      TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black);
  static const _animatedBodyTextStyle =
      TextStyle(fontSize: 15, color: Colors.grey);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  List<PageViewModel> get pages => [
        PageViewModel(
          title: "Instant Q&A Maker",
          body:
              "Quickly turn PDFs, Docs, and images into questions and answers. Just snap or upload—learn fast.",
          image: Center(
            child: SlideTransition(
              position: _offsetAnimation,
              child: Image.asset("asset/images/onboarding_1.png", height: 300),
            ),
          ),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Smart AI Chatbot",
          body:
              "Get instant help from your AI assistant. Accurate answers, anytime you need them.",
          image: Center(
            child: SlideTransition(
              position: _offsetAnimation,
              child: Image.asset("asset/images/onboarding_2.png", height: 300),
            ),
          ),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Custom Q&A",
          body:
              "Make your own Q&As. Edit, organize, and study at your own pace.",
          image: Center(
            child: SlideTransition(
              position: _offsetAnimation,
              child: Image.asset("asset/images/onboarding_3.jpg", height: 300),
            ),
          ),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Learn Anywhere",
          body: "Study anytime, anywhere. Your Q&As are always with you.",
          image: Center(
            child: SlideTransition(
              position: _offsetAnimation,
              child: Image.asset("asset/images/onboarding_4.jpg", height: 300),
            ),
          ),
          decoration: _pageDecoration(),
        ),
      ];

  PageDecoration _pageDecoration() {
    return PageDecoration(
      titleTextStyle: OnboardingPage._animatedTextStyle,
      bodyTextStyle: OnboardingPage._animatedBodyTextStyle,
      imagePadding: EdgeInsets.only(bottom: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroductionScreen(
        globalBackgroundColor: Colors.white,
        pages: pages,
        onDone: () => _navigateAuth(context),
        onSkip: () => _navigateAuth(context),
        showSkipButton: true,
        skip: Text("Skip", style: TextStyle(color: Colors.black)),
        next: Icon(Icons.arrow_forward, color: Colors.black),
        done: Text("Get Started",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
        dotsDecorator: DotsDecorator(
          size: Size(5, 5),
          color: Colors.grey,
          activeSize: Size(15, 10),
          activeColor: Colors.black,
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  void _navigateAuth(BuildContext context) {
    final onboardingProvider =
        Provider.of<OnboardingProvider>(context, listen: false);
    onboardingProvider.completeOnboarding();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
