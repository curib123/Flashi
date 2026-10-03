import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/screen/main/favorate_screen.dart';
import 'package:flashi/presentation/screen/main/history_screen.dart';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/components/see_all_quiz_set_list.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/other/wepage_launcher.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/about_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Consumer3<BottomNavigationProvider, QuizProvider, AiCreditProvider>(
          builder: (context, navigation, quiz, credits, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _DrawerHeader(credits: credits.credits),
                  const SizedBox(height: 18),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(title: 'Navigate'),
                          _DrawerItem(
                            icon: Icons.home_outlined,
                            label: 'Home',
                            selected: navigation.currentIndex == 1,
                            onTap: () => _selectTab(context, navigation, 1),
                          ),
                          _DrawerItem(
                            icon: Icons.auto_awesome_outlined,
                            label: 'AI Assistant',
                            selected: navigation.currentIndex == 0,
                            onTap: () => _selectTab(context, navigation, 0),
                          ),
                          _DrawerItem(
                            icon: Icons.note_alt_outlined,
                            label: 'Notes',
                            selected: navigation.currentIndex == 2,
                            onTap: () => _selectTab(context, navigation, 2),
                          ),
                          const SizedBox(height: 14),
                          const _SectionTitle(title: 'Study library'),
                          _DrawerItem(
                            icon: Icons.layers_outlined,
                            label: 'Quiz sets',
                            onTap: () {
                              quiz.searchController.text = quiz.searchQuery;
                              _push(
                                context,
                                SeeAllQuizSetList(
                                  name: 'All Quiz Sets',
                                  colorScheme: Theme.of(context).colorScheme,
                                ),
                              );
                            },
                          ),
                          _DrawerItem(
                            icon: Icons.favorite_border_rounded,
                            label: 'Favorites',
                            onTap: () => _push(
                              context,
                              const FavoriteScreen(),
                            ),
                          ),
                          _DrawerItem(
                            icon: Icons.history_rounded,
                            label: 'Generation history',
                            onTap: () => _push(
                              context,
                              const HistoryScreen(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _SectionTitle(title: 'App'),
                          _DrawerItem(
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                            onTap: () => _push(
                              context,
                              const SettingsScreen(),
                            ),
                          ),
                          _DrawerItem(
                            icon: Icons.mail_outline_rounded,
                            label: 'Contact us',
                            onTap: () {
                              Navigator.pop(context);
                              WebPageLauncher('').launchEmail();
                            },
                          ),
                          _DrawerItem(
                            icon: Icons.info_outline_rounded,
                            label: 'About',
                            onTap: () {
                              Navigator.pop(context);
                              showAnimatedAboutDialog(context);
                            },
                          ),
                          _DrawerItem(
                            icon: Icons.privacy_tip_outlined,
                            label: 'Privacy policy',
                            onTap: () {
                              Navigator.pop(context);
                              WebPageLauncher(
                                'https://curib123.github.io/flashi_/privacy_policy.html',
                              ).launch();
                            },
                          ),
                          _DrawerItem(
                            icon: Icons.description_outlined,
                            label: 'Terms & conditions',
                            onTap: () {
                              Navigator.pop(context);
                              WebPageLauncher(
                                'https://curib123.github.io/flashi_/terms%26condition.html',
                              ).launch();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: FlashiDesign.mutedOf(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Private study data stays on your device.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: FlashiDesign.mutedOf(context),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static void _selectTab(
    BuildContext context,
    BottomNavigationProvider provider,
    int index,
  ) {
    provider.setIndex(index);
    Navigator.pop(context);
  }

  static void _push(BuildContext context, Widget screen) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _DrawerHeader extends StatelessWidget {
  final int credits;

  const _DrawerHeader({required this.credits});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _FlashiMark(size: 54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FlashiDesign.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                FlashiDesign.tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FlashiDesign.mutedOf(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: FlashiDesign.primarySoftOf(context),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 15,
                      color: FlashiDesign.brand,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$credits energy',
                      style: const TextStyle(
                        color: FlashiDesign.brand,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlashiMark extends StatelessWidget {
  final double size;

  const _FlashiMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: FlashiDesign.brand,
        borderRadius: BorderRadius.circular(size * .30),
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: size * .48,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: FlashiDesign.mutedOf(context),
              letterSpacing: .8,
            ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      selected: selected,
      selectedTileColor: FlashiDesign.primarySoftOf(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      leading: Icon(
        icon,
        size: 20,
        color: selected ? FlashiDesign.brand : FlashiDesign.mutedOf(context),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? FlashiDesign.brand : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
