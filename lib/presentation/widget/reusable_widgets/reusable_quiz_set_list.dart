import 'dart:io';

import 'package:flashlearn/presentation/screen/main/export_import_screen.dart';
import 'package:flashlearn/presentation/widget/components/see_all_quiz_card.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_set_core.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/util/helpers/alert_box/delete_confirmation_alert_box.dart';
import 'package:flashlearn/util/helpers/alert_box/review_selection_alert_box.dart';
import 'package:flashlearn/util/helpers/import_export_helper_class.dart';
import 'package:flashlearn/util/helpers/modal/create_card_bottom_modal.dart';
import 'package:flashlearn/util/helpers/modal/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart';

/// Reusable widget to display a list of quiz sets with animations and interactive actions.
class ReusableQuizSetList extends StatelessWidget {
  final List<Map<String, dynamic>> quizSets;

  Future<void> requestPermissions() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
    if (!await Permission.manageExternalStorage.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  const ReusableQuizSetList({
    super.key,
    required this.quizSets,
  });

  @override
  Widget build(BuildContext context) {

    final ImportExportHelperClass helper = ImportExportHelperClass();  // Helper instance for export/import

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
                              onPressed: (_) => showDeleteConfirmationDialog(
                                context: context,
                                setName: name,
                                onDelete: () => quizProvider.removeQuizSet(set),
                              ),
                              foregroundColor: Theme.of(context).colorScheme.error,
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
                                quizProvider.descriptionController.text = description;
                                CreateSetBottomModal(
                                  context: context,
                                  buttonName: 'Edit',
                                  isCreate: false,
                                  setName: name,
                                );
                              },
                              foregroundColor: Theme.of(context).colorScheme.tertiary,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        child: ReusableSetCore(
                          name: name,
                          description: description,
                          numberOfQuiz: cards.length,
                          isFavorate: favorite,
                          timestamp: timestamp,
                          onTap: () => _navigateToQuizCards(context, name, set,index,set['cards']),
                          onAddCard: () async => _addCard(context, name, set,index,set['cards']),
                          onReview: () => showReviewSelection(context: context, heading:name, cards:set['cards'], setname: name ),
                          onDelete: () => showDeleteConfirmationDialog(
                            context: context,
                            setName: name,
                            onDelete: () => quizProvider.removeQuizSet(set),
                          ),
                          onEdit: () {
                            quizProvider.nameController.text = name;
                            quizProvider.descriptionController.text = description;
                            CreateSetBottomModal(
                              context: context,
                              buttonName: 'Edit',
                              isCreate: false,
                              setName: name,
                            );
                          },
                          onFavorate: () => quizProvider.toggleFavorite(set),
                          onViewAllCards: () => _navigateToSeeAllQuizCard(context, name, set,index,set['cards']),
                          onShare: () async {

                            try {

                              helper.exportList(context, set);

                              // Replace with the path to the directory you want to share files from
                              final String directoryPath = '/storage/emulated/0/FlashLearn/Export/Sets';

                              // Ensure the directory exists
                              await requestPermissions();
                              final rootDirectory = Directory(directoryPath);

                              if (!rootDirectory.existsSync()) {
                                await rootDirectory.create(recursive: true);
                              }

                              // Define the file name and path
                              String fileName = '$name.json';
                              final filePath = "${rootDirectory.path}/$fileName";
                              final file = File(filePath);

                              // Check if the file exists
                              if (await file.exists()) {
                                try {
                                  // Share the file
                                  await Share.shareXFiles(
                                      [XFile(filePath)],
                                      text: 'Check out this file!'
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('File shared successfully!'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(16),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } catch (shareError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error sharing file: $shareError'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(16),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('File does not exist at path: $filePath'),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(16),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Catch and handle general errors
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Unexpected error: $e'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(16),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          },


                          onExport: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  ExportImportScreen()),
                            );
                          },
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
  void _navigateToQuizCards(BuildContext context, String name, Map<String, dynamic> set,int index,List<dynamic> cards) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeeAllQuizCard(
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
  Future<void> _addCard(BuildContext context, String name, Map<String, dynamic> set,int index,List<dynamic> cards) async {


    // Navigate to the Add Card List screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeeAllQuizCard(
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

    CreateCardBottomModal(
      context: context,
      buttonName: "Add Card",
      isCreate: true,
      cardName: '',
      name: name,
      card: set,
    );
  }

  /// Navigate to the Add Card List screen.
  void _navigateToSeeAllQuizCard(BuildContext context, String name, Map<String, dynamic> set,int index,List<dynamic> cards) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeeAllQuizCard(
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
