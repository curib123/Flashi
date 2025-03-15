import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flutter/material.dart';

class OnlineScreen extends StatelessWidget {
  const OnlineScreen({super.key});

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
            title: "Community ",
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
              Tab(text: "What's New"),
              Tab(text: "Leaderboards"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text("Recent Post ")),
            Center(child: Text("Leaderboards")),
          ],
        ),
      ),
    );
  }
}