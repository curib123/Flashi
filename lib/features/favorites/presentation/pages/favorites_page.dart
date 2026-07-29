import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/features/quiz/presentation/pages/quiz_cards_page.dart';
import 'package:flashi/features/quiz/presentation/widgets/quiz_set_card.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/shared/dialogs/delete_confirmation_dialog.dart';
import 'package:flashi/features/reviewer/presentation/dialogs/review_mode_dialog.dart';
import 'package:flashi/features/quiz/data/services/quiz_import_export_service.dart';
import 'package:flashi/features/quiz/presentation/dialogs/quiz_card_form_sheet.dart';
import 'package:flashi/features/quiz/presentation/dialogs/quiz_set_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashi/features/settings/presentation/dialogs/theme_dialog.dart';
import 'package:flashi/shared/widgets/empty_state_widgets.dart';
import 'package:flashi/shared/widgets/app_page_header.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final quizSets = quizProvider.filteredQuizSetsFavorite;

    final QuizImportExportService helper =
        QuizImportExportService(); // Helper instance for export/import
    AdManager adManager = AdManager();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Favorites',
              description: '${quizSets.length} saved quiz sets',
              leading: const BackButton(),
              actions: [
                IconButton(
                  tooltip: 'Appearance',
                  onPressed: () => openThemeSelector(context),
                  icon: const Icon(Icons.contrast_outlined),
                ),
              ],
            ),
            Expanded(
              child: ResponsiveContent(
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
                          final DateTime timestamp =
                              set['timestamp'] ?? DateTime.now();

                          return Column(
                            children: [
                              adManager.getSecondBannerAdWidget(),
                              QuizSetCard(
                                name: name,
                                description: description,
                                numberOfQuiz: cards.length,
                                isFavorate: favorite,
                                timestamp: timestamp,
                                onTap: () => _navigateToQuizCards(
                                    context, name, set, index, cards),
                                onAddCard: () =>
                                    _addCard(context, name, set, index, cards),
                                onReview: () => showReviewModeDialog(
                                  context: context,
                                  heading: name,
                                  cards: cards,
                                  setname: name,
                                ),
                                onDelete: () => showDeleteConfirmationDialog(
                                  context: context,
                                  setName: name,
                                  onDelete: () =>
                                      quizProvider.removeQuizSet(set),
                                ),
                                onEdit: () => _showEditSetModal(
                                    context, quizProvider, name, description),
                                onFavorate: () =>
                                    quizProvider.toggleFavorite(set),
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
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a placeholder widget when the quiz set list is empty.
  Widget _buildEmptyState(BuildContext context) {
    return const AppEmptyState(
      icon: Icons.favorite_border,
      title: 'No favorites yet',
      description: 'Favorite a quiz set to keep it within easy reach.',
    );
  }

  /// Combines navigation logic to avoid redundancy.
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

  /// Handles the "Edit Set" modal logic.
  void _showEditSetModal(BuildContext context, QuizProvider quizProvider,
      String name, String description) {
    quizProvider.nameController.text = name;
    quizProvider.descriptionController.text = description;

    showQuizSetFormSheet(
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

    showQuizCardFormSheet(
      context: context,
      buttonName: "Add Card",
      isCreate: true,
      cardName: '',
      name: name,
      card: set,
    );
  }
}
