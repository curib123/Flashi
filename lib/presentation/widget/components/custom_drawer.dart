import 'package:flashi/provider/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashi/presentation/screen/authentication/sign_in_screen.dart';
import 'package:flashi/presentation/screen/main/export_import_screen.dart';
import 'package:flashi/presentation/screen/main/favorate_screen.dart';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/util/helpers/classes/other/wepage_launcher.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/about_alert_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_logout_dialog.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(color: colorScheme.onSurface, fontSize: 16);

    Widget buildListTile({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
    }) {
      return ListTile(
        leading: Icon(icon, color: colorScheme.primary, size: 26),
        title: Text(title, style: textStyle),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      );
    }

    return Consumer3<BottomNavigationProvider, AuthProvider,QuizProvider>(
      builder: (context, bottomNavProvider, authProvider,quizProvider, child) {
        return Drawer(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          child: Column(
            children: [
              Container(
                width: MediaQuery.sizeOf(context).shortestSide,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      backgroundColor: colorScheme.onTertiary,
                      radius: 30, // Bigger for better focus
                      child: Icon(Icons.person, size: 40, color: colorScheme.primary),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),

                      child: Column(
                        children: [
                          Text(authProvider.username,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          const SizedBox(height: 5),
                          Text(authProvider.email,
                              style: const TextStyle(fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ),
                    // Optional: Add a divider for better separation
                    Divider(color: Colors.white.withOpacity(0.2), thickness: 1, indent: 20, endIndent: 20),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    authProvider.username == "Guest Account"
                        ? buildListTile(
                      icon: Icons.login_rounded,
                      title: 'Sign In',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInScreen()));
                      },
                    )
                        : buildListTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      onTap: () {
                        showLogoutConfirmationDialog(
                            context: context,
                            onLogout: () {
                              authProvider.signOut(context,quizProvider);
                            });
                      },
                    ),
                    const Divider(),
                    buildListTile(
                      icon: Icons.home_rounded,
                      title: 'Home',
                      onTap: () {
                        Navigator.pop(context);
                        bottomNavProvider.toogleNavigation(1);
                      },
                    ),
                    buildListTile(
                      icon: Icons.favorite_rounded,
                      title: 'Favorites',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FavoriteScreen()));
                      },
                    ),
                    buildListTile(
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsScreen()));
                      },
                    ),
                    const Divider(),
                    buildListTile(
                      icon: Icons.add_card_sharp,
                      title: 'Import Flashcard',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExportImportScreen()));
                      },
                    ),
                    buildListTile(
                      icon: Icons.bug_report_rounded,
                      title: 'Bug/Issues Report',
                      onTap: () {
                        Navigator.pop(context);
                        WebPageLauncher(
                            'https://docs.google.com/forms/...').launch();
                      },
                    ),
                    buildListTile(
                      icon: Icons.facebook_rounded,
                      title: 'Official FB Page',
                      onTap: () {
                        Navigator.pop(context);
                        WebPageLauncher('https://www.facebook.com/...').launch();
                      },
                    ),
                    const Divider(),
                    buildListTile(
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy Policy',
                      onTap: () {
                        Navigator.pop(context);
                        WebPageLauncher(
                            'https://curib123.github.io/flashi_/privacy_policy.html')
                            .launch();
                      },
                    ),
                    buildListTile(
                      icon: Icons.info_rounded,
                      title: 'Terms & Conditions',
                      onTap: () {
                        Navigator.pop(context);
                        WebPageLauncher(
                            'https://curib123.github.io/flashi_/terms%26condition.html')
                            .launch();
                      },
                    ),
                    buildListTile(
                      icon: Icons.contact_mail,
                      title: 'Contact Us',
                      onTap: () {
                        Navigator.pop(context);
                        WebPageLauncher('').launchEmail();
                      },
                    ),
                    buildListTile(
                      icon: Icons.info_rounded,
                      title: 'About Us',
                      onTap: () {
                        Navigator.pop(context);
                        showAnimatedAboutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}