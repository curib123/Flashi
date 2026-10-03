import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/widget/components/see_all_quiz_card.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_set_core.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/other/import_export_helper_class.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/delete_confirmation_alert_box.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/review_selection_alert_box.dart';
import 'package:flashi/util/helpers/widget/modals/create_card_bottom_modal.dart';
import 'package:flashi/util/helpers/widget/modals/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final sets = quiz.filteredQuizSetsFavorite;
    final helper = ImportExportHelperClass();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          FlashiDesign.pagePadding,
          4,
          FlashiDesign.pagePadding,
          0,
        ),
        child: sets.isEmpty
            ? const _EmptyFavorites()
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 30),
                itemCount: sets.length,
                itemBuilder: (context, index) {
                  final set = sets[index];
                  final name = (set['name'] ?? 'Unnamed set').toString();
                  final description = (set['description'] ?? '').toString();
                  final cards = (set['cards'] as List?) ?? <dynamic>[];
                  final favorite = set['favorite'] == true;
                  final timestamp = set['timestamp'] is DateTime
                      ? set['timestamp'] as DateTime
                      : DateTime.now();

                  return ReusableSetCore(
                    name: name,
                    description: description,
                    numberOfQuiz: cards.length,
                    isFavorate: favorite,
                    timestamp: timestamp,
                    onTap: () =>
                        _openCards(context, name, set, index, cards),
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
                      onDelete: () => quiz.removeQuizSet(set),
                    ),
                    onEdit: () {
                      quiz.nameController.text = name;
                      quiz.descriptionController.text = description;
                      CreateSetBottomModal(
                        context: context,
                        buttonName: 'Save',
                        isCreate: false,
                        setName: name,
                      );
                    },
                    onFavorate: () => quiz.toggleFavorite(set),
                    onViewAllCards: () =>
                        _openCards(context, name, set, index, cards),
                    onShare: () {},
                    onExport: () => helper.exportList(context, set),
                  );
                },
              ),
      ),
    );
  }

  void _openCards(
    BuildContext context,
    String name,
    Map<String, dynamic> set,
    int index,
    List<dynamic> cards,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeeAllQuizCard(
          name: name,
          colorScheme: Theme.of(context).colorScheme,
          card: set,
          index: index,
          cards: cards,
        ),
      ),
    );
  }

  Future<void> _addCard(
    BuildContext context,
    String name,
    Map<String, dynamic> set,
    int index,
    List<dynamic> cards,
  ) async {
    _openCards(context, name, set, index, cards);
    await Future.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) return;
    CreateCardBottomModal(
      context: context,
      buttonName: 'Add Card',
      isCreate: true,
      cardName: '',
      name: name,
      card: set,
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 52,
              color: colors.primary,
            ),
            const SizedBox(height: 14),
            const Text(
              'No favorites yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Favorite the quiz sets you review most often and they will stay easy to reach.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
