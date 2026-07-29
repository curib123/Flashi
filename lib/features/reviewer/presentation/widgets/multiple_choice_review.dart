import 'dart:math';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/core/ads/ad_unit_id.dart';
import 'package:flashi/shared/widgets/highlighted_text.dart';
import 'package:flutter/material.dart';
import 'package:flashi/features/reviewer/presentation/widgets/multiple_choice_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MultipleChoiceReview extends StatefulWidget {
  final String reviewer;
  final List<dynamic> cards;
  final String setname;

  const MultipleChoiceReview({
    super.key,
    required this.reviewer,
    required this.cards,
    required this.setname,
  });

  @override
  _MultipleChoiceReviewState createState() => _MultipleChoiceReviewState();
}

class _MultipleChoiceReviewState extends State<MultipleChoiceReview> {
  late PageController _pageController;
  final Random _random = Random();
  late List<List<String>> _shuffledOptions;
  int _score = 0;
  AdManager adManager = AdManager();

  @override
  void initState() {
    super.initState();
    adManager.loadInterstitialAd(AdUnitId.interstitialAdUnitId);
    adManager.showInterstitialAd();

    _pageController = PageController();

    _shuffledOptions = widget.cards.map((card) {
      final correctAnswer = card['answer'] as String;
      List<String> incorrectAnswers = widget.cards
          .where((c) => c['answer'] != correctAnswer)
          .map<String>((c) => c['answer'] as String)
          .toList();

      while (incorrectAnswers.length < 3) {
        incorrectAnswers.add("No Answer");
      }

      final options = ([correctAnswer, ...incorrectAnswers.sublist(0, 3)]
        ..shuffle(_random));
      return options;
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onAnswerSelected(String selectedAnswer, String correctAnswer) {
    if (selectedAnswer == correctAnswer) {
      setState(() {
        _score++;
      });
    }

    // Automatically navigate to the next page
    if (_pageController.page?.toInt() == widget.cards.length - 1) {
      // If it's the last question, show congratulations
      showCongratulationDialog(context);
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    }
  }

  void showCongratulationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events, // 🏆 Trophy icon
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .moveY(begin: -20, end: 0, curve: Curves.easeOutBack),
                const SizedBox(height: 15),
                Text(
                  '🎉 Congratulations! 🎉',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 10),
                Text(
                  'You have completed the quiz!',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                const SizedBox(height: 8),
                Text(
                  'Your score is $_score out of ${widget.cards.length}.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        adManager.showInterstitialAd();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      icon:
                          const Icon(Icons.check_circle, size: 18), // ✅ OK icon
                      label: const Text('OK'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ).animate().fadeIn(duration: 700.ms, delay: 300.ms),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        adManager.showInterstitialAd();
                        Navigator.pop(context);
                        restartQuiz();
                      },
                      icon: Icon(
                        Icons.replay,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ), // 🔄 Restart icon
                      label: const Text('Restart'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ).animate().fadeIn(duration: 700.ms, delay: 400.ms),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void restartQuiz() {
    setState(() {
      _score = 0; // Reset score
      _pageController.jumpToPage(0); // Go back to the first question
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Center(
        child: Text("No cards available",
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: widget.cards.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final card = widget.cards[index];
        final correctAnswer = card['answer'] as String;
        final options = _shuffledOptions[index];

        return MultipleChoiceCard(
          timer: 'None', // Removed timer
          totalScore: widget.cards.length.toString(),
          score: _score.toString(),
          question: highlightKeywords(
              context: context,
              keyword: card['keyword'],
              text: card['question'],
              fontSize: 22,
              fontColor: Theme.of(context).colorScheme.onPrimary,
              fontSizeKeyword: 17,
              isCenter: true),
          optionA: options[0],
          optionB: options[1],
          optionC: options[2],
          optionD: options[3],
          answer: correctAnswer,
          onAnswerSelected: (selectedAnswer) {
            onAnswerSelected(selectedAnswer, correctAnswer);
          },
        );
      },
    );
  }
}
