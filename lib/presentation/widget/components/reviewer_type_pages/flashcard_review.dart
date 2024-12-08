import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reviewer_widgets_core/flip_card_core.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/util/helpers/modal/create_card_bottom_modal.dart';
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

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < widget.cards.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access both providers directly
    final quizProvider = Provider.of<QuizProvider>(context);

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
                    question: card['question'],
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
          // Arrow buttons and indicator in a Row for horizontal alignment
          Padding(
            padding: const EdgeInsets.only(top: 10.0), // Adds space between indicator and cards
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _previousPage,
                  child: Icon(
                    Icons.chevron_left,
                    size: 60,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                // Wrap the indicator row in a SingleChildScrollView for horizontal scrolling
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the indicators
                        children: List.generate(
                          widget.cards.length,
                              (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 2.0),
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
                GestureDetector(
                  onTap: _nextPage,
                  child: Icon(
                    Icons.chevron_right,
                    size: 60,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
