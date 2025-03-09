import 'dart:math';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/components/see_all_quiz_set_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_daily_quest_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_favorate_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_import_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/DailyQuestionProvider.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/ai_model_logic_provider.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/chatbot_provider.dart';
import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/provider/check_version_provider.dart';
import 'package:flashi/provider/notes_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/classes/ads/app_lifecycle_reactor.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/showDailyQuestionDialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_free_credits_dialog.dart';
import 'package:flashi/util/helpers/widget/other/empty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  AdManager adManager = AdManager();
  late AppLifecycleReactor appLifecycleReactor;

  @override
  void initState() {
    super.initState();

    AdManager adManager = AdManager()..loadOpenAppAd(AdUnitId.appOpenAdUnitId);
    appLifecycleReactor = AppLifecycleReactor(
        adManager: adManager);
    Future.delayed(Duration(minutes: 5),(){
      adManager.loadInterstitialAd(AdUnitId.interstitialAdUnitId);
    });

    final fetchDataFromJsonProvider = Provider.of<FetchDataFromJsonProvider>(context,listen: false);
    final aiModelLogicProvider = Provider.of<AiModelLogicProvider>(context,listen: false);
    final checkVersionProvider = Provider.of<CheckVersionProvider>(context,listen: false);
    final aiCreditProvider = Provider.of<AiCreditProvider>(context,listen: false);
    final dailyQuestionProvider = Provider.of<DailyQuestionProvider>(context,listen: false);
    final authProvider = Provider.of<AuthProvider>(context,listen: false);
    final quizProvider = Provider.of<QuizProvider>(context,listen: false);
    final notesProvider = Provider.of<NotesProvider>(context,listen: false);
    final chatBotProvider = Provider.of<ChatBotProvider>(context,listen: false);

    fetchDataFromJsonProvider.fetchLatestVersion();
    aiModelLogicProvider.fetchLatestVersion();
    checkVersionProvider.checkAppVersion(context);
    dailyQuestionProvider.updateFunFacts(fetchDataFromJsonProvider);

    Future.delayed(Duration(seconds: 3),() async {

     await authProvider.saveFlashcards(authProvider.user_id,quizProvider.quizSets);
     await authProvider.saveUserCredits(authProvider.user_id, aiCreditProvider.credits);
     await authProvider.saveNotes(authProvider.user_id, notesProvider.notes);
     await authProvider.saveChatBotMessages(authProvider.user_id, chatBotProvider.messages);

    });

    Future.delayed(Duration(seconds: 5),(){
      print(dailyQuestionProvider.funFacts);
      handleFreeCreditsDialog(aiCreditProvider, context);
      if (dailyQuestionProvider.funFacts.isNotEmpty && !dailyQuestionProvider.isAlreadyShow) {
        showDailyQuestionDialog(context, questions: dailyQuestionProvider.funFacts) ;
        dailyQuestionProvider.toggleFunFacts();
      }
    });



  }


  void handleFreeCreditsDialog(AiCreditProvider aiCreditProvider,BuildContext context) async{
        if (await aiCreditProvider.hasInternet()) {
          final now = await aiCreditProvider.getNetworkTime();
          final random = Random();

          print(now);
          print(aiCreditProvider.lastUpdated);

          if (aiCreditProvider.credits <= 10) {
            aiCreditProvider.updateAddedCredits(random.nextInt(6) + 10);
          } else if (aiCreditProvider.credits > 10 && aiCreditProvider.credits <= 15) {
           aiCreditProvider.updateAddedCredits( random.nextInt(6) + 7);
          } else if (aiCreditProvider.credits > 15 && aiCreditProvider.credits <= 20) {
           aiCreditProvider.updateAddedCredits(random.nextInt(5) + 5);
          } else {
           aiCreditProvider.updateAddedCredits(random.nextInt(5) + 3);
          }

          if (aiCreditProvider.lastUpdated == null || now.difference(aiCreditProvider.lastUpdated!).inDays > 0) {
            showFreeCreditsDialog(
              context: context,
              rewardText: "You have free ${aiCreditProvider.addedCredits} energy",
              onClaim: () async {
                await aiCreditProvider.handleDataChange(now: now);
              },
            );

          }
        };

  }

  void change(QuizProvider quizProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        quizProvider.updateDefaultMaxCard(
            quizProvider.searchQuery == "12/15/03" ? 99999 : 20);
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    adManager.showInterstitialAd();
  }
  @override
  Widget build(BuildContext context) {

    // Retrieve the current theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;

    // Access the QuizProvider and SortProvider from the context
    final quizProvider = Provider.of<QuizProvider>(context);
    final fetchDataFromJsonProvider = Provider.of<FetchDataFromJsonProvider>(context);
    final sortProvider = Provider.of<SortProvider>(context);
    final aiModelLogicProvider = Provider.of<AiModelLogicProvider>(context);
    final aiCreditProvider = Provider.of<AiCreditProvider>(context);

    // Reverse the filtered quiz sets for display
    final filteredQuizSets = quizProvider.filteredQuizSets.reversed.toList();

    AdManager adManager = AdManager();


    change(quizProvider);

    // Navigate to the SeeAllQuizSetList screen
    void gotoSeeAllQuizSetList() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeeAllQuizSetList(
            name: 'All Flashcard',
            colorScheme: colorScheme,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main scrollable content using CustomScrollView
          RefreshIndicator(
            onRefresh: () {
              setState(() {});
              return Future.delayed(Duration.zero);
            },
            child: CustomScrollView(
              slivers: [
                // SliverAppBar for a custom collapsing header
                SliverAppBar(
                  backgroundColor: colorScheme.primary.withOpacity(0.9),
                  leading: GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Icon(
                      Icons.notes_rounded,
                      size: 30,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  pinned: true, // Keeps the header visible when scrolling
                  floating: true, // Header doesn't float when scrolling
                  expandedHeight: 190, // Height of the expanded header
                  title:  ReusableTitleContent(colorScheme: colorScheme, title: "FLASHI", onUpgradePro: () {},
                      onSettings: () {
            
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
            
                      }),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Learn Smarter Retain Faster",
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          // Search bar for filtering quiz sets
                          Container(
                            height: 80,
                            child: ReusableSearchBarCore(
                              colorScheme: colorScheme,
                              hintText: 'Search Flashcards',
                              onChanged: (value) =>
                                  quizProvider.updateSearchQuery(value),
                              controller: quizProvider.searchController,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
            
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(35),
                      bottomLeft: Radius.circular(35),
                    ),
                  ),
                ),
            
                // Content section below the header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 200,right: 2,left: 2),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            // Sorting and "See All" button
                           Column(
                             children: [
                               ReusableSortAndSeeAll(
                                 dropdownValue: sortProvider.dropdownValueSet,
                                 sortOptions: sortProvider.sortOptionsSet,
                                 onSortChanged: (newValue) {
                                   sortProvider.updateSortValueSet(newValue!);
                                   quizProvider.sortQuizSets(newValue);
                                 },
                                 onSeeAllPressed: ()  {
                                   quizProvider.searchController.text = quizProvider.searchQuery;
                                   gotoSeeAllQuizSetList();
                                 },
                                 isShowSeeAllLink: true,
                                 isShowReviewLink: false,
                                 onShowReviewLink: () { },
                               ),
                               // Positioned Banner Ads (Floating Above the Content)
                               adManager.getFirstBannerAdWidget(),
                             ],
                           ),
            
                            // Quiz set list or message
                            if (filteredQuizSets.isNotEmpty)
                              ReusableQuizSetList(quizSets: filteredQuizSets)
                            else
                              noSetWidget(context)
            
                          ],
                        ),
            
            
                      ],
                    )
            
                  ),
                ),
              ],
            ),
          ),

          // Floating "Create Set" button
          ReusableCreateSetButtonPosition(
            icon: Icons.add_circle,
            colorScheme: colorScheme,
            name: 'Create Flashcard',
            onTap: ()  {
              aiModelLogicProvider.showFlashcardDialog(context, quizProvider, colorScheme,fetchDataFromJsonProvider,aiCreditProvider);
            },
          ),

          // Floating theme settings button
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          ReusableDailyQuestPosition(colorScheme: colorScheme),
          ReusableImportPosition(colorScheme: colorScheme),
          ReusableFavoratePosition(colorScheme: colorScheme),

        ],
      ),
    );
  }
}

