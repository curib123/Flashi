import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/widget/other/highlight_keywords.dart';
import 'package:flutter/material.dart';
import 'package:dart_levenshtein/dart_levenshtein.dart';

class TextInputReviewBasic extends StatefulWidget {
  final String reviewer;
  final List<dynamic> cards;
  final String setname;

  const TextInputReviewBasic({
    super.key,
    required this.reviewer,
    required this.cards,
    required this.setname,
  });

  @override
  _TextInputReviewState createState() => _TextInputReviewState();
}

class _TextInputReviewState extends State<TextInputReviewBasic> {
  late PageController _pageController;
  int _score = 0;
  final TextEditingController _answerController = TextEditingController();
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

  void onAnswerSubmitted(String userAnswer, String correctAnswer) async {
    String normalizedUserAnswer =
    userAnswer.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
    String normalizedCorrectAnswer =
    correctAnswer.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

    if (normalizedUserAnswer == normalizedCorrectAnswer) {
      setState(() {
        _score++;
      });
    } else {
      int distance = await normalizedUserAnswer.levenshteinDistance(
          normalizedCorrectAnswer);

      if (distance <= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Close! Did you mean: $correctAnswer?"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    _answerController.clear();

    if (_pageController.page?.toInt() == widget.cards.length - 1) {
      showCongratulationDialog();
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    }
  }


  void showCongratulationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              '🎉 Congratulations! 🎉',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
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
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your score is $_score out of ${widget.cards.length}.',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .secondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                adManager.showInterstitialAd();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                adManager.showInterstitialAd();
                Navigator.pop(context);
                restartQuiz();
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
      _score = 0;
      _pageController.jumpToPage(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Center(
        child: Text(
          "No cards available",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme
                .of(context)
                .colorScheme
                .primary,
          ),
        ),
      );
    }

    return SafeArea(
      child: Center(
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width , // Adjust width for responsiveness
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center, // Ensure proper centering
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 400, // Ensure visible height
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.cards.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final card = widget.cards[index];
                      final correctAnswer = card['answer'] as String;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 30, horizontal: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme
                                      .of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.7),
                                  Theme
                                      .of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: highlightKeywords(
                              context: context,
                              keyword: card['keyword'],
                              text: card['question'],
                              fontSize: 20,
                              fontColor: Theme
                                  .of(context)
                                  .colorScheme
                                  .onPrimary,
                              fontSizeKeyword: 17,
                              isCenter: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _answerController,
                                    style: const TextStyle(fontSize: 16),
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.6),
                                      ),
                                      hintText: "Type your answer...",
                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          horizontal: 16, vertical: 14),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    onAnswerSubmitted(
                                        _answerController.text, correctAnswer);
                                  },
                                  icon: Icon(Icons.send, color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme
                            .of(context)
                            .colorScheme
                            .secondary,
                        Theme
                            .of(context)
                            .colorScheme
                            .primary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "$_score",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}