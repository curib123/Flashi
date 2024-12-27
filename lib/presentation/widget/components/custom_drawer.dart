import 'package:flashlearn/presentation/screen/main/settings_screen.dart';
import 'package:flashlearn/provider/bottom_navigation_provider.dart';
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
            accountName: const Text("not sign in"),
            accountEmail: const Text("sign in first"),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, color: colorScheme.primary, size: 50),
            ),
          ),
          buildListTile(
            icon: Icons.login,
            title: 'Sign in',
            onTap: () => Navigator.pop(context),
          ),
          buildListTile(
            icon: Icons.star_rounded,
            title: 'Upgrade to PRO',
            onTap: () => Navigator.pop(context),
          ),
          const Divider(height: 1),
          buildListTile(
            icon: Icons.home_rounded,
            title: 'Home',
            onTap: () {
              Navigator.pop(context);
              bottomNavigationProvider.toogleNavigation(1);
            },
          ),
          buildListTile(
            icon: Icons.favorite_rounded,
            title: 'Favorites',
            onTap: () {
              Navigator.pop(context);
              bottomNavigationProvider.toogleNavigation(0);
            },
          ),
          buildListTile(
            icon: Icons.note_rounded,
            title: 'Notes',
            onTap: () {
              Navigator.pop(context);
              bottomNavigationProvider.toogleNavigation(2);
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
            icon: Icons.settings_backup_restore_rounded,
            title: 'Backup/Restore',
            onTap: () => Navigator.pop(context),
          ),
          buildListTile(
            icon: Icons.import_export_rounded,
            title: 'Import/Export Cards',
            onTap: () => Navigator.pop(context),
          ),
          buildListTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy policy',
            onTap: () => Navigator.pop(context),
          ),
          buildListTile(
            icon: Icons.help_center,
            title: 'Help',
            onTap: () => Navigator.pop(context),
          ),
          buildListTile(
            icon: Icons.share_rounded,
            title: 'Share',
            onTap: () => Navigator.pop(context),
          ),
          buildListTile(
            icon: Icons.contact_mail,
            title: 'Contact us',
            onTap: () => Navigator.pop(context),
          ),
          buildListTile(
            icon: Icons.info_rounded,
            title: 'About us',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
