import 'package:flashi/provider/daily_activities_provider.dart';
import 'package:flutter/material.dart';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flashi/util/helpers/widget/other/check_internet.dart';
import 'package:flashi/util/helpers/widget/other/empty_widgets.dart';
import 'package:flashi/util/helpers/widget/other/reward_ui.dart';
import 'package:flashi/util/helpers/widget/other/token_initialization.dart';
import 'package:provider/provider.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  bool isConnected = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fetchDataTokens(context, checkInternet);
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> checkInternet(AuthProvider authProvider) async {
    bool result = await isHaveInternet();
    setState(() {
      isConnected = result;
    });

    if (!isConnected) {
      showAuthDialog(
        context,
        type: "error",
        "No Internet",
        "Connect to WiFi or Mobile Data",
      );
    } else {
      if (authProvider.user_id.isEmpty) {
        showAuthDialog(
          context,
          type: "warning",
          "Sign In Required",
          "Sign in to continue",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
          colorScheme: colorScheme,
          title: "Earn",
          onUpgradePro: () {},
          onSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ),
      body: Consumer3<TokenProvider, AuthProvider,DailyActivitiesProvider>(
        builder: (context, tokenProvider, authProvider,dailyActivitiesProvider, child) {
          return authProvider.user_id.isNotEmpty
              ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BalanceToken(colorScheme, tokenProvider, context),
                    const SizedBox(height: 5),
                    inviteBtnContainer(colorScheme, context, tokenProvider),
                    const SizedBox(height: 10),
                    TabBar(
                      controller: _tabController,
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: colorScheme.primary,
                      tabs: const [
                        Tab(text: "Daily Rewards"),
                        Tab(text: "Active Rewards"),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _DailyActivitiesContainer(
                      colorScheme,
                          (tokenRewards) {},
                      dailyActivitiesProvider.activities,
                      context,
                    ),
                    ActiveDailyActivity(),
                  ],
                ),
              ),
            ],
          )
              : isOfflineOrNotSignIn(colorScheme, context);
        },
      ),
    );
  }
}

Widget ActiveDailyActivity() {
  return Center(child: Text("Active Daily Activity"));
}

Widget _DailyActivitiesContainer(
    ColorScheme colorScheme,
    Function(double) onClaim,
    List<Map<String, dynamic>> activities,
    BuildContext context,
    ) {
  final filteredActivities = activities.where((activity) => activity['isClaim'] != true).toList();

  return ListView.builder(
    padding: const EdgeInsets.all(10),
    itemCount: filteredActivities.length,
    itemBuilder: (context, index) {
      final activity = filteredActivities[index];
      return DailyActivitiesTile(
        icon: activity['icon'],
        title: activity['title'],
        colorScheme: colorScheme,
        onClaim: onClaim,
        tokenRewards: activity['rewards'],
      );
    },
  );
}