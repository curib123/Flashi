import 'dart:async';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/core/ads/ad_unit_id.dart';
import 'package:flashi/shared/widgets/highlighted_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TextInputReview extends StatefulWidget {
  final String reviewer;
  final List<dynamic> cards;
  final String setname;

  const TextInputReview({
    super.key,
    required this.reviewer,
    required this.cards,
    required this.setname,
  });

  @override
  _TextInputReviewState createState() => _TextInputReviewState();
}

class _TextInputReviewState extends State<TextInputReview> {
  late PageController _pageController;
  final TextEditingController _answerController = TextEditingController();
  int _score = 0;
  bool _isWrong = false;
  String _correctAnswerShown = '';
  AdManager adManager = AdManager();

  @override
  void initState() {
    super.initState();
    adManager.loadInterstitialAd(AdUnitId.interstitialAdUnitId);
    adManager.showInterstitialAd();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void onSubmit(String typedAnswer, String correctAnswer) {
    setState(() {
      final isCorrect = typedAnswer.trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase();

      if (isCorrect) {
        if (!_isWrong) {
          // First try is correct
          _score++;
        }
        _isWrong = false;
        _correctAnswerShown = ''; // Clear the correct answer shown
        _answerController.clear();
        // Move to next page immediately if correct
        _goToNextPage();
      } else {
        _isWrong = true;
        _correctAnswerShown = 'Correct answer: $correctAnswer';
        _answerController.clear();
        // Wait for 3 seconds then move to the next page if wrong
        Future.delayed(const Duration(seconds: 3), () {
          _goToNextPage();
        });
      }
    });
  }

  void _goToNextPage() {
    setState(() {
      _correctAnswerShown =
          ''; // Clear the correct answer shown when transitioning
    });

    if (_pageController.page?.toInt() == widget.cards.length - 1) {
      showCongratulationDialog(context);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
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
                Icon(Icons.emoji_events,
                        size: 50, color: Theme.of(context).colorScheme.primary)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .moveY(begin: -20, end: 0, curve: Curves.easeOutBack),
                const SizedBox(height: 15),
                Text(
                  '🎉 Congratulations! 🎉',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 22,
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
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('OK'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ).animate().fadeIn(duration: 700.ms, delay: 300.ms),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        adManager.showInterstitialAd();
                        Navigator.pop(context);
                        restartQuiz();
                      },
                      icon: Icon(Icons.replay,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSecondary),
                      label: const Text('Restart'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
      _score = 0;
      _correctAnswerShown = '';
      _isWrong = false;
      _answerController.clear();
      _pageController.jumpToPage(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.cards.isEmpty) {
      return Center(
        child: Text(
          "No cards available",
          style: TextStyle(color: colorScheme.primary),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: widget.cards.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final card = widget.cards[index];
        final correctAnswer = card['answer'] as String;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Score: $_score / ${widget.cards.length}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.8),
                        colorScheme.primary.withValues(alpha: 0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: highlightKeywords(
                        context: context,
                        keyword: card['keyword'],
                        text: card['question'],
                        fontSize: 22,
                        fontColor: Theme.of(context).colorScheme.onPrimary,
                        fontSizeKeyword: 17,
                        isCenter: true,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _answerController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Type your answer...',
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _isWrong
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
              ),
              if (_isWrong)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: _correctAnswerShown.isNotEmpty
                      ? Text(
                          _correctAnswerShown,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : const SizedBox(),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () =>
                    onSubmit(_answerController.text, correctAnswer),
                icon: const Icon(Icons.send_rounded),
                label: const Text(
                  "Submit",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
