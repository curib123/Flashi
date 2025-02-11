

import 'dart:async';
import 'dart:math';
import 'package:flashlearn/util/helpers/ads/ad_helper.dart';
import 'package:flashlearn/util/helpers/widget/highlight_keywords.dart';
import 'package:flutter/material.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reviewer_widgets_core/multiple_choice_core.dart';
import 'package:startapp_sdk/startapp.dart';

class MultipleChoiceReviewTimer extends StatefulWidget {
  final String reviewer;
  final List<dynamic> cards;
  final String setname;
  final int timerDuration;

  const MultipleChoiceReviewTimer({
    super.key,
    required this.reviewer,
    required this.cards,
    required this.setname,
    required this.timerDuration,
  });

  @override
  _MultipleChoiceReviewState createState() => _MultipleChoiceReviewState();
}

class _MultipleChoiceReviewState extends State<MultipleChoiceReviewTimer> {
  late PageController _pageController;
  late ValueNotifier<int> _timerNotifier;
  late Timer _timer;
  final Random _random = Random();

  late List<List<String>> _shuffledOptions;
  int _score = 0;

  var startAppSdk = StartAppSdk();

  StartAppInterstitialAd? interstitialAd;

  @override
  void initState() {
    super.initState();
    // TODO make sure to comment out this line before release
   // startAppSdk.setTestAdsEnabled(true);
    startAppSdk.setTestAdsEnabled(AdHelper.isTestEnabled);
    loadInterstitialAd();
    _pageController = PageController();
    _timerNotifier = ValueNotifier<int>(widget.timerDuration);

    _shuffledOptions = widget.cards.map((card) {
      final correctAnswer = card['answer'] as String;
      List<String> incorrectAnswers = widget.cards
          .where((c) => c['answer'] != correctAnswer)
          .map<String>((c) => c['answer'] as String)
          .toList();

      while (incorrectAnswers.length < 3) {
        incorrectAnswers.add("none");
      }

      final options = ([correctAnswer, ...incorrectAnswers.sublist(0, 3)]..shuffle(_random));
      return options;
    }).toList();

    _timer = Timer.periodic(Duration(seconds: 1), (timerTick) {
      if (_timerNotifier.value > 0) {
        _timerNotifier.value--;
      } else {
        int nextPage = _pageController.page?.toInt() ?? 0;
        if (nextPage < widget.cards.length - 1) {
          _pageController.animateToPage(
            nextPage + 1,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        _timer.cancel();
      }
    });
  }

  void loadInterstitialAd() {
    startAppSdk.loadInterstitialAd(prefs: StartAppAdPreferences(adTag: 'timer_multiple_choice')).then((interstitialAd) {
      setState(() {
        this.interstitialAd = interstitialAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Interstitial ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Interstitial ad: $error");
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
    _timer = Timer.periodic(Duration(seconds: 1), (timerTick) {
      if (_timerNotifier.value > 0) {
        _timerNotifier.value--;
      } else {
        int nextPage = _pageController.page?.toInt() ?? 0;
        if (nextPage < widget.cards.length - 1) {
          _pageController.animateToPage(
            nextPage + 1,
            duration: Duration(milliseconds: 300),
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
      showCongratulationPage();

    } else {

      Future.delayed(Duration(seconds: 2), () {
        resetTimer();

        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    }
  }



  void showCongratulationPage() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    showDialog(
      context: context,
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
                fontWeight: FontWeight.bold,
                fontSize: 20
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
              SizedBox(height: 10),
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
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                if (interstitialAd != null) {
                  interstitialAd!.show().then((shown) {
                    if (shown) {
                      setState(() {
                        // NOTE interstitial ad can be shown only once
                        this.interstitialAd = null;

                        // NOTE load again
                        loadInterstitialAd();
                      });
                    }

                    return null;
                  }).onError((error, stackTrace) {
                    debugPrint("Error showing Interstitial ad: $error");
                  });
                }
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: colorScheme.onPrimary
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: colorScheme.onSecondary,
                backgroundColor: colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                if (interstitialAd != null) {
                  interstitialAd!.show().then((shown) {
                    if (shown) {
                      setState(() {
                        // NOTE interstitial ad can be shown only once
                        this.interstitialAd = null;

                        // NOTE load again
                        loadInterstitialAd();
                      });
                    }

                    return null;
                  }).onError((error, stackTrace) {
                    debugPrint("Error showing Interstitial ad: $error");
                  });
                }
                Navigator.pop(context); // Close the dialog
                restartQuiz(); // Restart the quiz
              },
              child: Text(
                'Restart',
                style: TextStyle(
                    color: colorScheme.onPrimary
                ),
              ),
            ),
          ],
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
      _timer = Timer.periodic(Duration(seconds: 1), (timerTick) {
        if (_timerNotifier.value > 0) {
          _timerNotifier.value--;
        } else {
          int nextPage = _pageController.page?.toInt() ?? 0;
          if (nextPage < widget.cards.length - 1) {
            _pageController.animateToPage(
              nextPage + 1,
              duration: Duration(milliseconds: 300),
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
        child: Text("No cards available", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      );
    }

    return ValueListenableBuilder<int>(
      valueListenable: _timerNotifier,
      builder: (context, timerValue, child) {
        return PageView.builder(
          controller: _pageController,
          itemCount: widget.cards.length,
          physics: NeverScrollableScrollPhysics(),
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
            final options  = _shuffledOptions[index];

            return MultipleChoiceCore(
              timer: _timerNotifier.value.toString(),
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
      },
    );
  }
}
