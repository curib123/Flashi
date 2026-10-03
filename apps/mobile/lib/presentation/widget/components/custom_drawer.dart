import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/screen/main/favorate_screen.dart';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/util/helpers/classes/other/wepage_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Consumer3<
            BottomNavigationProvider,
            AuthProvider,
            AiCreditProvider>(
          builder: (context, navigation, auth, credits, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _DrawerHeader(auth: auth, credits: credits.credits),
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
                            selected: navigation.currentIndex == 0,
                            onTap: () => _selectTab(context, navigation, 0),
                          ),
                          _DrawerItem(
                            icon: Icons.layers_outlined,
                            label: 'Study library',
                            selected: navigation.currentIndex == 1,
                            onTap: () => _selectTab(context, navigation, 1),
                          ),
                          _DrawerItem(
                            icon: Icons.history_outlined,
                            label: 'Generation history',
                            selected: navigation.currentIndex == 2,
                            onTap: () => _selectTab(context, navigation, 2),
                          ),
                          _DrawerItem(
                            icon: Icons.favorite_border_rounded,
                            label: 'Favorites',
                            onTap: () => _push(
                              context,
                              const FavoriteScreen(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _SectionTitle(title: 'Account'),
                          if (auth.signedIn)
                            _DrawerItem(
                              icon: Icons.logout_rounded,
                              label: 'Sign out',
                              onTap: () async {
                                final navigator = Navigator.of(context);
                                navigator.pop();
                                await auth.signOut();
                              },
                            )
                          else
                            _DrawerItem(
                              icon: Icons.login_rounded,
                              label: 'Sign in with Google',
                              onTap: () async {
                                final navigator = Navigator.of(context);
                                final hostContext = navigator.context;
                                navigator.pop();
                                final ok = await auth.signInWithGoogle();
                                if (ok && hostContext.mounted) {
                                  await hostContext
                                      .read<AiCreditProvider>()
                                      .refresh();
                                }
                              },
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
                              final navigator = Navigator.of(context);
                              final hostContext = navigator.context;
                              navigator.pop();
                              showAboutDialog(
                                context: hostContext,
                                applicationName: 'Flashi',
                                applicationVersion: '1.6.3',
                                applicationLegalese:
                                    'Offline-first flashcard and quiz maker.',
                              );
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
                          Icons.offline_bolt_outlined,
                          size: 16,
                          color: FlashiDesign.mutedOf(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Manual sets and downloaded study content stay available offline.',
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
  final AuthProvider auth;
  final int credits;

  const _DrawerHeader({
    required this.auth,
    required this.credits,
  });

  @override
  Widget build(BuildContext context) {
    final user = auth.user;
    return Row(
      children: [
        const _FlashiMark(size: 54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Flashi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                auth.signedIn
                    ? (user?.email ?? 'Signed in')
                    : 'Offline manual mode',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FlashiDesign.mutedOf(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: FlashiDesign.primarySoftOf(context),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      auth.signedIn
                          ? Icons.bolt_rounded
                          : Icons.offline_bolt_outlined,
                      size: 15,
                      color: FlashiDesign.brand,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      auth.signedIn
                          ? credits.toString() + ' energy'
                          : 'Offline ready',
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
        Icons.style_rounded,
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
