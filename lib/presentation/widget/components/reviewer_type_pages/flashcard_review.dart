import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reviewer_widgets_core/flip_card_core.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/reviewer_settings_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/widget/modals/create_card_bottom_modal.dart';
import 'package:flashi/util/helpers/widget/other/highlight_keywords.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlashcardReview extends StatefulWidget {
  final String reviewer;
  final List<dynamic> cards;
  final String setname;

  const FlashcardReview({super.key, required this.reviewer, required this.cards, required this.setname});

  @override
  _FlashcardReviewState createState() => _FlashcardReviewState();
}

class _FlashcardReviewState extends State<FlashcardReview> {
  late PageController _pageController;
  int _currentPage = 0;
AdManager adManager = AdManager();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(minutes: 3),(){
      adManager.loadInterstitialAd(AdUnitId.interstitialAdUnitId);
    });

    adManager.showInterstitialAd();
    _pageController = PageController();

  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access both providers directly
    final quizProvider = Provider.of<QuizProvider>(context);
    final reviewerSettingsProvider = Provider.of<ReviewerSettingsProvider>(context);


    if (widget.cards.isEmpty) {
      return Center(
        child: Text("No cards available", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      );
    }

    //ads here


    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // PageView wrapped in an Expanded widget to avoid overflow
          Expanded(
            child: SizedBox(
              width: double.infinity, // Full width
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.cards.length,
                itemBuilder: (context, index) {
                  // Ensure the card is cast to the correct type
                  Map<String, dynamic> card = Map<String, dynamic>.from(widget.cards[index]);

                  return FlipCardCore(
                    flipDirection: reviewerSettingsProvider.flashCardFlippingDirection,
                    question: highlightKeywords( context: context, keyword:  card['keyword'] , text:  card['question'] , fontSize: 20 , fontColor: Theme.of(context).colorScheme.onPrimary, fontSizeKeyword: 15, isCenter: true),
                    answer: card['answer'],
                    onEdit: () {
                      // Populate the quiz provider with the current card's data
                      quizProvider.questionController.text = card['question'];
                      quizProvider.answerController.text = card['answer'];

                      // Open the modal for editing the card
                      CreateCardBottomModal(
                        name: widget.setname,
                        context: context,
                        buttonName: "Edit Card",
                        isCreate: false,
                        cardName: card['question'],
                        card: card,
                      );
                    },
                  );
                },

                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
              ),
            ),
          ),
          // Indicator in a Row for horizontal alignment
          Padding(
            padding: const EdgeInsets.only(top: 5.0), // Adds space between indicator and cards
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, color: Colors.grey),
                    onPressed: () {
                      // Add logic to scroll left
                    },
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the indicators
                      children: List.generate(
                        3,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2.0),
                          width: widget.cards.length <= 15 ? 10 : 6,
                          height: widget.cards.length <= 15 ? 10 : 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, color: Colors.grey),
                    onPressed: () {
                      // Add logic to scroll right
                    },
                  ),
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}
