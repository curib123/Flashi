import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_free_credits_dialog.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:flashi/provider/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  static const _animatedTextStyle = TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal);
  static const _animatedBodyTextStyle = TextStyle(fontSize: 15, color: Colors.teal);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<PageViewModel> pages = [
    PageViewModel(
      title: "AI-Powered Flashcards",
      body: "Generate smart flashcards instantly using AI! Create custom prompts or extract key points from PDFs and Docs to supercharge your learning.",
      image: Center(child: _AnimatedMovingIcon(icon: Icons.auto_awesome_rounded)), // AI-inspired icon
      decoration: PageDecoration(
        titleTextStyle: OnboardingScreen._animatedTextStyle,
        bodyTextStyle: OnboardingScreen._animatedBodyTextStyle,
        imagePadding: EdgeInsets.only(bottom: 16),
      ),
    ),

    PageViewModel(
      title: "AI Assistant Chatbot",
      body: "Study with ease—let the AI assistant chatbot guide you through your learning journey, offering accurate, correct, and tailored support to match your unique style!",
      image: Center(child: _AnimatedMovingIcon(icon: Icons.smart_toy_rounded)),
      decoration: PageDecoration(
        titleTextStyle: OnboardingScreen._animatedTextStyle,
        bodyTextStyle: OnboardingScreen._animatedBodyTextStyle,
        imagePadding: EdgeInsets.only(bottom: 16),
      ),
    ),

    PageViewModel(
      title: "Create & Customize",
      body: "Create your own flashcards tailored to your learning style. Add questions and answer for personalized use",
      image: Center(child: _AnimatedMovingIcon(icon: Icons.create)),
      decoration: PageDecoration(
        titleTextStyle: OnboardingScreen._animatedTextStyle,
        bodyTextStyle: OnboardingScreen._animatedBodyTextStyle,
        imagePadding: EdgeInsets.only(bottom: 16),
      ),
    ),
    PageViewModel(
      title: "Learn Anytime, Anywhere",
      body: "Access your flashcards and study on-the-go, wherever you are, just dive into your learning!",
      image: Center(child: _AnimatedMovingIcon(icon: Icons.mobile_friendly)),
      decoration: PageDecoration(
        titleTextStyle: OnboardingScreen._animatedTextStyle,
        bodyTextStyle: OnboardingScreen._animatedBodyTextStyle,
        imagePadding: EdgeInsets.only(bottom: 16),
      ),
    ),

  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroductionScreen(
        globalBackgroundColor: Colors.white,
        pages: pages,
        onDone: () => _navigateToHome(context),
        onSkip: () => _navigateToHome(context),
        showSkipButton: true,
        skip: Text("Skip", style: TextStyle(color: Colors.teal)),
        next: Icon(Icons.arrow_forward, color: Colors.teal),
        done: Text("Get Started", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal)),
        dotsDecorator: DotsDecorator(
          size: Size(5, 5),
          color: Colors.grey,
          activeSize: Size(15, 10),
          activeColor: Colors.teal,
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    // Complete the onboarding process
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    final aiCreditProvider = Provider.of<AiCreditProvider>(context, listen: false);
    onboardingProvider.completeOnboarding();

    // showFreeCreditsDialog(
    //   context: context,
    //   rewardText: "You have Free ${aiCreditProvider.defaultCredits} credits daily",
    //   onClaim: () async {
    //     // Save other relevant data
    //     await aiCreditProvider.handleDataChange();
    //   },
    // );
  }
}

class _AnimatedMovingIcon extends StatefulWidget {
  final IconData icon;
  const _AnimatedMovingIcon({required this.icon});

  @override
  _AnimatedMovingIconState createState() => _AnimatedMovingIconState();
}

class _AnimatedMovingIconState extends State<_AnimatedMovingIcon> with SingleTickerProviderStateMixin {
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
      begin: Offset(0, -1), // Start position (off-screen at the top)
      end: Offset(0, 0), // End position (center)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward(); // Start the animation immediately
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Icon(widget.icon, size: 250, color: Colors.teal),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller when no longer needed
    super.dispose();
  }
}
