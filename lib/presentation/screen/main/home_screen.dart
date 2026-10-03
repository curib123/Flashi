import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/screen/main/favorate_screen.dart';
import 'package:flashi/presentation/screen/main/history_screen.dart';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/components/see_all_quiz_set_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/ai_model_logic_provider.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/provider/check_version_provider.dart';
import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FetchDataFromJsonProvider>().fetchLatestVersion();
      context.read<AiModelLogicProvider>().fetchLatestVersion();
      context.read<CheckVersionProvider>().checkAppVersion(context);
    });
  }

  void _openGenerator() {
    final quiz = context.read<QuizProvider>();
    final data = context.read<FetchDataFromJsonProvider>();
    final ai = context.read<AiModelLogicProvider>();
    final credits = context.read<AiCreditProvider>();

    ai.showFlashcardDialog(
      context,
      quiz,
      Theme.of(context).colorScheme,
      data,
      credits,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final quiz = context.watch<QuizProvider>();
    final credits = context.watch<AiCreditProvider>();
    final sets = quiz.filteredQuizSets.reversed.toList();
    final totalCards = quiz.quizSets.fold<int>(
      0,
      (total, item) => total + ((item['cards'] as List?)?.length ?? 0),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<FetchDataFromJsonProvider>().fetchLatestVersion();
            context.read<AiModelLogicProvider>().fetchLatestVersion();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              FlashiDesign.pagePadding,
              12,
              FlashiDesign.pagePadding,
              36,
            ),
            children: [
              _TopBar(credits: credits.credits),
              const SizedBox(height: 24),
              Text(
                'Turn anything into a quiz.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create study sets from a topic, PDF, document, image, or your own questions.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface.withOpacity(0.65),
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 20),
              _GeneratorCard(onGenerate: _openGenerator),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.layers_outlined,
                      value: quiz.quizSets.length.toString(),
                      label: 'Quiz sets',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.style_outlined,
                      value: totalCards.toString(),
                      label: 'Study cards',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Quick access',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.auto_awesome,
                      label: 'Assistant',
                      onTap: () => context
                          .read<BottomNavigationProvider>()
                          .toogleNavigation(0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.history_rounded,
                      label: 'History',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.favorite_outline_rounded,
                      label: 'Favorites',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoriteScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your quiz sets',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeeAllQuizSetList(
                          name: 'All Quiz Sets',
                          colorScheme: colors,
                        ),
                      ),
                    ),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quiz.searchController,
                onChanged: quiz.updateSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Search quiz sets',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 10),
              if (sets.isEmpty)
                _EmptyLibrary(onGenerate: _openGenerator)
              else
                ReusableQuizSetList(quizSets: sets),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int credits;

  const _TopBar({required this.credits});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.bolt_rounded, color: colors.onPrimary),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flashi AI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              Text(
                'Quiz Maker & Learner',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, size: 17, color: colors.primary),
              const SizedBox(width: 4),
              Text(
                credits.toString(),
                style: TextStyle(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _GeneratorCard extends StatelessWidget {
  final VoidCallback onGenerate;

  const _GeneratorCard({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: colors.onPrimary, size: 30),
          const SizedBox(height: 18),
          Text(
            'Create with AI',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose a source and let Flashi build a focused Q&A set for you.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onPrimary.withOpacity(0.82),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.onPrimary,
              foregroundColor: colors.primary,
            ),
            onPressed: onGenerate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Generate quiz'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(FlashiDesign.radius),
        border: Border.all(color: colors.outline.withOpacity(0.13)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FlashiDesign.smallRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(FlashiDesign.smallRadius),
          border: Border.all(color: colors.outline.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  final VoidCallback onGenerate;

  const _EmptyLibrary({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(FlashiDesign.radius),
        border: Border.all(color: colors.outline.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.layers_outlined,
            size: 42,
            color: colors.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          const Text(
            'No quiz sets yet',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Generate your first quiz and it will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onGenerate,
            child: const Text('Create first quiz'),
          ),
        ],
      ),
    );
  }
}
