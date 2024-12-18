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

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Removes default padding
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("not sign in"),
            accountEmail: Text("sign in first"),
            currentAccountPicture: CircleAvatar(

            ),
          ),
          ListTile(
            leading:  Icon(Icons.home_rounded,color: colorScheme.primary,),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              bottomNavigationProvider.toogleNavigation(1);
            },
          ),
          ListTile(
            leading:  Icon(Icons.favorite_rounded,color: colorScheme.primary),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              bottomNavigationProvider.toogleNavigation(0);
            },
          ),
          ListTile(
            leading:  Icon(Icons.alarm_rounded,color: colorScheme.primary),
            title: const Text('Alarm'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              bottomNavigationProvider.toogleNavigation(0);
            },
          ),
          ListTile(
            leading:  Icon(Icons.settings_rounded,color: colorScheme.primary),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Add navigation logic here
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );

            },
          ),
          Divider(
              height: 1,
              color: colorScheme.primary
          )
        ],
      ),
    );
  }
}
