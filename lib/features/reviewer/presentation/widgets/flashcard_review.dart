import 'package:flashi/features/reviewer/presentation/widgets/flashcard.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/features/reviewer/application/reviewer_settings_provider.dart';
import 'package:flashi/features/quiz/presentation/dialogs/quiz_card_form_sheet.dart';
import 'package:flashi/shared/widgets/highlighted_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlashcardReview extends StatefulWidget {
  final String reviewer;
  final List<dynamic> cards;
  final String setname;

  const FlashcardReview(
      {super.key,
      required this.reviewer,
      required this.cards,
      required this.setname});

  @override
  State<FlashcardReview> createState() => _FlashcardReviewState();
}

class _FlashcardReviewState extends State<FlashcardReview> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

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
    final reviewerSettingsProvider =
        Provider.of<ReviewerSettingsProvider>(context);

    if (widget.cards.isEmpty) {
      return Center(
        child: Text("No cards available",
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
                  Map<String, dynamic> card =
                      Map<String, dynamic>.from(widget.cards[index]);

                  return Flashcard(
                    flipDirection:
                        reviewerSettingsProvider.flashCardFlippingDirection,
                    question: highlightKeywords(
                        context: context,
                        keyword: card['keyword'],
                        text: card['question'],
                        fontSize: 20,
                        fontColor: Theme.of(context).colorScheme.onSurface,
                        fontSizeKeyword: 15,
                        isCenter: true),
                    answer: card['answer'],
                    onEdit: () {
                      // Populate the quiz provider with the current card's data
                      quizProvider.questionController.text = card['question'];
                      quizProvider.answerController.text = card['answer'];

                      // Open the modal for editing the card
                      showQuizCardFormSheet(
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
            padding: const EdgeInsets.only(
                top: 5.0), // Adds space between indicator and cards
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left, color: Colors.grey),
                    onPressed: () {
                      // Add logic to scroll left
                    },
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center the indicators
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
                    icon: const Icon(Icons.arrow_right, color: Colors.grey),
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
