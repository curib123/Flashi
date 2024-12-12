import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/flashcard_review.dart';
import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/keywords_review.dart';
import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/matching_type_review.dart';
import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/multiple_choice_review(basic).dart';
import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/multiple_choice_review(timer).dart';
import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/q&a_reviewer.dart';
import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/text_to_speech_review.dart';
import 'package:flutter/material.dart';

class ReviewerPage extends StatelessWidget {
  final String reviewer;
  final List<dynamic> cards;
  final String setname;
  const ReviewerPage({super.key, required this.reviewer, required this.cards, required this.setname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                reviewer,
                style: TextStyle(fontSize: 20),
                overflow: TextOverflow.ellipsis, // Adds ellipsis for text overflow
              ),
            ),
            Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new, // Custom icon (back arrow)
            color: Theme.of(context).colorScheme.onPrimary, // Custom color for the icon
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back when pressed
          },
        ),
      ),
      body: reviewerCheck(),
    );
  }

  Widget reviewerCheck() {
    switch (reviewer) {
      case 'Flashcard Review':
        return FlashcardReview(reviewer: reviewer, cards: cards, setname: setname,);  // Assuming this is the correct widget to display for this review type
      case 'Multiple Choice (Basic)':
      // Return the widget for multiple choice
        return MultipleChoiceReviewBasic(reviewer: reviewer, cards: cards, setname: setname,); // Replace with the actual widget

      case 'Multiple Choice (Timer)':
      // Return the widget for multiple choice
        return MultipleChoiceReviewTimer(reviewer: reviewer, cards: cards, setname: setname, timerDuration: 10,); // Replace with the actual widget
      case 'Matching Type(Coming Soon)':
      // Return the widget for matching type
        return MatchingTypeReview(reviewer: reviewer); // Replace with the actual widget
      case 'Q&A Session(Coming Soon)':
      // Return the widget for Q&A session
        return QuestionAndAnswer(reviewer: reviewer); // Replace with the actual widget
      case 'Text-to-Speech Review(Coming Soon)':
      // Return the widget for text-to-speech review
        return TextToSpeechReview(reviewer: reviewer); // Replace with the actual widget
      case 'Keywords Review(Coming Soon)':
      // Return the widget for keywords review
        return KeywordsReview(reviewer: reviewer); // Replace with the actual widget
      default:
        return Center(
          child: Text(
            'Review type not implemented',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
        );
    }
  }
}
