import 'package:flashlearn/presentation/screen/main/settings_screen.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_quiz_card_list.dart';
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
           UserAccountsDrawerHeader(
            accountName: Text("not sign in"),
            accountEmail: Text("sign in first"),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person,color: colorScheme.primary,size: 50,),
            ),
          ),
          ListTile(
            leading:  Icon(Icons.home_rounded,color: colorScheme.primary,),
            title:  Text('Home',style: TextStyle(color: colorScheme.primary),),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              bottomNavigationProvider.toogleNavigation(1);
            },
          ),
          ListTile(
            leading:  Icon(Icons.favorite_rounded,color: colorScheme.primary),
            title:  Text('Favorites',style: TextStyle(color: colorScheme.primary)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              bottomNavigationProvider.toogleNavigation(0);
            },
          ),
          ListTile(
            leading:  Icon(Icons.alarm_rounded,color: colorScheme.primary),
            title:  Text('Alarm',style: TextStyle(color: colorScheme.primary)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              bottomNavigationProvider.toogleNavigation(2);
            },
          ),
          ListTile(
            leading:  Icon(Icons.settings_rounded,color: colorScheme.primary),
            title:  Text('Settings',style: TextStyle(color: colorScheme.primary)),
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
          ),
          ListTile(
            leading:  Icon(Icons.settings_backup_restore_rounded,color: colorScheme.primary),
            title:  Text('Backup/Restore',style: TextStyle(color: colorScheme.primary)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Add navigation logic here
            },
          ),
          ListTile(
            leading:  Icon(Icons.import_export_rounded,color: colorScheme.primary),
            title:  Text('Import/Export Cards',style: TextStyle(color: colorScheme.primary)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Add navigation logic here
            },
          ),
          ListTile(
            leading:  Icon(Icons.contact_mail,color: colorScheme.primary),
            title:  Text('Contact us',style: TextStyle(color: colorScheme.primary)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Add navigation logic here
            },
          ),
          ListTile(
            leading:  Icon(Icons.privacy_tip_rounded,color: colorScheme.primary),
            title:  Text('Privacy policy',style: TextStyle(color: colorScheme.primary)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Add navigation logic here
            },
          ),
          ListTile(
            leading:  Icon(Icons.help_center,color: colorScheme.primary),
            title:  Text('Help',style: TextStyle(color: colorScheme.primary)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Add navigation logic here
            },
          ),
          ListTile(
            leading:  Icon(Icons.share_rounded,color: colorScheme.primary),
            title:  Text('Share',style: TextStyle(color: colorScheme.primary)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Add navigation logic here
            },
          ),
          ListTile(
            leading:  Icon(Icons.info_rounded,color: colorScheme.primary),
            title:  Text('About us',style: TextStyle(color: colorScheme.primary)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Add navigation logic here
            },
          ),
        ],
      ),
    );
  }
}
