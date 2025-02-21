import 'package:flashi/presentation/screen/main/export_import_screen.dart';
import 'package:flashi/presentation/screen/main/favorate_screen.dart';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/util/helpers/classes/other/wepage_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(color: colorScheme.primary);

    Widget buildListTile({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
    }) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: textStyle),
        onTap: onTap,
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Flashi Ai"),
            accountEmail: const Text("Ai-Powered Flashcard Generator"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: colorScheme.onTertiary,
              child: Icon(Icons.person,size: 50,color: colorScheme.primary,),

            ),
          ),
          // buildListTile(
          //   icon: Icons.login,
          //   title: 'Sign in',
          //   onTap: () => Navigator.pop(context),
          // ),
          // buildListTile(
          //   icon: Icons.diamond_rounded,
          //   title: 'Upgrade to PRO',
          //   onTap: () => Navigator.pop(context),
          // ),
          buildListTile(
            icon: Icons.house_siding_rounded,
            title: 'Home',
            onTap: () {
              Navigator.pop(context);
              bottomNavigationProvider.toogleNavigation(2);
            },
          ),
          buildListTile(
            icon: Icons.favorite_rounded,
            title: 'My Favorites',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
          ),
          buildListTile(
            icon: Icons.text_snippet_rounded,
            title: 'My Notes',
            onTap: () {
              Navigator.pop(context);
              bottomNavigationProvider.toogleNavigation(4);
            },
          ),
          buildListTile(
            icon: Icons.task_rounded,
            title: 'My Chatbot ',
            onTap: () {
              Navigator.pop(context);
              bottomNavigationProvider.toogleNavigation(0);
            },
          ),

          buildListTile(
            icon: Icons.settings_rounded,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),

          const Divider(height: 1),
          buildListTile(
            icon: Icons.import_export_rounded,
            title: 'Import/Export Set Card',
            onTap: () => {
              Navigator.pop(context),
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  ExportImportScreen()),
            )
            },
          ),

          buildListTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            onTap: () => {
              Navigator.pop(context),
              // TODO: Navigate to privacy policy screen

            WebPageLauncher('https://curib123.github.io/flashi_/privacy_policy.html').launch()

          },

          ), buildListTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Terms and Conditions',
            onTap: () => {
              Navigator.pop(context),
              // TODO: Navigate to privacy policy screen

            WebPageLauncher('https://curib123.github.io/flashi_/terms%26condition.html').launch()

          },

          ),
          // buildListTile(
          //   icon: Icons.help_center,
          //   title: 'Help',
          //   onTap: () => Navigator.pop(context),
          // ),
          // buildListTile(
          //   icon: Icons.share_rounded,
          //   title: 'Share',
          //   onTap: () => Navigator.pop(context),
          // ),
          buildListTile(
            icon: Icons.contact_mail,
            title: 'Contact us',
            onTap: () =>
            {
              Navigator.pop(context),
              // TODO: Navigate to contact us screen},
              WebPageLauncher('').launchEmail()
            }
          ),
          // buildListTile(
          //   icon: Icons.info_rounded,
          //   title: 'About us',
          //   onTap: () => Navigator.pop(context),
          // ),
        ],
      ),
    );
  }
}
