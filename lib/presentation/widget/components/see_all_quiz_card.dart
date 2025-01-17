import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_quiz_card_list.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_rewarded_ads_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/provider/sort_provider.dart';
import 'package:flashlearn/util/helpers/ads/ads_manager.dart';
import 'package:flashlearn/util/helpers/alert_box/delete_confirmation_alert_box.dart';
import 'package:flashlearn/util/helpers/alert_box/review_selection_alert_box.dart';
import 'package:flashlearn/util/helpers/modal/create_card_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SeeAllQuizCard extends StatelessWidget {
  final String name;
  final int index;
  final ColorScheme colorScheme;
  final  Map<String, dynamic> card;
  final  List< dynamic> cards;

  const SeeAllQuizCard({
    super.key,
    required this.name,
    required this.colorScheme,
    required this.card,
    required this.index, required this.cards,
  });

  @override
  Widget build(BuildContext context) {

    // Access both providers directly
    final quizProvider = Provider.of<QuizProvider>(context);



    return Scaffold(
      appBar: AppBar(
        foregroundColor: colorScheme.onPrimary, // For text and icons color
        backgroundColor: colorScheme.primary, // Background color of the app bar
        title: Text(name),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        // Custom Back Arrow Icon
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new, // Custom Icon (back arrow)
            color: colorScheme.onPrimary, // Custom color for the icon
          ),
          onPressed: () {

            Navigator.pop(context); // Go back to the previous screen
            quizProvider.searchController.text = quizProvider.searchQuery;
            print(quizProvider.searchQuery);
          },
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final AdManager adManager = AdManager();

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
                      quizProvider.newValueCard = newValue; // Trigger sorting in the provider

                    }
                  },
                  onSeeAllPressed: () {
                    // Optional functionality if required
                  },
                  isShowSeeAllLink: false,
                  isShowReviewLink: true,
                  onShowReviewLink: () {
                    showReviewSelection(
                        context: context,
                        heading: name,
                        cards: cards,
                        setname: name);
                  },
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 0.70,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ReusableQuizCardList(
                      name: name,
                      card: card,
                      onRemove: (quizSet) {
                       showDeleteConfirmationDialog(
                           context: context,
                           setName: name,
                           onDelete: () => {
                             quizProvider.removeCardFromQuizSet(
                                 quizSetName: name,
                                 question:  quizSet['question'])
                           } );
                      },
                      onEdit: (quizSet) {
                      quizProvider.questionController.text =  quizSet['question'];
                      quizProvider.answerController.text =  quizSet['answer'];
                      CreateCardBottomModal(
                        name: name,
                        context: context,
                        buttonName: "Edit Card",
                        isCreate: false,
                        cardName: quizSet['question'],
                        card: quizSet,
                      );
                    },
                      onIgnore: (name,quizSet) {
                        quizProvider.toggleIgnore(
                            quizSetName: name,
                            isIgnore: quizSet['isIgnore'],
                            question: quizSet['question']);
                      },),
                  ),
                ),
              ],
            ),

           Positioned(
             bottom: 60,
               left: 0,
               right: 0,
               child: Center(child: Text('${ card['limitNumberOfQuiz'] - quizProvider.getNumberOfCardsInSet(name) } slot free out of ${card['limitNumberOfQuiz']}')),),
            // Create Button Position
            card['limitNumberOfQuiz'] - quizProvider.getNumberOfCardsInSet(name) != 0 ? ReusableCreateSetButtonPosition(
              colorScheme: colorScheme,
              name: 'Create Card',
              onTap: () {
                CreateCardBottomModal(
                    context: context,
                    buttonName: "Add Card",
                    isCreate: true,
                    cardName: '',
                    card: card,
                    name: name );
              },
            ) : ReusableRewardedAdsButtonPosition(colorScheme: colorScheme, name: "Watch an ad to get 5 free slot!"),
            ReusableThemeSettingPosition(
                colorScheme: colorScheme
            ),
          ],
        );
      },
    );
  }
}
