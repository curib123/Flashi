import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Icon(
              Icons.notes_rounded,
              size: 30,
              color: colorScheme.onPrimary,
            ),
          ),
          backgroundColor: colorScheme.primary,
          title: ReusableTitleContent(
            isEnergyShow: false,
            colorScheme: colorScheme,
            title: "Study Session",
            onUpgradePro: () {},
            onSettings: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          bottom: TabBar(
            labelColor: colorScheme.onPrimary,
            unselectedLabelColor: Colors.white70,
            indicatorColor: colorScheme.onPrimary,
            tabs: const [
              Tab(text: "Chat Session"),
              Tab(text: "Study Session"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text("Chat Session Content")),
            Center(child: Text("Study Session Content")),
          ],
        ),
      ),
    );
  }
}