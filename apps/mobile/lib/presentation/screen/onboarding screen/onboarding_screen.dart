import 'package:flashi/provider/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final decoration = PageDecoration(
      pageColor: Theme.of(context).scaffoldBackgroundColor,
      titleTextStyle: textTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.w900,
        color: colors.onSurface,
      ),
      bodyTextStyle: textTheme.bodyLarge!.copyWith(
        height: 1.45,
        color: colors.onSurface.withOpacity(0.65),
      ),
      imagePadding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      contentMargin: const EdgeInsets.symmetric(horizontal: 24),
    );

    return IntroductionScreen(
      globalBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      pages: [
        PageViewModel(
          title: 'Create study sets your way',
          body:
              'Build flashcards manually offline, or generate them from a topic, PDF, document, or notes image.',
          image: _OnboardingVisual(
            icon: Icons.add_card_rounded,
            colors: colors,
          ),
          decoration: decoration,
        ),
        PageViewModel(
          title: 'Practice in the format you need',
          body:
              'Use multiple choice, identification, true or false, definition, fill-in-the-blank, enumeration, and flashcard review.',
          image: _OnboardingVisual(
            icon: Icons.quiz_outlined,
            colors: colors,
          ),
          decoration: decoration,
        ),
        PageViewModel(
          title: 'Keep studying offline',
          body:
              'AI generation needs Google sign-in and internet, but generated study sets are saved locally for offline review.',
          image: _OnboardingVisual(
            icon: Icons.offline_bolt_outlined,
            colors: colors,
          ),
          decoration: decoration,
        ),
      ],
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward_rounded),
      done: const Text(
        'Get started',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      onSkip: () => _complete(context),
      onDone: () => _complete(context),
      dotsDecorator: DotsDecorator(
        size: const Size(7, 7),
        activeSize: const Size(22, 8),
        color: colors.outline.withOpacity(0.3),
        activeColor: colors.primary,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }

  void _complete(BuildContext context) {
    context.read<OnboardingProvider>().completeOnboarding();
  }
}

class _OnboardingVisual extends StatelessWidget {
  final IconData icon;
  final ColorScheme colors;

  const _OnboardingVisual({
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 210,
        height: 210,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(56),
        ),
        child: Center(
          child: Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(34),
            ),
            child: Icon(icon, color: colors.onPrimary, size: 52),
          ),
        ),
      ),
    );
  }
}
