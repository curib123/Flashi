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
      body: "Generate Accurate Questions And Answer ! Extract key points from PDFs,Docs ,Images or just captured it to supercharge your learning.",
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
      body: "Study with ease—let the AI assistant chatbot guide you through your learning journey, offering accurate, correct, and tailored support to match your unique style!",
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
      body: "Create your own Q&A tailored to your learning style. Add questions and answer for personalized use.",
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
      body: "Access your flashcards and study on-the-go, wherever you are, just dive into your learning!",
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
