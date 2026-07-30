import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/core/ads/widgets/rewarded_ad_button.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/core/state/sort_provider.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/features/ai/presentation/dialogs/add_credit_slot_dialog.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/features/quiz/presentation/dialogs/quiz_card_form_sheet.dart';
import 'package:flashi/features/quiz/presentation/widgets/quiz_card_list.dart';
import 'package:flashi/features/reviewer/presentation/dialogs/highlight_keyword_dialog.dart';
import 'package:flashi/features/reviewer/presentation/dialogs/review_mode_dialog.dart';
import 'package:flashi/shared/dialogs/delete_confirmation_dialog.dart';
import 'package:flashi/shared/widgets/app_page_header.dart';
import 'package:flashi/shared/widgets/empty_state_widgets.dart';
import 'package:flashi/shared/widgets/sort_section_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizCardsPage extends StatelessWidget {
  const QuizCardsPage({
    required this.name,
    required this.colorScheme,
    required this.card,
    required this.index,
    required this.cards,
    super.key,
  });

  final String name;
  final int index;
  final ColorScheme colorScheme;
  final Map<String, dynamic> card;
  final List<dynamic> cards;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: name,
              description: '${cards.length} cards in this quiz set',
              leading: const BackButton(),
              actions: [
                IconButton(
                  tooltip: 'Start review',
                  onPressed: cards.isEmpty
                      ? null
                      : () => showReviewModeDialog(
                            context: context,
                            heading: name,
                            cards: cards,
                            setname: name,
                          ),
                  icon: const Icon(Icons.play_arrow_rounded),
                ),
              ],
            ),
            Expanded(
              child: _CardLibrary(name: name, card: card, cards: cards),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardLibrary extends StatelessWidget {
  const _CardLibrary({
    required this.name,
    required this.card,
    required this.cards,
  });

  final String name;
  final Map<String, dynamic> card;
  final List<dynamic> cards;

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final sort = context.watch<SortProvider>();
    final credits = context.watch<AiCreditProvider>();
    final limit = (card['limitNumberOfQuiz'] as int?) ?? 0;
    final used = quiz.getNumberOfCardsInSet(name);
    final slotsLeft = limit > 0 ? limit - used : 0;
    final colors = Theme.of(context).colorScheme;
    final adManager = AdManager();

    return ResponsiveContent(
      child: Column(
        children: [
          SortSectionHeader(
            dropdownValue: sort.dropdownValueCard,
            sortOptions: sort.sortOptionsCard,
            onSortChanged: (value) {
              if (value == null) return;
              sort.updateSortValueCard(value);
              quiz.toggleNewValueCard(value);
            },
            isShowSeeAllLink: false,
            isShowReviewLink: false,
            onShowReviewLink: () {},
            onSeeAllPressed: () {},
          ),
          if (cards.isNotEmpty) adManager.getSixthBannerAdWidget(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: cards.isEmpty
                ? noCardWidget(context)
                : QuizCardList(
                    name: name,
                    card: card,
                    onRemove: (item) => showDeleteConfirmationDialog(
                      context: context,
                      setName: name,
                      onDelete: () => quiz.removeCardFromQuizSet(
                        quizSetName: name,
                        question: item['question'],
                      ),
                    ),
                    onEdit: (item) {
                      quiz.questionController.text = item['question'];
                      quiz.answerController.text = item['answer'];
                      showQuizCardFormSheet(
                        name: name,
                        context: context,
                        buttonName: 'Edit card',
                        isCreate: false,
                        cardName: item['question'],
                        card: item,
                      );
                    },
                    onIgnore: (_, item) => quiz.toggleIgnore(
                      quizSetName: name,
                      isIgnore: item['isIgnore'],
                      question: item['question'],
                    ),
                    onKeyword: (item) =>
                        showHighlightKeywordDialog(context, (keyword) {
                      quiz.updateKeyWordInQuizSet(
                        quizSetName: name,
                        oldKeyWord: item['keyword'],
                        newKeyWord: keyword,
                      );
                    }),
                    onRemoveKeyword: (item) => quiz.updateKeyWordInQuizSet(
                      quizSetName: name,
                      oldKeyWord: item['keyword'],
                      newKeyWord: '',
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (slotsLeft > 0)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => showQuizCardFormSheet(
                  context: context,
                  buttonName: 'Add card',
                  isCreate: true,
                  cardName: '',
                  card: card,
                  name: name,
                ),
                icon: const Icon(Icons.add),
                label: Text('Add card · $slotsLeft slots left'),
              ),
            )
          else if (credits.credits > 0)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showAddSlotAlertDialog(
                  context: context,
                  onConfirm: () async {
                    final spent = await credits.spendCredits(1);
                    if (!context.mounted) return;
                    if (!spent) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Not enough energy to add more slots.'),
                        ),
                      );
                      return;
                    }
                    quiz.updateQuizSetLimit(2);
                  },
                ),
                icon: const Icon(Icons.add_card_outlined),
                label: const Text('Add more slots'),
              ),
            )
          else
            RewardedAdButton(
              colorScheme: colors,
              name: 'Watch ad for 5 credits',
            ),
        ],
      ),
    );
  }
}
