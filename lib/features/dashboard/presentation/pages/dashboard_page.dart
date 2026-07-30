import 'dart:async';

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
import 'package:flashi/features/history/application/history_provider.dart';
import 'package:flashi/features/notes/application/notes_provider.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/shared/widgets/app_search_field.dart';
import 'package:flashi/shared/widgets/app_page_header.dart';
import 'package:flashi/features/quiz/presentation/widgets/quiz_set_list.dart';
import 'package:flashi/features/quiz/presentation/dialogs/quiz_set_form_sheet.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/features/quiz/data/services/quiz_import_export_service.dart';
import 'package:flashi/core/updates/presentation/app_update_dialog.dart';
import 'package:flashi/shared/widgets/empty_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AdManager _adManager = AdManager();
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

    config.fetchLatestVersion();
    generation.fetchLatestVersion();
    _checkForUpdates(updates);
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

  @override
  void dispose() {
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
    final allMatches = quiz.filteredQuizSets.reversed.toList();
    final quizSets = allMatches
        .take(quiz.searchQuery.trim().isEmpty ? 3 : 8)
        .toList(growable: false);
    final totalCards = quiz.quizSets.fold<int>(
      0,
      (total, set) => total + ((set['numberOfQuiz'] as num?)?.toInt() ?? 0),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Home',
              description: 'Pick up where you left off.',
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
                                          'What do you want to learn?',
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
                                        ? 'Create a focused quiz from a topic, document, or image.'
                                        : 'Your saved quizzes and notes are ready offline.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Wrap(
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.sm,
                                    children: [
                                      FilledButton.icon(
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
                                      OutlinedButton.icon(
                                        onPressed: () => showQuizSetFormSheet(
                                          context: context,
                                          buttonName: 'Save',
                                          isCreate: true,
                                          setName: '',
                                        ),
                                        icon: const Icon(Icons.edit_outlined),
                                        label: const Text('Create manually'),
                                      ),
                                    ],
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
                            const SizedBox(height: AppSpacing.sm),
                            AppSearchField(
                              colorScheme: Theme.of(context).colorScheme,
                              hintText: 'Search quiz sets',
                              onChanged: quiz.updateSearchQuery,
                              controller: quiz.searchController,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _LibraryActions(quizProvider: quiz),
                            const SizedBox(height: AppSpacing.md),
                            if (quizSets.isEmpty)
                              noSetWidget(context)
                            else
                              QuizSetList(quizSets: quizSets),
                            if (quizSets.isNotEmpty)
                              _adManager.getFirstBannerAdWidget(),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(child: _Stat(label: 'Sets', value: quizSets)),
          const _StatDivider(),
          Expanded(child: _Stat(label: 'Cards', value: cards)),
          const _StatDivider(),
          Expanded(child: _Stat(label: 'Notes', value: notes)),
          const _StatDivider(),
          Expanded(child: _Stat(label: 'Sessions', value: sessions)),
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
    return Semantics(
      label: '$value $label',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value', style: Theme.of(context).textTheme.titleMedium),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child:
          VerticalDivider(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}

class _LibraryActions extends StatelessWidget {
  const _LibraryActions({required this.quizProvider});

  final QuizProvider quizProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.favorites),
          icon: const Icon(Icons.favorite_border_rounded),
          label: const Text('Favorites'),
        ),
        TextButton.icon(
          onPressed: () =>
              QuizImportExportService().importList(context, quizProvider),
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Import'),
        ),
      ],
    );
  }
}
