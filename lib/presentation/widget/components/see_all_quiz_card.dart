import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_quiz_card_list.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_rewarded_ads_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/provider/sort_provider.dart';
import 'package:flashlearn/util/helpers/ads/ad_helper.dart';
import 'package:flashlearn/util/helpers/alert_box/delete_confirmation_alert_box.dart';
import 'package:flashlearn/util/helpers/alert_box/highlight_keyword_alert_box.dart';
import 'package:flashlearn/util/helpers/alert_box/review_selection_alert_box.dart';
import 'package:flashlearn/util/helpers/modal/create_card_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class SeeAllQuizCard extends StatefulWidget {
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
  State<SeeAllQuizCard> createState() => _SeeAllQuizCardState();
}

class _SeeAllQuizCardState extends State<SeeAllQuizCard> {


  var startAppSdk = StartAppSdk();

  StartAppBannerAd? bannerAd;



  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
    //  startAppSdk.setTestAdsEnabled(true);
    startAppSdk.setTestAdsEnabled(AdHelper.isTestEnabled);

    // TODO use one of the following types: BANNER, MREC, COVER
    startAppSdk.loadBannerAd(StartAppBannerType.MREC).then((bannerAd) {
      setState(() {
        this.bannerAd = bannerAd;

      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");

    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");

    });
  }



  @override
  Widget build(BuildContext context) {

    // Access both providers directly
    final quizProvider = Provider.of<QuizProvider>(context);



    return Scaffold(
      appBar: AppBar(
        foregroundColor: widget.colorScheme.onPrimary, // For text and icons color
        backgroundColor: widget.colorScheme.primary, // Background color of the app bar
        title: Text(widget.name),
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
            color: widget.colorScheme.onPrimary, // Custom color for the icon
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
                        heading: widget.name,
                        cards: widget.cards,
                        setname: widget.name);
                  },
                ),
                bannerAd != null ? StartAppBanner(bannerAd!) : Container(),
                widget.cards.isEmpty
                    ? _noCardWidget(context)
                    :SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 0.70,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ReusableQuizCardList(
                      name: widget.name,
                      card: widget.card,
                      onRemove: (quizSet) {
                       showDeleteConfirmationDialog(
                           context: context,
                           setName: widget.name,
                           onDelete: () => {
                             quizProvider.removeCardFromQuizSet(
                                 quizSetName: widget.name,
                                 question:  quizSet['question'])
                           } );
                      },
                      onEdit: (quizSet) {
                      quizProvider.questionController.text =  quizSet['question'];
                      quizProvider.answerController.text =  quizSet['answer'];
                      CreateCardBottomModal(
                        name: widget.name,
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
                      },
                      onKeyword: (quizSet) {
                       HighlightKeywordAlertBox(context, (keyword) {
                         quizProvider.updateKeyWordInQuizSet(quizSetName: widget.name, oldKeyWord: quizSet['keyword'], newKeyWord: keyword);
                       });
                      },
                      onRemoveKeyword: ( quizSet) {
                        quizProvider.updateKeyWordInQuizSet(quizSetName: widget.name, oldKeyWord:quizSet['keyword'] , newKeyWord: '');
                      },),
                  ),
                ),
              ],
            ),

           Positioned(
             bottom: 60,
               left: 0,
               right: 0,
               child: Center(child: Text('${ widget.card['limitNumberOfQuiz'] - quizProvider.getNumberOfCardsInSet(widget.name) } slot free out of ${widget.card['limitNumberOfQuiz']}')),),
            // Create Button Position
            widget.card['limitNumberOfQuiz'] - quizProvider.getNumberOfCardsInSet(widget.name) != 0 ? ReusableCreateSetButtonPosition(
              icon: Icons.add_circle,
              colorScheme: widget.colorScheme,
              name: 'Create Card',
              onTap: () {
                CreateCardBottomModal(
                    context: context,
                    buttonName: "Add Card",
                    isCreate: true,
                    cardName: '',
                    card: widget.card,
                    name: widget.name );
              },
            ) : ReusableRewardedAdsButtonPosition(colorScheme: widget.colorScheme, name: "Watch an ad to get 5 free slot!"),
            ReusableThemeSettingPosition(
                colorScheme: widget.colorScheme
            ),
          ],
        );
      },
    );
  }
}


Widget _noCardWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.30,
    width: MediaQuery.of(context).size.width,
    child:   Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "No Cards available",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Create some Cards to see them here.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}