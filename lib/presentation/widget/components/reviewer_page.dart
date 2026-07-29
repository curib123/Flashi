import 'package:flashi/presentation/widget/components/reviewer_type_pages/flashcard_review.dart';
import 'package:flashi/presentation/widget/components/reviewer_type_pages/multiple_choice_review(basic).dart';
import 'package:flashi/presentation/widget/components/reviewer_type_pages/multiple_choice_review(timer).dart';
import 'package:flashi/presentation/widget/components/reviewer_type_pages/text_input_review_basic.dart';
import 'package:flashi/presentation/widget/components/reviewer_type_pages/text_to_speech_review.dart';
import 'package:flashi/features/reviewer/application/reviewer_settings_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/reviewer_settings_alert_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewerPage extends StatelessWidget {
  final String reviewer;
  final List<dynamic> cards;
  final String setname;
  const ReviewerPage(
      {super.key,
      required this.reviewer,
      required this.cards,
      required this.setname});

  @override
  Widget build(BuildContext context) {
    // Filtering only cards where isIgnore is false
    final List<dynamic> filteredCardsIsIgnore = cards
        .where((card) =>
            card['isIgnore'] == false) // Filter cards with isIgnore == false
        .toList();

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(),
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                reviewer,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow:
                    TextOverflow.ellipsis, // Adds ellipsis for text overflow
              ),
            ),
            GestureDetector(
              onTap: () => reviewerSettingsAlertBox(context: context),
              child: Icon(
                Icons.edit_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new, // Custom icon (back arrow)
            color: Theme.of(context)
                .colorScheme
                .primary, // Custom color for the icon
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back when pressed
          },
        ),
      ),
      body: reviewerCheck(context, filteredCardsIsIgnore),
    );
  }

  Widget reviewerCheck(
      BuildContext context, List<dynamic> filteredCardsIsIgnore) {
    switch (reviewer) {
      case 'Flashcard Review':
        return FlashcardReview(
          reviewer: reviewer,
          cards: filteredCardsIsIgnore,
          setname: setname,
        ); // Assuming this is the correct widget to display for this review type
      case 'Multiple Choice (Basic)':
        // Return the widget for multiple choice
        return MultipleChoiceReviewBasic(
          reviewer: reviewer,
          cards: filteredCardsIsIgnore,
          setname: setname,
        ); // Replace with the actual widget
      case 'Multiple Choice (Timer)':
        // Return the widget for multiple choice
        return MultipleChoiceReviewTimer(
          reviewer: reviewer,
          cards: filteredCardsIsIgnore,
          setname: setname,
          timerDuration:
              Provider.of<ReviewerSettingsProvider>(context).timeDuration,
        ); // Replace with the actual widget
      case 'Text-to-Speech Review':
        // Return the widget for text-to-speech review
        return TextToSpeechReview(
            reviewer: reviewer,
            cards: filteredCardsIsIgnore,
            setname: setname); // Replace with the actual widget
      case 'Text Input Basic Review':
        // Return the widget for text-to-speech review
        return TextInputReviewBasic(
            reviewer: reviewer,
            cards: filteredCardsIsIgnore,
            setname: setname); // Replace with the actual widget

      default:
        return const Center(
          child: Text(
            'Review type not implemented',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
        );
    }
  }
}
