import 'dart:async';
import 'dart:math';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/features/reviewer/domain/quiz_choice_builder.dart';
import 'package:flashi/shared/widgets/highlighted_text.dart';
import 'package:flutter/material.dart';
import 'package:flashi/features/reviewer/presentation/widgets/multiple_choice_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimedMultipleChoiceReview extends StatefulWidget {
  final String reviewer;
  final List<dynamic> cards;
  final String setname;
  final int timerDuration;

  const TimedMultipleChoiceReview({
    super.key,
    required this.reviewer,
    required this.cards,
    required this.setname,
    required this.timerDuration,
  });

  @override
  State<TimedMultipleChoiceReview> createState() =>
      _MultipleChoiceReviewState();
}

class _MultipleChoiceReviewState extends State<TimedMultipleChoiceReview> {
  late PageController _pageController;
  late ValueNotifier<int> _timerNotifier;
  late Timer _timer;
  final Random _random = Random();

  late List<List<String>> _shuffledOptions;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timerNotifier = ValueNotifier<int>(widget.timerDuration);

    _shuffledOptions = widget.cards
        .map<List<String>>(
          (card) => QuizChoiceBuilder.build(
            card: card as Map<dynamic, dynamic>,
            cards: widget.cards,
            random: _random,
          ),
        )
        .toList();

    _timer = Timer.periodic(const Duration(seconds: 1), (timerTick) {
      if (_timerNotifier.value > 0) {
        _timerNotifier.value--;
      } else {
        int nextPage = _pageController.page?.toInt() ?? 0;
        if (nextPage < widget.cards.length - 1) {
          _pageController.animateToPage(
            nextPage + 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _timerNotifier.dispose();
    super.dispose();
  }

  void resetTimer() {
    _timer.cancel();
    _timerNotifier.value = widget.timerDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timerTick) {
      if (_timerNotifier.value > 0) {
        _timerNotifier.value--;
      } else {
        int nextPage = _pageController.page?.toInt() ?? 0;
        if (nextPage < widget.cards.length - 1) {
          _pageController.animateToPage(
            nextPage + 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        _timer.cancel();
      }
    });
  }

  // void stopTimer() {
  //   if (_timer.isActive) {
  //     _timer.cancel();
  //   }
  // }
  //
  // void resumeTimer() {
  //   if (!_timer.isActive) {
  //     _timer = Timer.periodic(Duration(seconds: 1), (timerTick) {
  //       if (_timerNotifier.value > 0) {
  //         _timerNotifier.value--;
  //       } else {
  //         int nextPage = _pageController.page?.toInt() ?? 0;
  //         if (nextPage < widget.cards.length - 1) {
  //           _pageController.animateToPage(
  //             nextPage + 1,
  //             duration: Duration(milliseconds: 300),
  //             curve: Curves.easeInOut,
  //           );
  //         }
  //         _timer.cancel();
  //       }
  //     });
  //   }
  // }

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
        resetTimer();

        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    }
  }

  void showCongratulationDialog(BuildContext context) {
    AdManager adManager = AdManager();
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
      _timerNotifier.value = widget.timerDuration; // Reset timer
      _pageController.jumpToPage(0); // Go back to the first question
      _timer.cancel(); // Stop the current timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timerTick) {
        if (_timerNotifier.value > 0) {
          _timerNotifier.value--;
        } else {
          int nextPage = _pageController.page?.toInt() ?? 0;
          if (nextPage < widget.cards.length - 1) {
            _pageController.animateToPage(
              nextPage + 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          _timer.cancel();
        }
      });
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

    return ValueListenableBuilder<int>(
      valueListenable: _timerNotifier,
      builder: (context, timerValue, child) {
        return PageView.builder(
          controller: _pageController,
          itemCount: widget.cards.length,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            if (_timerNotifier.value > 0) {
              _pageController.jumpToPage(index);
            } else {
              resetTimer();
            }
          },
          itemBuilder: (context, index) {
            final card = widget.cards[index];
            final correctAnswer = card['answer'] as String;
            final options = _shuffledOptions[index];

            return MultipleChoiceCard(
              timer: _timerNotifier.value.toString(),
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
      },
    );
  }
}
