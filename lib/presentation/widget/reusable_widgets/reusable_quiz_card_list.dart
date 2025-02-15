import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_card_core.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

/// A reusable widget for displaying a list of quiz cards with animations and actions.
class ReusableQuizCardList extends StatelessWidget {
  final String name; // Name of the quiz set
  final Map<String, dynamic> card; // Quiz card data
  final Function(Map<String, dynamic> quizSet)? onRemove; // Callback for removing a quiz card
  final Function(Map<String, dynamic> quizSet)? onEdit; // Callback for editing a quiz card
  final Function(String name, Map<String, dynamic> quizSet)? onIgnore; // Callback for ignoring/unignoring a quiz card
  final Function( Map<String, dynamic> quizSet)? onKeyword; // Callback for ignoring/unignoring a quiz card
  final Function( Map<String, dynamic> quizSet)? onRemoveKeyword; // Callback for ignoring/unignoring a quiz card

  const ReusableQuizCardList({
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



    // Safely extract quiz sets from the provided card and reverse the list for display.
    final quizSet = (card['cards'] as List?)
        ?.map((item) => item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item))
        .toList().reversed.toList()
        ??
        [];

   final quizProvider = Provider.of<QuizProvider>(context);

  final quizSets = quizProvider.sortQuizCard( quizSet:quizSet ).reversed.toList();

    if (quizSets.isEmpty) {
      return Center(
        child: Text("No cards available", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      );
    }

    return AnimationLimiter(
      child: Column(
        children: quizSets.map((quizSet) {
          final int index = quizSets.indexOf(quizSet);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(seconds: 2), // Animation duration for each item
            child: SlideAnimation(
              curve: Curves.easeInOutCubicEmphasized, // Smooth animation curve
              verticalOffset: 100.0, // Initial vertical offset for slide animation
              child: FadeInAnimation(
                child: Slidable(
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      // Delete action
                      SlidableAction(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        icon: Icons.delete,
                        onPressed: (context) {
                          if (onRemove != null) onRemove!(quizSet);
                        },
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      // Edit action
                      SlidableAction(
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                        icon: Icons.edit,
                        onPressed: (context) {
                          if (onEdit != null) onEdit!(quizSet);
                        },
                      ),
                      // Ignore/Unignore action
                      SlidableAction(
                        foregroundColor: Theme.of(context).colorScheme.tertiary,
                        icon: quizSet['isIgnore'] ? Icons.visibility : Icons.visibility_off,
                        onPressed: (context) {
                          if (onIgnore != null) onIgnore!(name, quizSet);
                        },
                      ),
                    ],
                  ),
                  child: ReusableCardCore(
                    isUpdating: quizSet['isUpdating'] ?? false,
                    question: quizSet['question'] ?? 'No question provided',
                    keyword:  quizSet['keyword'] ?? '',
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
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
