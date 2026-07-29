import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_card_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_rewarded_ads_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/add_slot_alert_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/delete_confirmation_alert_box.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/highlight_keyword_alert_box.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/review_selection_alert_box.dart';
import 'package:flashi/util/helpers/widget/other/empty_widgets.dart';
import 'package:flashi/util/helpers/widget/modals/create_card_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SeeAllQuizCard extends StatelessWidget {
  final String name;
  final int index;
  final ColorScheme colorScheme;
  final Map<String, dynamic> card;
  final List<dynamic> cards;

  const SeeAllQuizCard({
    super.key,
    required this.name,
    required this.colorScheme,
    required this.card,
    required this.index,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevents bottom overflow
      appBar: AppBar(
        foregroundColor: colorScheme.primary,
        backgroundColor: colorScheme.onPrimary,
        title: Text(
          name,
          style: TextStyle(
              fontSize: 16,
              color: colorScheme.primary,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.primary),
          onPressed: () {
            Navigator.pop(context);
            quizProvider.searchController.text = quizProvider.searchQuery;
          },
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    AdManager adManager = AdManager();

    return Consumer3<QuizProvider, SortProvider, AiCreditProvider>(
      builder: (context, quizProvider, sortProvider, aiCreditProvider, child) {
        return Stack(
          children: [
            ListView(
              children: [
                ReusableSortAndSeeAll(
                  dropdownValue: sortProvider.dropdownValueCard,
                  sortOptions: sortProvider.sortOptionsCard,
                  onSortChanged: (newValue) {
                    if (newValue != null) {
                      sortProvider.updateSortValueCard(newValue);
                      quizProvider.newValueCard = newValue;
                    }
                  },
                  isShowSeeAllLink: false,
                  isShowReviewLink: true,
                  onShowReviewLink: () {
                    showReviewSelection(
                      context: context,
                      heading: name,
                      cards: cards,
                      setname: name,
                    );
                  },
                  onSeeAllPressed: () {},
                ),
                adManager.getSixthBannerAdWidget(),
                cards.isEmpty
                    ? noCardWidget(context)
                    : SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height * 0.68,
                        child: ReusableQuizCardList(
                          name: name,
                          card: card,
                          onRemove: (quizSet) {
                            showDeleteConfirmationDialog(
                              context: context,
                              setName: name,
                              onDelete: () =>
                                  quizProvider.removeCardFromQuizSet(
                                quizSetName: name,
                                question: quizSet['question'],
                              ),
                            );
                          },
                          onEdit: (quizSet) {
                            quizProvider.questionController.text =
                                quizSet['question'];
                            quizProvider.answerController.text =
                                quizSet['answer'];
                            CreateCardBottomModal(
                              name: name,
                              context: context,
                              buttonName: "Edit Card",
                              isCreate: false,
                              cardName: quizSet['question'],
                              card: quizSet,
                            );
                          },
                          onIgnore: (name, quizSet) {
                            quizProvider.toggleIgnore(
                              quizSetName: name,
                              isIgnore: quizSet['isIgnore'],
                              question: quizSet['question'],
                            );
                          },
                          onKeyword: (quizSet) {
                            HighlightKeywordAlertBox(context, (keyword) {
                              quizProvider.updateKeyWordInQuizSet(
                                quizSetName: name,
                                oldKeyWord: quizSet['keyword'],
                                newKeyWord: keyword,
                              );
                            });
                          },
                          onRemoveKeyword: (quizSet) {
                            quizProvider.updateKeyWordInQuizSet(
                              quizSetName: name,
                              oldKeyWord: quizSet['keyword'],
                              newKeyWord: '',
                            );
                          },
                        ),
                      ),
              ],
            ),
            Positioned(
              bottom: 75,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${card['limitNumberOfQuiz'] - quizProvider.getNumberOfCardsInSet(name)} slot free out of ${card['limitNumberOfQuiz']}',
                ),
              ),
            ),
            if (card['limitNumberOfQuiz'] -
                    quizProvider.getNumberOfCardsInSet(name) !=
                0)
              ReusableCreateSetButtonPosition(
                icon: Icons.add_circle,
                colorScheme: colorScheme,
                name: 'Create Card',
                onTap: () {
                  CreateCardBottomModal(
                    context: context,
                    buttonName: "Add Card",
                    isCreate: true,
                    cardName: '',
                    card: card,
                    name: name,
                  );
                },
              )
            else
              aiCreditProvider.credits > 0
                  ? ReusableCreateSetButtonPosition(
                      colorScheme: colorScheme,
                      name: "Add More Slot",
                      onTap: () {
                        showAddSlotAlertDialog(
                            context: context,
                            onConfirm: () {
                              aiCreditProvider.useCredit(1);
                              quizProvider.updateQuizSetLimit(2);
                            });
                      },
                      icon: Icons.add_circle_rounded)
                  : ReusableRewardedAdsButtonPosition(
                      colorScheme: colorScheme,
                      name: "Watch Ad Free 5 Credits",
                    ),
            ReusableThemeSettingPosition(colorScheme: colorScheme),
          ],
        );
      },
    );
  }
}
