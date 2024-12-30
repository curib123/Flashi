import 'package:flashlearn/presentation/widget/components/see_all_quiz_card.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_set_summary_core.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/util/helpers/alert_box/delete_confirmation_alert_box.dart';
import 'package:flashlearn/util/helpers/alert_box/review_selection_alert_box.dart';
import 'package:flashlearn/util/helpers/modal/create_card_bottom_modal.dart';
import 'package:flashlearn/util/helpers/modal/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// Reusable widget to display a list of quiz sets with animations and interactive actions.
class ReusableQuizSetSummaryList extends StatelessWidget {
  final List<Map<String, dynamic>> quizSets;

  const ReusableQuizSetSummaryList({
    super.key,
    required this.quizSets,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        return AnimationLimiter(
          // Adds staggered animations to the quiz set list
          child: Column(
            children: List.generate(
              quizSets.length,
                  (index) {
                final set = quizSets[index];

                // Extract quiz set details with fallbacks for null values
                final String name = set['name'] ?? 'Unnamed Set';
                final String description = set['description'] ?? '';
                final List cards = set['cards'] ?? [];
                final bool favorite = set['favorite'] ?? false;
                final DateTime timestamp = set['timestamp'] ?? DateTime.now();

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(seconds: 3),
                  child: SlideAnimation(
                    curve: Curves.easeInOutCubicEmphasized,
                    verticalOffset: 100.0,
                    child: FadeInAnimation(
                      child: Slidable(
                        // Left swipe for delete action
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) =>
                                  showDeleteConfirmationDialog(
                                    context: context,
                                    setName: name,
                                    onDelete: () =>
                                        quizProvider.removeQuizSet(set),
                                  ),
                              foregroundColor: Theme
                                  .of(context)
                                  .colorScheme
                                  .error,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        // Right swipe for edit action
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                quizProvider.nameController.text = name;
                                quizProvider.descriptionController.text =
                                    description;
                                CreateSetBottomModal(
                                  context: context,
                                  buttonName: 'Edit',
                                  isCreate: false,
                                  setName: name,
                                );
                              },
                              foregroundColor: Theme
                                  .of(context)
                                  .colorScheme
                                  .tertiary,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        child: ReusableSetSummaryCore(
                          name: name,
                          description: description,
                          numberOfQuiz: cards.length,
                          timestamp: timestamp,
                          onTap: () =>
                              _navigateToQuizCards(
                                  context, name, set, index, set['cards']),
                          onAddCard: () async =>
                              _addCard(context, name, set, index, set['cards']),
                          onReview: () =>
                              showReviewSelection(context: context,
                                  heading: name,
                                  cards: set['cards'],
                                  setname: name),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Navigate to the quiz card screen.
  void _navigateToQuizCards(BuildContext context, String name,
      Map<String, dynamic> set, int index, List<dynamic> cards) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SeeAllQuizCard(
              name: name,
              colorScheme: Theme
                  .of(context)
                  .colorScheme,
              card: set,
              index: index,
              cards: cards,
            ),
      ),
    );
  }

  /// Add a card to a quiz set after a delay.
  Future<void> _addCard(BuildContext context, String name,
      Map<String, dynamic> set, int index, List<dynamic> cards) async {
    // Navigate to the Add Card List screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SeeAllQuizCard(
              name: name,
              colorScheme: Theme
                  .of(context)
                  .colorScheme,
              card: set,
              index: index,
              cards: cards,
            ),
      ),
    );

    // Wait before showing the Create Card modal
    await Future.delayed(const Duration(seconds: 1));

    CreateCardBottomModal(
      context: context,
      buttonName: "Add Card",
      isCreate: true,
      cardName: '',
      name: name,
      card: set,
    );
  }


}