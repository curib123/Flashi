import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/presentation/widget/components/see_all_quiz_card.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_set_core.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/delete_confirmation_alert_box.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/review_selection_alert_box.dart';
import 'package:flashi/util/helpers/classes/other/import_export_helper_class.dart';
import 'package:flashi/util/helpers/widget/modals/create_card_bottom_modal.dart';
import 'package:flashi/util/helpers/widget/modals/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashi/util/helpers/widget/modals/theme_modal.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final quizSets = quizProvider.filteredQuizSetsFavorite;

    final ImportExportHelperClass helper =
        ImportExportHelperClass(); // Helper instance for export/import
    AdManager adManager = AdManager();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            tooltip: 'Appearance',
            onPressed: () => openThemeSelector(context),
            icon: const Icon(Icons.contrast_outlined),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: ResponsiveContent(
        child: quizSets.isEmpty
            ? _buildEmptyState(context)
            : ListView.separated(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                itemCount: quizSets.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final set = quizSets[index];
                  final String name = set['name'] ?? 'Unnamed Set';
                  final String description = set['description'] ?? '';
                  final List cards = set['cards'] ?? [];
                  final bool favorite = set['favorite'] ?? false;
                  final DateTime timestamp = set['timestamp'] ?? DateTime.now();

                  return Column(
                    children: [
                      adManager.getSecondBannerAdWidget(),
                      ReusableSetCore(
                        name: name,
                        description: description,
                        numberOfQuiz: cards.length,
                        isFavorate: favorite,
                        timestamp: timestamp,
                        onTap: () => _navigateToQuizCards(
                            context, name, set, index, cards),
                        onAddCard: () =>
                            _addCard(context, name, set, index, cards),
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
                        onEdit: () => _showEditSetModal(
                            context, quizProvider, name, description),
                        onFavorate: () => quizProvider.toggleFavorite(set),
                        onViewAllCards: () => _navigateToQuizCards(
                            context, name, set, index, cards),
                        onShare: () {},
                        onExport: () {
                          helper.exportList(context, set);
                        },
                      ),
                    ],
                  );
                },
              ),
      ),
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
  void _navigateToQuizCards(BuildContext context, String name,
      Map<String, dynamic> set, int index, List<dynamic> cards) {
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
  void _showEditSetModal(BuildContext context, QuizProvider quizProvider,
      String name, String description) {
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
  Future<void> _addCard(BuildContext context, String name,
      Map<String, dynamic> set, int index, List<dynamic> cards) async {
    _navigateToQuizCards(context, name, set, index, cards);
    await Future.delayed(const Duration(seconds: 1));
    if (!context.mounted) return;

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
