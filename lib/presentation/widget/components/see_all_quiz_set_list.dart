import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_favorate_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_import_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/ai_model_logic_provider.dart';
import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/core/state/sort_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/widget/other/empty_widgets.dart';
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

    return Scaffold(
      appBar: AppBar(
        foregroundColor: colorScheme.primary, // For text and icons color
        backgroundColor:
            colorScheme.onPrimary, // Background color of the app bar
        title: Text(name),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(),
        ),
        // Custom Back Arrow Icon
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new, // Custom Icon (back arrow)
            color: colorScheme.primary, // Custom color for the icon
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

    return Consumer5<QuizProvider, SortProvider, FetchDataFromJsonProvider,
        AiModelLogicProvider, AiCreditProvider>(
      builder: (context, quizProvider, sortProvider, fetchDataFromJsonProvider,
          aiModelLogicProvider, aiCreditProvider, child) {
        final filteredQuizSets =
            quizProvider.filteredQuizSets.reversed.toList();

        return Stack(
          children: [
            ListView(
              children: [
                ReusableSortAndSeeAll(
                  dropdownValue: sortProvider.dropdownValueSet,
                  sortOptions: sortProvider.sortOptionsSet,
                  onSortChanged: (newValue) {
                    if (newValue != null) {
                      sortProvider.updateSortValueSet(newValue);
                      quizProvider.sortQuizSets(
                          newValue); // Trigger sorting in the provider
                    }
                  },
                  onSeeAllPressed: () {
                    // Optional functionality if required
                  },
                  isShowSeeAllLink: false,
                  isShowReviewLink: false,
                  onShowReviewLink: () {},
                ),
                adManager.getFifthBannerAdWidget(),
                ReusableSearchBarCore(
                  colorScheme: colorScheme,
                  hintText: 'Search Quiz Set ',
                  onChanged: (value) {
                    quizProvider.updateSearchQuery(value);
                  },
                  controller: quizProvider.searchController,
                ),
                filteredQuizSets.isEmpty
                    ? noSetWidget(context)
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
              name: 'Generate Quiz Set',
              onTap: () {
                aiModelLogicProvider.showFlashcardDialog(context, quizProvider,
                    colorScheme, fetchDataFromJsonProvider, aiCreditProvider);
              },
            ),

            ReusableThemeSettingPosition(colorScheme: colorScheme),
            ReusableImportPosition(colorScheme: colorScheme),
            ReusableFavoratePosition(colorScheme: colorScheme),
          ],
        );
      },
    );
  }
}
