import 'package:flashi/presentation/screen/main/export_import_screen.dart';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/components/see_all_quiz_card.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_set_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/delete_confirmation_alert_box.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/review_selection_alert_box.dart';
import 'package:flashi/util/helpers/classes/other/import_export_helper_class.dart';
import 'package:flashi/util/helpers/widget/modals/create_card_bottom_modal.dart';
import 'package:flashi/util/helpers/widget/modals/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final quizProvider = Provider.of<QuizProvider>(context);
    final quizSets = quizProvider.filteredQuizSetsFavorite;

    final ImportExportHelperClass helper = ImportExportHelperClass();  // Helper instance for export/import
    AdManager adManager = AdManager();

    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorScheme.primary,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(

            ),
          ),
          backgroundColor: colorScheme.onPrimary,
          foregroundColor: colorScheme.primary,
          title: Text("Favorates",style: TextStyle(color: colorScheme.primary),),
          centerTitle: true,
        ),
      body:  Stack(
        children: [

          quizSets.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
            itemCount: quizSets.length,
            itemBuilder: (context, index) {
              final set = quizSets[index];
              final String name = set['name'] ?? 'Unnamed Set';
              final String description = set['description'] ?? '';
              final List cards = set['cards'] ?? [];
              final bool favorite = set['favorite'] ?? false;
              final DateTime timestamp = set['timestamp'] ?? DateTime.now();

              return AnimationLimiter(
                child: AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(seconds: 1),
                  child: SlideAnimation(
                    curve: Curves.easeInOutCubicEmphasized,
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Column(
                          children: [
                            adManager.getSecondBannerAdWidget(),
                            ReusableSetCore(
                              name: name,
                              description: description,
                              numberOfQuiz: cards.length,
                              isFavorate: favorite,
                              timestamp: timestamp,
                              onTap: () => _navigateToQuizCards(context, name, set, index, cards),
                              onAddCard: () => _addCard(context, name, set, index, cards),
                              onReview: () => showReviewSelection(
                                context: context,
                                heading: name,
                                cards: cards,
                                setname: name,
                              ),
                              onDelete: () => showDeleteConfirmationDialog(
                                context: context,
                                setName: name,
                                onDelete: () => quizProvider.removeQuizSet(set),
                              ),
                              onEdit: () => _showEditSetModal(context, quizProvider, name, description),
                              onFavorate: () => quizProvider.toggleFavorite(set),
                              onViewAllCards: () => _navigateToQuizCards(context, name, set, index, cards),
                              onShare: () {  },
                              onExport: () {
                                helper.exportList(context, set);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              );
            },
          ),

          ReusableThemeSettingPosition(colorScheme: colorScheme)
        ],
      )
    );
  }

  /// Builds a placeholder widget when the quiz set list is empty.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "No favorite sets available",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Add some sets to your favorites to see them here.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Combines navigation logic to avoid redundancy.
  void _navigateToQuizCards(BuildContext context, String name, Map<String, dynamic> set, int index, List<dynamic> cards) {
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

  /// Handles the "Edit Set" modal logic.
  void _showEditSetModal(BuildContext context, QuizProvider quizProvider, String name, String description) {
    quizProvider.nameController.text = name;
    quizProvider.descriptionController.text = description;

    CreateSetBottomModal(
      context: context,
      buttonName: 'Edit',
      isCreate: false,
      setName: name,
    );
  }

  /// Adds a card to the quiz set.
  Future<void> _addCard(BuildContext context, String name, Map<String, dynamic> set, int index, List<dynamic> cards) async {
    _navigateToQuizCards(context, name, set, index, cards);
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
