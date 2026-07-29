import 'package:flashi/features/quiz/presentation/widgets/quiz_card.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A reusable widget for displaying a list of quiz cards with actions.
class QuizCardList extends StatelessWidget {
  final String name; // Name of the quiz set
  final Map<String, dynamic> card; // Quiz card data
  final Function(Map<String, dynamic> quizSet)?
      onRemove; // Callback for removing a quiz card
  final Function(Map<String, dynamic> quizSet)?
      onEdit; // Callback for editing a quiz card
  final Function(String name, Map<String, dynamic> quizSet)?
      onIgnore; // Callback for ignoring/unignoring a quiz card
  final Function(Map<String, dynamic> quizSet)?
      onKeyword; // Callback for keyword action
  final Function(Map<String, dynamic> quizSet)?
      onRemoveKeyword; // Callback for removing keyword

  const QuizCardList({
    Key? key,
    required this.name,
    required this.card,
    required this.onRemove,
    required this.onEdit,
    required this.onIgnore,
    required this.onKeyword,
    required this.onRemoveKeyword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely extract quiz sets from the provided card
    final quizSet = (card['cards'] as List?)
            ?.map((item) => item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item))
            .toList() ??
        [];

    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final quizSets = quizProvider.sortQuizCard(quizSet: quizSet);

    if (quizSets.isEmpty) {
      return Center(
        child: Text("No cards available",
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      );
    }

    return ListView.builder(
      itemCount: quizSets.length,
      itemBuilder: (context, index) {
        final quizSet = quizSets[index];

        return QuizCard(
          isUpdating: quizSet['isUpdating'] ?? false,
          question: quizSet['question'] ?? 'No question provided',
          keyword: quizSet['keyword'] ?? '',
          answer: quizSet['answer'] ?? 'No answer provided',
          timestamp: quizSet['timestamp'] ?? DateTime.now(),
          isIgnore: quizSet['isIgnore'] ?? false,
          onRemove: () {
            if (onRemove != null) onRemove!(quizSet);
          },
          onEdit: () {
            if (onEdit != null) onEdit!(quizSet);
          },
          onIgnore: () {
            if (onIgnore != null) onIgnore!(name, quizSet);
          },
          onKeyword: () {
            if (onKeyword != null) onKeyword!(quizSet);
          },
          onRemoveKeyword: () {
            if (onRemoveKeyword != null) onRemoveKeyword!(quizSet);
          },
        );
      },
    );
  }
}
