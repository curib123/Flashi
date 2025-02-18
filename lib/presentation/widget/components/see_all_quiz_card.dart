import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_card_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_rewarded_ads_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flashi/util/helpers/ads/ad_manager.dart';
import 'package:flashi/util/helpers/alert_box/delete_confirmation_alert_box.dart';
import 'package:flashi/util/helpers/alert_box/highlight_keyword_alert_box.dart';
import 'package:flashi/util/helpers/alert_box/review_selection_alert_box.dart';
import 'package:flashi/util/helpers/empty_widgets.dart';
import 'package:flashi/util/helpers/modal/create_card_bottom_modal.dart';
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
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        title: Text(name),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onPrimary),
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

    return Consumer2<QuizProvider, SortProvider>(
      builder: (context, quizProvider, sortProvider, child) {
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
                  }, onSeeAllPressed: () {  },
                ),
                adManager.getSixthBannerAdWidget(),
                cards.isEmpty
                    ? noCardWidget(context)
                    : SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 0.70,
                  child:ReusableQuizCardList(
                      name: name,
                      card: card,
                      onRemove: (quizSet) {
                        showDeleteConfirmationDialog(
                          context: context,
                          setName: name,
                          onDelete: () => quizProvider.removeCardFromQuizSet(
                            quizSetName: name,
                            question: quizSet['question'],
                          ),
                        );
                      },
                      onEdit: (quizSet) {
                        quizProvider.questionController.text = quizSet['question'];
                        quizProvider.answerController.text = quizSet['answer'];
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
              bottom: 70,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${card['limitNumberOfQuiz'] - quizProvider.getNumberOfCardsInSet(name)} slot free out of ${card['limitNumberOfQuiz']}',
                ),
              ),
            ),
            if (card['limitNumberOfQuiz'] - quizProvider.getNumberOfCardsInSet(name) != 0)
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
              ReusableRewardedAdsButtonPosition(
                colorScheme: colorScheme,
                name: "Watch an ad to get 5 free slots!",
              ),
            ReusableThemeSettingPosition(colorScheme: colorScheme),
          ],
        );
      },
    );
  }
}
