import 'package:flashi/app/navigation/app_router.dart';
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

  factory ReviewerPage.fromArguments(ReviewerArguments arguments) {
    return ReviewerPage(
      reviewer: arguments.reviewer,
      cards: arguments.cards,
      setname: arguments.setname,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtering only cards where isIgnore is false
    final List<dynamic> filteredCardsIsIgnore = cards
        .where((card) =>
            card['isIgnore'] == false) // Filter cards with isIgnore == false
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reviewer, overflow: TextOverflow.ellipsis),
            Text(
              setname,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Study settings',
            onPressed: () => showReviewerSettingsDialog(context: context),
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: reviewerCheck(context, filteredCardsIsIgnore),
    );
  }

  Widget reviewerCheck(
      BuildContext context, List<dynamic> filteredCardsIsIgnore) {
    switch (reviewer) {
      case 'Flashcards':
      case 'Flashcard Review':
        return FlashcardReview(
          reviewer: reviewer,
          cards: filteredCardsIsIgnore,
          setname: setname,
        ); // Assuming this is the correct widget to display for this review type
      case 'Multiple choice':
      case 'Multiple Choice (Basic)':
        // Return the widget for multiple choice
        return MultipleChoiceReview(
          reviewer: reviewer,
          cards: filteredCardsIsIgnore,
          setname: setname,
        ); // Replace with the actual widget
      case 'Timed challenge':
      case 'Multiple Choice (Timer)':
        // Return the widget for multiple choice
        return TimedMultipleChoiceReview(
          reviewer: reviewer,
          cards: filteredCardsIsIgnore,
          setname: setname,
          timerDuration:
              Provider.of<ReviewerSettingsProvider>(context).timeDuration,
        ); // Replace with the actual widget
      case 'Listen and answer':
      case 'Text-to-Speech Review':
        // Return the widget for text-to-speech review
        return TextToSpeechReview(
            reviewer: reviewer,
            cards: filteredCardsIsIgnore,
            setname: setname); // Replace with the actual widget
      case 'Written answers':
      case 'Text Input Basic Review':
        // Return the widget for text-to-speech review
        return TextInputReview(
            reviewer: reviewer,
            cards: filteredCardsIsIgnore,
            setname: setname); // Replace with the actual widget

      default:
        return const Center(
          child: Text('This study mode is not available.'),
        );
    }
  }
}
