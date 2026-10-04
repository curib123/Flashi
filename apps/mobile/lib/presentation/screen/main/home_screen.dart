import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/screen/main/favorate_screen.dart';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/components/custom_drawer.dart';
import 'package:flashi/presentation/widget/components/study_generator_sheet.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/provider/check_version_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      context.read<CheckVersionProvider>().checkAppVersion(context);
      if (context.read<AuthProvider>().signedIn) {
        await context.read<AiCreditProvider>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final auth = context.watch<AuthProvider>();
    final credits = context.watch<AiCreditProvider>();
    final sets = quiz.filteredQuizSets.reversed.toList();
    final totalCards = quiz.quizSets.fold<int>(
      0,
      (total, item) => total + ((item['cards'] as List?)?.length ?? 0),
    );

    return Scaffold(
      drawer: const CustomDrawer(),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            if (auth.signedIn) await credits.refresh();
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
              _TopBar(
                signedIn: auth.signedIn,
                credits: credits.credits,
              ),
              const SizedBox(height: 24),
              Text(
                'Turn study material into practice.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create flashcards and quizzes manually offline, or generate them from a topic, document, or notes image with Luna.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: FlashiDesign.mutedOf(context),
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 20),
              _GeneratorCard(
                onCreate: () => showStudyGeneratorSheet(context),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.layers_outlined,
                      value: quiz.quizSets.length.toString(),
                      label: 'Study sets',
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
                      icon: Icons.layers_outlined,
                      label: 'Library',
                      onTap: () => context
                          .read<BottomNavigationProvider>()
                          .setIndex(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.history_rounded,
                      label: 'History',
                      onTap: () => context
                          .read<BottomNavigationProvider>()
                          .setIndex(2),
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
                      'Recent study sets',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context
                        .read<BottomNavigationProvider>()
                        .setIndex(1),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quiz.searchController,
                onChanged: quiz.updateSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Search study sets',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 10),
              if (sets.isEmpty)
                _EmptyLibrary(
                  onCreate: () => showStudyGeneratorSheet(context),
                )
              else
                ReusableQuizSetList(
                  quizSets: sets.take(6).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool signedIn;
  final int credits;

  const _TopBar({
    required this.signedIn,
    required this.credits,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Menu',
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu_rounded),
        ),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.style_rounded, color: colors.onPrimary),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flashi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              Text(
                'Flashcard & Quiz Maker',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: FlashiDesign.primarySoftOf(context),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            children: [
              Icon(
                signedIn ? Icons.bolt_rounded : Icons.offline_bolt_outlined,
                size: 16,
                color: colors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                signedIn ? credits.toString() : 'Offline',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
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
  final VoidCallback onCreate;

  const _GeneratorCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlashiDesign.primaryFaintOf(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: FlashiDesign.primarySoftOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: FlashiDesign.primarySoftOf(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.add_card_rounded,
              color: FlashiDesign.brand,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create a study set',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Build cards yourself or use GPT-5.6 Luna to generate structured practice from your material.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: FlashiDesign.mutedOf(context),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create study set'),
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
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: FlashiDesign.surfaceOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FlashiDesign.borderOf(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: FlashiDesign.primarySoftOf(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: FlashiDesign.brand, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: FlashiDesign.brand,
                      ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: FlashiDesign.mutedOf(context),
                      ),
                ),
              ],
            ),
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
    return Material(
      color: FlashiDesign.brand,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyLibrary({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: FlashiDesign.surfaceOf(context),
        borderRadius: BorderRadius.circular(FlashiDesign.radius),
        border: Border.all(color: FlashiDesign.borderOf(context)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.layers_outlined,
            size: 42,
            color: FlashiDesign.brand,
          ),
          const SizedBox(height: 12),
          const Text(
            'No study sets yet',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Create one manually or generate it from your notes.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: FlashiDesign.mutedOf(context),
                ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onCreate,
            child: const Text('Create first set'),
          ),
        ],
      ),
    );
  }
}
