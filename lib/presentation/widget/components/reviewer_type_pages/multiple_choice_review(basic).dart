import 'dart:math';
import 'package:flashi/util/helpers/ads/ad_manager.dart';
import 'package:flashi/util/helpers/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/widget/highlight_keywords.dart';
import 'package:flutter/material.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reviewer_widgets_core/multiple_choice_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MultipleChoiceReviewBasic extends StatefulWidget {
  final String reviewer;
  final List<dynamic> cards;
  final String setname;

  const MultipleChoiceReviewBasic({
    super.key,
    required this.reviewer,
    required this.cards,
    required this.setname,
  });

  @override
  _MultipleChoiceReviewState createState() => _MultipleChoiceReviewState();
}

class _MultipleChoiceReviewState extends State<MultipleChoiceReviewBasic> {
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

      final options = ([correctAnswer, ...incorrectAnswers.sublist(0, 3)]..shuffle(_random));
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
      showCongratulationDialog();
    } else {
      Future.delayed(Duration(seconds: 2), () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    }
  }


  void showCongratulationDialog() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;



    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              '🎉 Congratulations! 🎉',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You have completed the quiz!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your score is $_score out of ${widget.cards.length}.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: colorScheme.onPrimary,
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                  adManager.showInterstitialAd();
                //ads here
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen
              },
              child: const Text('OK'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: colorScheme.onSecondary,
                backgroundColor: colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                adManager.showInterstitialAd();
               //ads here
                Navigator.pop(context); // Close the dialog
                restartQuiz(); // Restart the quiz
              },
              child: const Text('Restart'),
            ),
          ],
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
        child: Text("No cards available", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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

        return MultipleChoiceCore(
          timer: 'None', // Removed timer
          totalScore: widget.cards.length.toString(),
          score: _score.toString(),
          question: highlightKeywords( context: context, keyword:  card['keyword'] , text:  card['question'] , fontSize: 22 , fontColor: Theme.of(context).colorScheme.onPrimary, fontSizeKeyword: 17, isCenter: true),
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
