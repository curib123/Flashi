import 'dart:async';
import 'dart:math';

import 'package:flashi/app/app_shell.dart';
import 'package:flashi/app/navigation/app_router.dart';
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
import 'package:flashi/features/history/application/history_provider.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/shared/widgets/app_search_field.dart';
import 'package:flashi/shared/widgets/app_page_header.dart';
import 'package:flashi/features/quiz/presentation/widgets/quiz_set_list.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/core/ads/ad_unit_id.dart';
import 'package:flashi/features/quiz/data/services/quiz_import_export_service.dart';
import 'package:flashi/features/dashboard/presentation/dialogs/daily_question_dialog.dart';
import 'package:flashi/features/ai/presentation/dialogs/free_credits_dialog.dart';
import 'package:flashi/core/updates/presentation/app_update_dialog.dart';
import 'package:flashi/features/settings/presentation/dialogs/theme_dialog.dart';
import 'package:flashi/shared/widgets/empty_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AdManager _adManager = AdManager();
  Timer? _adPreloadTimer;
  Timer? _dailyRewardTimer;

  @override
  void initState() {
    super.initState();
    _adManager.loadOpenAppAd(AdUnitId.appOpenAdUnitId);
    _adPreloadTimer = Timer(const Duration(seconds: 20), () {
      _adManager.loadInterstitialAd(AdUnitId.interstitialAdUnitId);
    });

    final config = context.read<GenerationConfigProvider>();
    final generation = context.read<AiGenerationProvider>();
    final updates = context.read<AppUpdateProvider>();
    final dailyQuestions = context.read<DailyQuestionProvider>();

    config.fetchLatestVersion();
    generation.fetchLatestVersion();
    _checkForUpdates(updates);
    dailyQuestions.updateFunFacts();

    _dailyRewardTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _showDailyRewards(
        context.read<AiCreditProvider>(),
        dailyQuestions,
      );
    });
  }

  Future<void> _checkForUpdates(AppUpdateProvider updates) async {
    final hasUpdate = await updates.checkAppVersion();
    if (!mounted || !hasUpdate) return;
    showAppUpdateDialog(
      context,
      updates.currentVersion,
      updates.latestVersion,
      updates.downloadLink,
      updates.patchNote,
    );
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
    await showAppDialog<void>(
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
    _adPreloadTimer?.cancel();
    _dailyRewardTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final sort = context.watch<SortProvider>();
    final config = context.watch<GenerationConfigProvider>();
    final generation = context.read<AiGenerationProvider>();
    final credits = context.watch<AiCreditProvider>();
    final history = context.read<HistoryProvider>();
    final quizSets = quiz.filteredQuizSets.reversed.toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Learning workspace',
              description: 'Create a focused study session in a few steps.',
              leading: MediaQuery.sizeOf(context).width < AppBreakpoints.medium
                  ? const IconButton(
                      tooltip: 'Open navigation',
                      onPressed: AppShell.openNavigation,
                      icon: Icon(Icons.menu),
                    )
                  : null,
              actions: [
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.settings,
                  ),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ResponsiveContent(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppSurface(
                              emphasized: true,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'What will you learn today?',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Search your library or generate a new quiz.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  AppSearchField(
                                    colorScheme: Theme.of(context).colorScheme,
                                    hintText: 'Search quiz sets',
                                    onChanged: quiz.updateSearchQuery,
                                    controller: quiz.searchController,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: () =>
                                          generation.showFlashcardDialog(
                                        context,
                                        quiz,
                                        Theme.of(context).colorScheme,
                                        config,
                                        credits,
                                        history,
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
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
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
                              QuizSetList(quizSets: quizSets),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
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
    Navigator.pushNamed(
      context,
      AppRoutes.quizSets,
      arguments: 'All Quiz Set',
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
              onTap: () => QuizImportExportService().importList(
                context,
                quizProvider,
              ),
            ),
            _ActionCard(
              width: itemWidth,
              icon: Icons.favorite_border,
              label: 'Favorites',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.favorites,
              ),
            ),
            _ActionCard(
              width: itemWidth,
              icon: Icons.lightbulb_outline,
              label: 'Daily question',
              onTap: () {
                final questions =
                    context.read<DailyQuestionProvider>().funFacts;
                showAppDialog<void>(
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
