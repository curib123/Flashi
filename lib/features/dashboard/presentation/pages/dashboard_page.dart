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
import 'package:flashi/features/notes/application/notes_provider.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/shared/widgets/app_search_field.dart';
import 'package:flashi/shared/widgets/app_page_header.dart';
import 'package:flashi/features/quiz/presentation/widgets/quiz_set_list.dart';
import 'package:flashi/features/quiz/presentation/dialogs/quiz_set_form_sheet.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/features/quiz/data/services/quiz_import_export_service.dart';
import 'package:flashi/features/dashboard/presentation/dialogs/daily_question_dialog.dart';
import 'package:flashi/features/ai/presentation/dialogs/free_credits_dialog.dart';
import 'package:flashi/core/updates/presentation/app_update_dialog.dart';
import 'package:flashi/shared/widgets/empty_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AdManager _adManager = AdManager();
  Timer? _dailyRewardTimer;
  StreamSubscription<InternetStatus>? _connectionSubscription;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _adManager.loadInterstitialAd();
    _adManager.loadRewardedAd();
    _checkConnection();
    _connectionSubscription =
        InternetConnection().onStatusChange.listen((status) {
      if (!mounted) return;
      setState(() => _isOnline = status == InternetStatus.connected);
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

  Future<void> _checkConnection() async {
    final isOnline = await InternetConnection().hasInternetAccess;
    if (mounted) setState(() => _isOnline = isOnline);
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
    _dailyRewardTimer?.cancel();
    _connectionSubscription?.cancel();
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
    final notes = context.watch<NotesProvider>();
    final historyItems = context.watch<HistoryProvider>().history;
    final quizSets = quiz.filteredQuizSets.reversed.toList();
    final totalCards = quiz.quizSets.fold<int>(
      0,
      (total, set) => total + ((set['numberOfQuiz'] as num?)?.toInt() ?? 0),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'AI learning hub',
              description:
                  'Create, memorize, and review faster—with or without internet.',
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Turn anything into a study session',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ),
                                      _ConnectionBadge(isOnline: _isOnline),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _isOnline
                                        ? 'AI can build a quiz from a topic, document, or image. Everything you save stays available offline.'
                                        : 'You are offline. Your saved quizzes, notes, and review modes are still ready to use.',
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
                                    hintText: 'Search your quiz library',
                                    onChanged: quiz.updateSearchQuery,
                                    controller: quiz.searchController,
                                    prominent: true,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: _isOnline
                                          ? () =>
                                              generation.showFlashcardDialog(
                                                context,
                                                quiz,
                                                Theme.of(context).colorScheme,
                                                config,
                                                credits,
                                                history,
                                              )
                                          : null,
                                      icon: const Icon(Icons.auto_awesome),
                                      label: Text(
                                        _isOnline
                                            ? 'Create with AI'
                                            : 'AI creation needs internet',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Topic  •  PDF or document  •  Image or photo',
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _LearningOverview(
                              quizSets: quiz.quizSets.length,
                              cards: totalCards,
                              notes: notes.notes.length,
                              sessions: historyItems.length,
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
                            if (quizSets.isNotEmpty)
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

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: isOnline ? 'Online, AI available' : 'Offline mode',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(isOnline ? 'AI ready' : 'Offline'),
          ],
        ),
      ),
    );
  }
}

class _LearningOverview extends StatelessWidget {
  const _LearningOverview({
    required this.quizSets,
    required this.cards,
    required this.notes,
    required this.sessions,
  });

  final int quizSets;
  final int cards;
  final int notes;
  final int sessions;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your offline library',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Saved on this device and ready whenever you study.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Stat(label: 'Quiz sets', value: quizSets),
              _Stat(label: 'Study cards', value: cards),
              _Stat(label: 'Notes', value: notes),
              _Stat(label: 'Sessions', value: sessions),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value', style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
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
              icon: Icons.add_box_outlined,
              label: 'Create manually',
              onTap: () => showQuizSetFormSheet(
                context: context,
                buttonName: 'Save',
                isCreate: true,
                setName: '',
              ),
            ),
            _ActionCard(
              width: itemWidth,
              icon: Icons.import_export_outlined,
              label: 'Import backup',
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
