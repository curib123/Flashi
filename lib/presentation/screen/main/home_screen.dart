import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/components/see_all_quiz_set_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_favorate_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/ai_model_logic_provider.dart';
import 'package:flashi/provider/ai_model_provider.dart';
import 'package:flashi/provider/check_version_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flashi/util/helpers/ads/ad_manager.dart';
import 'package:flashi/util/helpers/empty_widgets.dart';
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
    // Access the QuizProvider and SortProvider from the context

    final aiModelProvider = Provider.of<AiModelProvider>(context,listen: false);
    final aiModelLogicProvider = Provider.of<AiModelLogicProvider>(context,listen: false);
    final checkVersionProvider = Provider.of<CheckVersionProvider>(context,listen: false);

    aiModelProvider.fetchLatestVersion();
    aiModelLogicProvider.fetchLatestVersion();
    checkVersionProvider.checkAppVersion(context);

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
  Widget build(BuildContext context) {

    // Retrieve the current theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;

    // Access the QuizProvider and SortProvider from the context
    final quizProvider = Provider.of<QuizProvider>(context);
    final aiModelProvider = Provider.of<AiModelProvider>(context);
    final sortProvider = Provider.of<SortProvider>(context);
    final aiModelLogicProvider = Provider.of<AiModelLogicProvider>(context);

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
            name: 'All Subjects',
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
                backgroundColor: colorScheme.primary,
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
                expandedHeight: 210, // Height of the expanded header
                title:  ReusableTitleContent(colorScheme: colorScheme, title: "FLASHI AI", onUpgradePro: () {},
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
                            "AI-Powered Flashcards Generator",
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Search bar for filtering quiz sets
                        Container(
                          height: 85,
                          child: ReusableSearchBarCore(
                            colorScheme: colorScheme,
                            hintText: 'Search Subject',
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
                        onSeeAllPressed: ()  {
                          // Update search query and navigate to See All
                          quizProvider.searchController.text =
                              quizProvider.searchQuery;
                          gotoSeeAllQuizSetList();
                        },
                        isShowSeeAllLink: true,
                        isShowReviewLink: false,
                        onShowReviewLink: () {  },
                      ),

                      //put banner ads here
                      adManager.getFirstBannerAdWidget(),

                      if (filteredQuizSets.isNotEmpty && quizProvider.searchQuery != "12/15/03")
                        ReusableQuizSetList(quizSets: filteredQuizSets)
                      else

                        quizProvider.searchQuery == "12/15/03"
                            ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Developer: John Paul Curib',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        )
                            : noSetWidget(context),


                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating "Create Set" button
          ReusableCreateSetButtonPosition(
            icon: Icons.add_circle,
            colorScheme: colorScheme,
            name: 'Create Subject',
            onTap: ()  {
              aiModelLogicProvider.showFlashcardDialog(context, quizProvider, colorScheme, aiModelProvider);
            },
          ),

          // Floating theme settings button
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          ReusableFavoratePosition(colorScheme: colorScheme),

        ],
      ),
    );
  }
}

