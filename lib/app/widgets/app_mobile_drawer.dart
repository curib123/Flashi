import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/features/favorites/presentation/pages/favorites_page.dart';
import 'package:flashi/features/history/presentation/pages/history_page.dart';
import 'package:flashi/features/settings/presentation/pages/settings_page.dart';
import 'package:flashi/presentation/widget/components/see_all_quiz_set_list.dart';
import 'package:flashi/app/state/app_navigation_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/other/wepage_launcher.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/about_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppMobileDrawer extends StatelessWidget {
  const AppMobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Consumer2<AppNavigationProvider, QuizProvider>(
          builder: (context, navigation, quiz, child) {
            return _NavigationContent(
              selectedIndex: navigation.currentIndex,
              onDestinationSelected: (index) {
                Navigator.pop(context);
                navigation.selectDestination(index);
              },
              onQuizSets: () {
                Navigator.pop(context);
                quiz.searchController.text = quiz.searchQuery;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeeAllQuizSetList(
                      name: 'All Quiz Set',
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                  ),
                );
              },
              closeBefore: (action) {
                Navigator.pop(context);
                action();
              },
            );
          },
        ),
      ),
    );
  }
}

class AppSideNavigation extends StatelessWidget {
  const AppSideNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.quizProvider,
    this.extended = false,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final QuizProvider quizProvider;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: extended ? 272 : 88,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: extended
            ? _NavigationContent(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                onQuizSets: () => _openQuizSets(context),
                closeBefore: (action) => action(),
              )
            : NavigationRail(
                backgroundColor: Colors.transparent,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                leading: const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _BrandMark(),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.auto_awesome_outlined),
                    selectedIcon: Icon(Icons.auto_awesome),
                    label: Text('Assistant'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.space_dashboard_outlined),
                    selectedIcon: Icon(Icons.space_dashboard),
                    label: Text('Learn'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.note_alt_outlined),
                    selectedIcon: Icon(Icons.note_alt),
                    label: Text('Notes'),
                  ),
                ],
              ),
      ),
    );
  }

  void _openQuizSets(BuildContext context) {
    quizProvider.searchController.text = quizProvider.searchQuery;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeeAllQuizSetList(
          name: 'All Quiz Set',
          colorScheme: Theme.of(context).colorScheme,
        ),
      ),
    );
  }
}

class _NavigationContent extends StatelessWidget {
  const _NavigationContent({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onQuizSets,
    required this.closeBefore,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onQuizSets;
  final void Function(VoidCallback action) closeBefore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              _BrandMark(),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flashi',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text('Learn with clarity'),
                  ],
                ),
              ),
            ],
          ),
        ),
        _DestinationTile(
          icon: Icons.auto_awesome_outlined,
          selectedIcon: Icons.auto_awesome,
          label: 'Assistant',
          selected: selectedIndex == 0,
          onTap: () => onDestinationSelected(0),
        ),
        _DestinationTile(
          icon: Icons.space_dashboard_outlined,
          selectedIcon: Icons.space_dashboard,
          label: 'Learn',
          selected: selectedIndex == 1,
          onTap: () => onDestinationSelected(1),
        ),
        _DestinationTile(
          icon: Icons.note_alt_outlined,
          selectedIcon: Icons.note_alt,
          label: 'Notes',
          selected: selectedIndex == 2,
          onTap: () => onDestinationSelected(2),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Divider(),
        ),
        _NavigationTile(
          icon: Icons.layers_outlined,
          label: 'Quiz sets',
          onTap: onQuizSets,
        ),
        _NavigationTile(
          icon: Icons.favorite_border,
          label: 'Favorites',
          onTap: () => closeBefore(
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesPage()),
            ),
          ),
        ),
        _NavigationTile(
          icon: Icons.history,
          label: 'History',
          onTap: () => closeBefore(
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          ),
        ),
        const Spacer(),
        _NavigationTile(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () => closeBefore(
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ),
        _NavigationTile(
          icon: Icons.info_outline,
          label: 'About',
          onTap: () => closeBefore(() => showAnimatedAboutDialog(context)),
        ),
        _NavigationTile(
          icon: Icons.contact_support_outlined,
          label: 'Contact',
          onTap: () => closeBefore(WebPageLauncher('').launchEmail),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Wrap(
            spacing: AppSpacing.md,
            children: [
              _TextAction(
                label: 'Privacy',
                onTap: () => closeBefore(
                  WebPageLauncher(
                    'https://curib123.github.io/flashi_/privacy_policy.html',
                  ).launch,
                ),
              ),
              _TextAction(
                label: 'Terms',
                onTap: () => closeBefore(
                  WebPageLauncher(
                    'https://curib123.github.io/flashi_/terms%26condition.html',
                  ).launch,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: ListTile(
        selected: selected,
        leading: Icon(selected ? selectedIcon : icon),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ListTile(
        dense: true,
        leading: Icon(icon),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.bolt_rounded,
        size: 20,
        color: colorScheme.onInverseSurface,
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
