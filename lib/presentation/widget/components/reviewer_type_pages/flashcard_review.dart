import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reviewer_widgets_core/flip_card_core.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/provider/reviewer_settings_provider.dart';
import 'package:flashlearn/util/helpers/ads/ad_helper.dart';
import 'package:flashlearn/util/helpers/modal/create_card_bottom_modal.dart';
import 'package:flashlearn/util/helpers/widget/highlight_keywords.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

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

  var startAppSdk = StartAppSdk();

  StartAppInterstitialAd? interstitialAd;

  @override
  void initState() {
    super.initState();
    // TODO make sure to comment out this line before release
  //  startAppSdk.setTestAdsEnabled(true);
    startAppSdk.setTestAdsEnabled(AdHelper.isTestEnabled);
      loadInterstitialAd();

    _pageController = PageController();

  }

  void loadInterstitialAd() {
    startAppSdk.loadInterstitialAd(prefs: StartAppAdPreferences(adTag: 'flashcard_review')).then((interstitialAd) {
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

    if (interstitialAd != null) {
      interstitialAd!.show().then((shown) {
        if (shown) {
          setState(() {
            // NOTE interstitial ad can be shown only once
            this.interstitialAd = null;

          });
        }

        return null;
      }).onError((error, stackTrace) {
        debugPrint("Error showing Interstitial ad: $error");
      });
    }

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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the indicators
                  children: List.generate(
                    widget.cards.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      width:  widget.cards.length <= 15 ? 10 : 6,
                      height:  widget.cards.length <= 15 ? 10 : 6,
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
            ),
          ),
        ],
      ),
    );
  }
}
