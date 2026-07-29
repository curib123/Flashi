import 'package:flashi/shared/widgets/core/reusable_search_bar_core.dart';
import 'package:flashi/features/quiz/presentation/widgets/create_quiz_set_button.dart';
import 'package:flashi/features/quiz/presentation/widgets/favorites_button.dart';
import 'package:flashi/features/quiz/presentation/widgets/quiz_import_button.dart';
import 'package:flashi/features/quiz/presentation/widgets/quiz_set_list.dart';
import 'package:flashi/shared/widgets/sort_section_header.dart';
import 'package:flashi/features/settings/presentation/widgets/theme_settings_button.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/features/ai/application/ai_generation_provider.dart';
import 'package:flashi/features/ai/application/generation_config_provider.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/features/history/application/history_provider.dart';
import 'package:flashi/core/state/sort_provider.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/shared/widgets/empty_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizSetsPage extends StatelessWidget {
  final String name;
  final ColorScheme colorScheme;

  const QuizSetsPage({
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
          },
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    AdManager adManager = AdManager();
    final historyProvider = context.read<HistoryProvider>();

    return Consumer5<QuizProvider, SortProvider, GenerationConfigProvider,
        AiGenerationProvider, AiCreditProvider>(
      builder: (context, quizProvider, sortProvider, fetchDataFromJsonProvider,
          aiModelLogicProvider, aiCreditProvider, child) {
        final filteredQuizSets =
            quizProvider.filteredQuizSets.reversed.toList();

        return Stack(
          children: [
            ListView(
              children: [
                SortSectionHeader(
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
                          child: QuizSetList(
                            quizSets: filteredQuizSets,
                          ),
                        ),
                      ),
              ],
            ),
            // Create Button Position
            CreateQuizSetButton(
              icon: Icons.add_circle,
              colorScheme: colorScheme,
              name: 'Generate Quiz Set',
              onTap: () {
                aiModelLogicProvider.showFlashcardDialog(
                    context,
                    quizProvider,
                    colorScheme,
                    fetchDataFromJsonProvider,
                    aiCreditProvider,
                    historyProvider);
              },
            ),

            ThemeSettingsButton(colorScheme: colorScheme),
            QuizImportButton(colorScheme: colorScheme),
            FavoritesButton(colorScheme: colorScheme),
          ],
        );
      },
    );
  }
}
