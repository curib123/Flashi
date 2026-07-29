import 'dart:math';

import 'package:flashi/app/app_shell.dart';
import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/app_surface.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/core/state/sort_provider.dart';
import 'package:flashi/core/updates/application/app_update_provider.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/features/ai/application/ai_generation_provider.dart';
import 'package:flashi/features/ai/application/generation_config_provider.dart';
import 'package:flashi/features/dashboard/application/daily_question_provider.dart';
import 'package:flashi/features/favorites/presentation/pages/favorites_page.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/features/settings/presentation/pages/settings_page.dart';
import 'package:flashi/presentation/widget/components/see_all_quiz_set_list.dart';
import 'package:flashi/shared/widgets/core/reusable_search_bar_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/classes/other/import_export_helper_class.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/daily_question_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_free_credits_dialog.dart';
import 'package:flashi/util/helpers/widget/modals/theme_modal.dart';
import 'package:flashi/util/helpers/widget/other/empty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AdManager _adManager = AdManager();

  @override
  void initState() {
    super.initState();
    _adManager.loadOpenAppAd(AdUnitId.appOpenAdUnitId);
    Future.delayed(const Duration(minutes: 5), () {
      _adManager.loadInterstitialAd(AdUnitId.interstitialAdUnitId);
    });

    final config = context.read<GenerationConfigProvider>();
    final generation = context.read<AiGenerationProvider>();
    final updates = context.read<AppUpdateProvider>();
    final dailyQuestions = context.read<DailyQuestionProvider>();

    config.fetchLatestVersion();
    generation.fetchLatestVersion();
    updates.checkAppVersion(context);
    dailyQuestions.updateFunFacts();

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      _showDailyRewards(
        context.read<AiCreditProvider>(),
        dailyQuestions,
      );
    });
  }

  Future<void> _showDailyRewards(
    AiCreditProvider credits,
    DailyQuestionProvider dailyQuestions,
  ) async {
    await _handleFreeCredits(credits);
    if (!mounted ||
        dailyQuestions.funFacts.isEmpty ||
        dailyQuestions.isAlreadyShow) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => DailyQuestionDialog(
        questions: dailyQuestions.funFacts,
      ),
    );
    dailyQuestions.toggleFunFacts();
  }

  Future<void> _handleFreeCredits(AiCreditProvider credits) async {
    if (!await credits.hasInternet()) return;
    final now = await credits.getNetworkTime();
    if (!mounted) return;

    final random = Random();
    if (credits.credits <= 10) {
      credits.updateAddedCredits(random.nextInt(4) + 4);
    } else if (credits.credits <= 15) {
      credits.updateAddedCredits(random.nextInt(3) + 3);
    } else {
      credits.updateAddedCredits(1);
    }

    if (credits.lastUpdated == null ||
        now.difference(credits.lastUpdated!).inDays > 0) {
      showFreeCreditsDialog(
        context: context,
        rewardText: 'You have free ${credits.addedCredits} energy',
        onClaim: () => credits.handleDataChange(now: now),
      );
    }
  }

  @override
  void dispose() {
    _adManager.showInterstitialAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final sort = context.watch<SortProvider>();
    final config = context.watch<GenerationConfigProvider>();
    final generation = context.read<AiGenerationProvider>();
    final credits = context.watch<AiCreditProvider>();
    final quizSets = quiz.filteredQuizSets.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        leading: MediaQuery.sizeOf(context).width < AppBreakpoints.medium
            ? const IconButton(
                tooltip: 'Open navigation',
                onPressed: AppShell.openNavigation,
                icon: Icon(Icons.menu),
              )
            : null,
        title: const Text('Learn'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ResponsiveContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Build your next study session',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Generate, organize, and review learning material.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppSurface(
                      child: Column(
                        children: [
                          ReusableSearchBarCore(
                            colorScheme: Theme.of(context).colorScheme,
                            hintText: 'Search quiz sets',
                            onChanged: quiz.updateSearchQuery,
                            controller: quiz.searchController,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => generation.showFlashcardDialog(
                                context,
                                quiz,
                                Theme.of(context).colorScheme,
                                config,
                                credits,
                              ),
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Generate quiz'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _QuickActions(quizProvider: quiz),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Quiz sets',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: sort.dropdownValueSet,
                            items: sort.sortOptionsSet
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              sort.updateSortValueSet(value);
                              quiz.sortQuizSets(value);
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () => _openAllQuizSets(quiz),
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    _adManager.getFirstBannerAdWidget(),
                    const SizedBox(height: AppSpacing.md),
                    if (quizSets.isEmpty)
                      noSetWidget(context)
                    else
                      ReusableQuizSetList(quizSets: quizSets),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAllQuizSets(QuizProvider quiz) {
    quiz.searchController.text = quiz.searchQuery;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeeAllQuizSetList(
          name: 'All Quiz Set',
          colorScheme: Theme.of(context).colorScheme,
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.quizProvider});

  final QuizProvider quizProvider;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 720 ? 4 : 2;
        final itemWidth = (width - (AppSpacing.sm * (columns - 1))) / columns;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _ActionCard(
              width: itemWidth,
              icon: Icons.import_export_outlined,
              label: 'Import',
              onTap: () => ImportExportHelperClass().importList(
                context,
                quizProvider,
              ),
            ),
            _ActionCard(
              width: itemWidth,
              icon: Icons.favorite_border,
              label: 'Favorites',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              ),
            ),
            _ActionCard(
              width: itemWidth,
              icon: Icons.lightbulb_outline,
              label: 'Daily question',
              onTap: () {
                final questions =
                    context.read<DailyQuestionProvider>().funFacts;
                showDialog<void>(
                  context: context,
                  builder: (_) => DailyQuestionDialog(questions: questions),
                );
              },
            ),
            _ActionCard(
              width: itemWidth,
              icon: Icons.contrast_outlined,
              label: 'Appearance',
              onTap: () => openThemeSelector(context),
            ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(AppSpacing.md),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
