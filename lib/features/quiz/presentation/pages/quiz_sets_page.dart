import 'package:flashi/app/navigation/app_router.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/core/state/sort_provider.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/features/ai/application/ai_generation_provider.dart';
import 'package:flashi/features/ai/application/generation_config_provider.dart';
import 'package:flashi/features/history/application/history_provider.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/features/quiz/data/services/quiz_import_export_service.dart';
import 'package:flashi/features/quiz/presentation/widgets/quiz_set_list.dart';
import 'package:flashi/features/settings/presentation/dialogs/theme_dialog.dart';
import 'package:flashi/shared/widgets/app_page_header.dart';
import 'package:flashi/shared/widgets/app_search_field.dart';
import 'package:flashi/shared/widgets/empty_state_widgets.dart';
import 'package:flashi/shared/widgets/sort_section_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizSetsPage extends StatelessWidget {
  const QuizSetsPage({
    required this.name,
    required this.colorScheme,
    super.key,
  });

  final String name;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final quiz = context.read<QuizProvider>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: name,
              description: 'Search, organize, and manage your quiz library.',
              leading: BackButton(
                onPressed: () {
                  Navigator.pop(context);
                  quiz.searchController.text = quiz.searchQuery;
                },
              ),
              actions: [
                IconButton(
                  tooltip: 'Favorites',
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.favorites,
                  ),
                  icon: const Icon(Icons.favorite_border),
                ),
                IconButton(
                  tooltip: 'Appearance',
                  onPressed: () => openThemeSelector(context),
                  icon: const Icon(Icons.contrast_outlined),
                ),
              ],
            ),
            const Expanded(child: _QuizLibrary()),
          ],
        ),
      ),
    );
  }
}

class _QuizLibrary extends StatelessWidget {
  const _QuizLibrary();

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final sort = context.watch<SortProvider>();
    final config = context.watch<GenerationConfigProvider>();
    final generation = context.read<AiGenerationProvider>();
    final credits = context.watch<AiCreditProvider>();
    final history = context.read<HistoryProvider>();
    final quizSets = quiz.filteredQuizSets.reversed.toList();
    final colors = Theme.of(context).colorScheme;
    final adManager = AdManager();

    return ResponsiveContent(
      child: Column(
        children: [
          AppSearchField(
            colorScheme: colors,
            hintText: 'Search quiz sets',
            onChanged: quiz.updateSearchQuery,
            controller: quiz.searchController,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => generation.showFlashcardDialog(
                    context,
                    quiz,
                    colors,
                    config,
                    credits,
                    history,
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate quiz'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.outlined(
                tooltip: 'Import quiz sets',
                onPressed: () =>
                    QuizImportExportService().importList(context, quiz),
                icon: const Icon(Icons.file_upload_outlined),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SortSectionHeader(
            dropdownValue: sort.dropdownValueSet,
            sortOptions: sort.sortOptionsSet,
            onSortChanged: (value) {
              if (value == null) return;
              sort.updateSortValueSet(value);
              quiz.sortQuizSets(value);
            },
            onSeeAllPressed: () {},
            isShowSeeAllLink: false,
            isShowReviewLink: false,
            onShowReviewLink: () {},
          ),
          adManager.getFifthBannerAdWidget(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: quizSets.isEmpty
                ? noSetWidget(context)
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                    child: QuizSetList(quizSets: quizSets),
                  ),
          ),
        ],
      ),
    );
  }
}
