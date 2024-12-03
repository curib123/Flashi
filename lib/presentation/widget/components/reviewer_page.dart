import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/flashcard_review.dart';
import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/keywords_review.dart';
import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/matching_type_review.dart';
import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/multiple_choice_review.dart';
import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/q&a_reviewer.dart';
import 'package:flashlearn/presentation/widget/components/reviewer_type_pages/text_to_speech_review.dart';
import 'package:flutter/material.dart';

class ReviewerPage extends StatelessWidget {
  final String reviewer;
  const ReviewerPage({super.key, required this.reviewer});

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
        title: Text(reviewer),
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
        return FlashcardReview(reviewer: reviewer,); // Assuming this is the correct widget to display for this review type
      case 'Multiple Choice':
      // Return the widget for multiple choice
        return MultipleChoiceReview(reviewer: reviewer); // Replace with the actual widget
      case 'Matching Type':
      // Return the widget for matching type
        return MatchingTypeReview(reviewer: reviewer); // Replace with the actual widget
      case 'Q&A Session':
      // Return the widget for Q&A session
        return QuestionAndAnswer(reviewer: reviewer); // Replace with the actual widget
      case 'Text-to-Speech Review':
      // Return the widget for text-to-speech review
        return TextToSpeechReview(reviewer: reviewer); // Replace with the actual widget
      case 'Keywords Review':
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
