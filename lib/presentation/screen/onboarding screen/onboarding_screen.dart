import 'package:flashi/presentation/screen/authentication/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:flashi/provider/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  static const _animatedTextStyle = TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black);
  static const _animatedBodyTextStyle = TextStyle(fontSize: 15, color: Colors.grey);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
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
      title: "Instant Question And Answer Maker",
      body: "Turn any content into powerful questions and answers—PDFs, Docs, Images, or snaps. Your learning, elevated instantly!",
      image: Center(
        child: SlideTransition(
          position: _offsetAnimation,
          child: Image.asset("asset/images/onboarding_1.png", height: 350),
        ),
      ),
      decoration: _pageDecoration(),
    ),
    PageViewModel(
      title: "AI Assistant Chatbot",
      body: "Study smarter, not harder—with an AI assistant built just for you. Get accurate, adaptive support anytime you need it.",
      image: Center(
        child: SlideTransition(
          position: _offsetAnimation,
          child: Image.asset("asset/images/onboarding_2.png", height: 350),
        ),
      ),
      decoration: _pageDecoration(),
    ),
    PageViewModel(
      title: "Create & Customize",
      body: "Shape your learning—craft personalized Q&As that match your pace and style. Build, edit, and master your own material.",
      image: Center(
        child: SlideTransition(
          position: _offsetAnimation,
          child: Image.asset("asset/images/onboarding_3.jpg", height: 350),
        ),
      ),
      decoration: _pageDecoration(),
    ),
    PageViewModel(
      title: "Learn Anytime, Anywhere",
      body: "Wherever life takes you, your knowledge goes too. Study on the move with your flashcards always at hand.",
      image: Center(
        child: SlideTransition(
          position: _offsetAnimation,
          child: Image.asset("asset/images/onboarding_4.jpg", height: 350),
        ),
      ),
      decoration: _pageDecoration(),
    ),
  ];


  PageDecoration _pageDecoration() {
    return PageDecoration(
      titleTextStyle: OnboardingScreen._animatedTextStyle,
      bodyTextStyle: OnboardingScreen._animatedBodyTextStyle,
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
        done: Text("Get Started", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
        dotsDecorator: DotsDecorator(
          size: Size(5, 5),
          color: Colors.grey,
          activeSize: Size(15, 10),
          activeColor: Colors.black,
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  void _navigateAuth(BuildContext context) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );

    final onboardingProvider = Provider.of<OnboardingProvider>(context,listen: false);
    onboardingProvider.completeOnboarding();


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
