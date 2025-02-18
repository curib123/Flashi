import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/provider/ai_model_logic_provider.dart';
import 'package:flashi/provider/ai_model_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flashi/util/helpers/ads/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SeeAllQuizSetList extends StatelessWidget {
  final String name;
  final ColorScheme colorScheme;

  const SeeAllQuizSetList({
    super.key,
    required this.name,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {

    // Access both providers directly
    final quizProvider = Provider.of<QuizProvider>(context);
    AdManager adManager = AdManager();


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
    AdManager adManager = AdManager();

    return Consumer4<QuizProvider, SortProvider,AiModelProvider,AiModelLogicProvider>(
      builder: (context, quizProvider, sortProvider,aiModelProvider,aiModelLogicProvider, child) {
        final filteredQuizSets = quizProvider.filteredQuizSets.reversed.toList();

        return Stack(
          children: [
            ListView(
              children: [
                ReusableSearchBarCore(
                  colorScheme: colorScheme,
                  hintText: 'search subject name ',
                  onChanged: (value) {
                    quizProvider.updateSearchQuery(value);
                  }, controller: quizProvider.searchController,
                ),
                ReusableSortAndSeeAll(
                  dropdownValue: sortProvider.dropdownValueSet,
                  sortOptions: sortProvider.sortOptionsSet,
                  onSortChanged: (newValue) {
                    if (newValue != null) {
                      sortProvider.updateSortValueSet(newValue);
                      quizProvider.sortQuizSets(newValue); // Trigger sorting in the provider
                    }
                  },
                  onSeeAllPressed: () {
                    // Optional functionality if required
                  },
                  isShowSeeAllLink: false,
                  isShowReviewLink: false,
                  onShowReviewLink: () {  },
                ),
                adManager.getFifthBannerAdWidget(),

        filteredQuizSets.isEmpty
                    ? _noSetWidget(context)
                    : SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 0.60,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ReusableQuizSetList(
                      quizSets: filteredQuizSets,
                    ),
                  ),
                ),

              ],

            ),
            // Create Button Position
            ReusableCreateSetButtonPosition(
              icon: Icons.add_circle,
              colorScheme: colorScheme,
              name: 'Create Subject',
              onTap: () {
                aiModelLogicProvider.showFlashcardDialog(context, quizProvider, Theme.of(context).colorScheme, aiModelProvider);
              },
            ),
            ReusableThemeSettingPosition(colorScheme: colorScheme),
          ],
        );
      },
    );
  }
}

Widget _noSetWidget(BuildContext context) {
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
            "No Set available",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Create some Set to see them here.",
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