import 'package:flashlearn/presentation/screen/main/settings_screen.dart';
import 'package:flashlearn/presentation/widget/components/see_all_quiz_set_list.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/provider/sort_provider.dart';
import 'package:flashlearn/util/helpers/ads/ad_unit_id.dart';
import 'package:flashlearn/util/helpers/ads/ads_manager.dart';
import 'package:flashlearn/util/helpers/modal/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    // Load ads with test ad unit IDs
    AdManager adManager = AdManager();
    // Load the ads using the platform-specific ad unit IDs
    adManager.loadBannerAd(AdUnitIds.bannerAdUnitId);
    adManager.loadInterstitialAd(AdUnitIds.interstitialAdUnitId);
    adManager.loadRewardedAd(AdUnitIds.rewardedAdUnitId);
  }

  @override
  Widget build(BuildContext context) {


    final AdManager adManager = AdManager();

    // Retrieve the current theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;

    // Access the QuizProvider and SortProvider from the context
    final quizProvider = Provider.of<QuizProvider>(context);
    final sortProvider = Provider.of<SortProvider>(context);

    // Reverse the filtered quiz sets for display
    final filteredQuizSets = quizProvider.filteredQuizSets.reversed.toList();

    // Navigate to the SeeAllQuizSetList screen
    void gotoSeeAllQuizSetList() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeeAllQuizSetList(
            name: 'See All Set Of Quiz',
            colorScheme: colorScheme,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main scrollable content using CustomScrollView
          CustomScrollView(
            slivers: [
              // SliverAppBar for a custom collapsing header
              SliverAppBar(
                leading: GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Icon(
                    Icons.notes_rounded,
                    size: 30,
                    color: colorScheme.onPrimary,
                  ),
                ),
                pinned: true, // Keeps the header visible when scrolling
                floating: false, // Header doesn't float when scrolling
                expandedHeight: 200, // Height of the expanded header
                title:  ReusableTitleContent(colorScheme: colorScheme, title: "FlashLearn", onUpgradePro: () {},
                    onSettings: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );

                    }),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    margin: const EdgeInsets.all(10),
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                          "FlashCards for Faster Learning",
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Search bar for filtering quiz sets
                        Container(
                          height: 85,
                          child: ReusableSearchBarCore(
                            colorScheme: colorScheme,
                            hintText: 'Search Set Here',
                            onChanged: (value) =>
                                quizProvider.updateSearchQuery(value),
                            controller: quizProvider.searchController,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                backgroundColor: colorScheme.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
              ),

              // Content section below the header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 200,right: 2,left: 2),
                  child: Column(
                    children: [
                      // Sorting and "See All" button
                      ReusableSortAndSeeAll(
                        dropdownValue: sortProvider.dropdownValueSet,
                        sortOptions: sortProvider.sortOptionsSet,
                        onSortChanged: (newValue) {
                          sortProvider.updateSortValueSet(newValue!);
                          quizProvider.sortQuizSets(newValue);
                        },
                        onSeeAllPressed: () {
                          // Update search query and navigate to See All
                          quizProvider.searchController.text =
                              quizProvider.searchQuery;
                          gotoSeeAllQuizSetList();
                        },
                        isShowSeeAllLink: true,
                        isShowReviewLink: false,
                        onShowReviewLink: () {  },
                      ),
                      const SizedBox(height:5),
                      adManager.getFirstBannerAdWidget(),
                      const SizedBox(height:5),

                      // Show a message if no quiz sets are available
                      if (filteredQuizSets.isNotEmpty && quizProvider.searchQuery != "list of gays")
                      // Display quiz sets in a reusable list
                        ReusableQuizSetList(quizSets: filteredQuizSets)
                      else if (quizProvider.searchQuery == "list of gays")
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueGrey.shade50,
                                  blurRadius: 2.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jeremiah Palatan',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 10), // Space between items
                                Text(
                                  'Dzey Saavedra',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Christian Dior',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Peter The Racist',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )

                      else
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No quiz sets available.',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        )


                    ],
                  ),
                ),
              ),
            ],
          ),

         // Floating "Create Set" button
          ReusableCreateSetButtonPosition(
            colorScheme: colorScheme,
            name: 'Create Set',
            onTap: () async {
              // Navigate to See All and then show a modal
              gotoSeeAllQuizSetList();
              await Future.delayed(const Duration(seconds: 1));
              CreateSetBottomModal(
                context: context,
                buttonName: 'Save',
                isCreate: true,
                setName: '',
              );
            },
          ),

          // Floating theme settings button
          ReusableThemeSettingPosition(colorScheme: colorScheme),

        ],
      ),
    );
  }
}
