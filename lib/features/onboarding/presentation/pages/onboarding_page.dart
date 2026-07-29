import 'package:flashi/features/onboarding/application/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: IntroductionScreen(
        globalBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        pages: [
          _page(
            title: 'Turn material into quizzes',
            body:
                'Quickly turn PDFs, documents, and images into questions and answers.',
            asset: 'asset/images/onboarding_1.png',
          ),
          _page(
            title: 'Learn with an AI assistant',
            body:
                'Ask questions and get focused help whenever you need another explanation.',
            asset: 'asset/images/onboarding_2.png',
          ),
          _page(
            title: 'Create your own material',
            body: 'Create, edit, and organize questions at your own pace.',
            asset: 'asset/images/onboarding_3.jpg',
          ),
          _page(
            title: 'Learn anywhere',
            body:
                'Your quizzes and notes stay ready whenever you want to study.',
            asset: 'asset/images/onboarding_4.jpg',
          ),
        ],
        onDone: _completeOnboarding,
        onSkip: _completeOnboarding,
        showSkipButton: true,
        skip: const Text('Skip'),
        next: const Icon(Icons.arrow_forward),
        done: const Text(
          'Get started',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        dotsDecorator: DotsDecorator(
          size: const Size(6, 6),
          color: colors.outline,
          activeSize: const Size(22, 8),
          activeColor: colors.primary,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }

  PageViewModel _page({
    required String title,
    required String body,
    required String asset,
  }) {
    final theme = Theme.of(context);
    return PageViewModel(
      title: title,
      body: body,
      image: Center(
        child: SlideTransition(
          position: _offsetAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(asset, height: 280, fit: BoxFit.contain),
          ),
        ),
      ),
      decoration: PageDecoration(
        titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w700,
        ),
        bodyTextStyle: theme.textTheme.bodyLarge!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        pageColor: theme.scaffoldBackgroundColor,
        imagePadding: const EdgeInsets.only(bottom: 24),
        contentMargin: const EdgeInsets.symmetric(horizontal: 24),
        imageFlex: 3,
        bodyFlex: 2,
      ),
    );
  }

  void _completeOnboarding() {
    context.read<OnboardingProvider>().completeOnboarding();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
