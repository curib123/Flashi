import 'package:flashi/features/quiz/presentation/pages/quiz_cards_page.dart';
import 'package:flashi/shared/widgets/core/reusable_set_core.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/shared/dialogs/message_dialog.dart';
import 'package:flashi/shared/dialogs/delete_confirmation_dialog.dart';
import 'package:flashi/features/reviewer/presentation/dialogs/review_mode_dialog.dart';
import 'package:flashi/features/quiz/data/services/quiz_import_export_service.dart';
import 'package:flashi/features/quiz/presentation/dialogs/quiz_card_form_sheet.dart';
import 'package:flashi/features/quiz/presentation/dialogs/quiz_set_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// Reusable widget to display a list of quiz sets with animations and interactive actions.
class QuizSetList extends StatelessWidget {
  final List<Map<String, dynamic>> quizSets;

  const QuizSetList({
    super.key,
    required this.quizSets,
  });

  Future<void> requestPermissions() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
    if (!await Permission.manageExternalStorage.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuizImportExportService helper =
        QuizImportExportService(); // Helper instance for export/import

    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        return Column(
          children: [
            AnimationLimiter(
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
                    final DateTime timestamp =
                        set['timestamp'] ?? DateTime.now();

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(seconds: 2),
                      child: SlideAnimation(
                        curve: Curves.easeInOutCubicEmphasized,
                        verticalOffset: 100.0,
                        child: FadeInAnimation(
                          child: ReusableSetCore(
                            name: name,
                            description: description,
                            numberOfQuiz: cards.length,
                            isFavorate: favorite,
                            timestamp: timestamp,
                            onTap: () => {
                              _navigateToQuizCards(
                                  context, name, set, index, set['cards']),
                              quizProvider
                                  .updateCurrentQuizSetNameToSetLimit(name),
                            },
                            onAddCard: () async {
                              if ((set['limitNumberOfQuiz'] -
                                      quizProvider
                                          .getNumberOfCardsInSet(name)) >
                                  0) {
                                _addCard(
                                    context, name, set, index, set['cards']);
                              } else {
                                _navigateToQuizCardsPage(
                                    context, name, set, index, set['cards']);
                                showMessageDialog(
                                    context,
                                    type: "warning",
                                    "warning",
                                    "You have run out of slots. Use Energy Free 2 slots");
                              }
                              quizProvider
                                  .updateCurrentQuizSetNameToSetLimit(name);
                            },
                            onReview: () => showReviewModeDialog(
                                context: context,
                                heading: name,
                                cards: set['cards'],
                                setname: name),
                            onDelete: () => showDeleteConfirmationDialog(
                              context: context,
                              setName: name,
                              onDelete: () => quizProvider.removeQuizSet(set),
                            ),
                            onEdit: () {
                              quizProvider.nameController.text = name;
                              quizProvider.descriptionController.text =
                                  description;
                              showQuizSetFormSheet(
                                context: context,
                                buttonName: 'Edit',
                                isCreate: false,
                                setName: name,
                              );
                            },
                            onFavorate: () => quizProvider.toggleFavorite(set),
                            onViewAllCards: () => {
                              _navigateToQuizCardsPage(
                                  context, name, set, index, set['cards']),
                              quizProvider
                                  .updateCurrentQuizSetNameToSetLimit(name),
                            },
                            onShare: () {
                              //    await shareFile();
                            },
                            onExport: () {
                              helper.exportList(context, set);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
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
        builder: (context) => QuizCardsPage(
          name: name,
          colorScheme: Theme.of(context).colorScheme,
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
        builder: (context) => QuizCardsPage(
          name: name,
          colorScheme: Theme.of(context).colorScheme,
          card: set,
          index: index,
          cards: cards,
        ),
      ),
    );

    // Wait before showing the Create Card modal
    await Future.delayed(const Duration(seconds: 1));

    showQuizCardFormSheet(
      context: context,
      buttonName: "Add Card",
      isCreate: true,
      cardName: '',
      name: name,
      card: set,
    );
  }

  /// Navigate to the Add Card List screen.
  void _navigateToQuizCardsPage(BuildContext context, String name,
      Map<String, dynamic> set, int index, List<dynamic> cards) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizCardsPage(
          name: name,
          colorScheme: Theme.of(context).colorScheme,
          card: set,
          index: index,
          cards: cards,
        ),
      ),
    );
  }
}
