import 'package:flashi/features/reviewer/presentation/widgets/flashcard_review.dart';
import 'package:flashi/features/reviewer/presentation/widgets/multiple_choice_review.dart';
import 'package:flashi/features/reviewer/presentation/widgets/timed_multiple_choice_review.dart';
import 'package:flashi/features/reviewer/presentation/widgets/text_input_review.dart';
import 'package:flashi/features/reviewer/presentation/widgets/text_to_speech_review.dart';
import 'package:flashi/features/reviewer/application/reviewer_settings_provider.dart';
import 'package:flashi/features/reviewer/presentation/dialogs/reviewer_settings_dialog.dart';
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow:
                    TextOverflow.ellipsis, // Adds ellipsis for text overflow
              ),
            ),
            GestureDetector(
              onTap: () => showReviewerSettingsDialog(context: context),
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
        return MultipleChoiceReview(
          reviewer: reviewer,
          cards: filteredCardsIsIgnore,
          setname: setname,
        ); // Replace with the actual widget
      case 'Multiple Choice (Timer)':
        // Return the widget for multiple choice
        return TimedMultipleChoiceReview(
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
        return TextInputReview(
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
