import 'dart:ffi';

import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flashi/util/helpers/widget/other/empty_widgets.dart';
import 'package:flashi/util/helpers/widget/other/reward_ui.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {

  bool isConnected = false;


  @override
  void initState() {
    super.initState();

    final tokenProvider = Provider.of<TokenProvider>(context,listen: false);
    final authProvider = Provider.of<AuthProvider>(context,listen: false);

    checkInternet(authProvider);
    Future.delayed(Duration.zero, () async {
      await   tokenProvider.fetchTokens(authProvider.user_id);
      await tokenProvider.updateIsReviewing(authProvider.user_id);
      await  tokenProvider.fetchPayoutDate();
      await tokenProvider.updateIsRedeemAvailable();
    });

  }

  Future<void> checkInternet(AuthProvider authProvider) async {
    bool result =   await InternetConnection().hasInternetAccess;

    setState(() {
      isConnected = result;
    });

    if (!isConnected ) {
      showAuthDialog(
        context,
        type: "error",
        "No Internet",
        "Connect to WiFi or Mobile Data",
      );
    }else{
      if(authProvider.user_id.isEmpty){
        showAuthDialog(
            context,
            type: "warning",
            "Sign In Required",
            "Sign in to continue");
      }
    }

    print("Internet Connection: $isConnected");
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

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(

          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title:  ReusableTitleContent(colorScheme: colorScheme, title: "Earn", onUpgradePro: () {},
            onSettings: () {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );

            }),
        centerTitle: false,
      ),
      body: Consumer2<TokenProvider,AuthProvider>(
        builder: (context, tokenProvider,authProvider, child) {
          return authProvider.user_id.isNotEmpty ?  SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BalanceToken(colorScheme, tokenProvider,context),
                SizedBox(height: 5),
                _inviteBtnContainer(colorScheme),
                SizedBox(height: 10,),
                _DailyActivitiesContainer(
                     colorScheme,
                      (tokenRewards){

                },
                  tokenProvider.activities,
                    context
                ),

              ],
            ),
          ) :isOfflineOrNotSignIn(colorScheme,context);
        },
      ),
    );
  }
}
Widget _inviteBtnContainer(ColorScheme colorScheme) {
  return GestureDetector(
    onTap: () {
      // TODO: Implement invite friend functionality
    },
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(1),
            colorScheme.primaryContainer.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            blurRadius: 8, // Spread of the shadow
            offset: Offset(0, 4), // Position of the shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Text and Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading
                Text(
                  "For each friend using your referral code, you get 150 tokens + 10% of their tokens!",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                // Subheading
                Text(
                  "The more invites you have, the more you earn!",
                  style: TextStyle(
                    color: colorScheme.primary.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),

              ],
            ),
          ),

          // Right side: Arrow Icon
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: colorScheme.primary.withOpacity(0.8),
            size: 24,
          ),
        ],
      ),
    ),
  );
}

Widget _DailyActivitiesContainer(
    ColorScheme colorScheme,
    Function(double) onClaim,
    List<Map<String, dynamic>> activities,
    BuildContext context) {

  // Filter out activities where isClaim is true
  final filteredActivities = activities.where((activity) => activity['isClaim'] != true).toList();

  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Daily Activities",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), // Disable scrolling inside the container
          itemCount: filteredActivities.length,
          itemBuilder: (context, index) {
            final activity = filteredActivities[index];
            return _dailyActivitiesTile(
              icon: activity['icon'],
              title: activity['title'],
              colorScheme: colorScheme,
              onClaim: onClaim,
              tokenRewards: activity['rewards'],
              context: context,
            );
          },
        ),
      ],
    ),
  );
}

Widget _dailyActivitiesTile({
  required IconData icon,
  required String title,
  required ColorScheme colorScheme,
  required void Function(double) onClaim,
  required double tokenRewards,
  required BuildContext context,
}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 5),
    margin: EdgeInsets.symmetric(vertical: 10),
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10), // Optional rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1), // Shadow color
          spreadRadius: 1, // How far the shadow spreads
          blurRadius: 5, // How soft the shadow is
          offset: Offset(2, 2), // Position of shadow
        ),
      ],
    ),
    child: ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Match container's border radius
      ),
      tileColor: Colors.white,
      leading: Icon(icon, color: colorScheme.primary, size: 30),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
      trailing: GestureDetector(
        onTap: () => onClaim(tokenRewards),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6 ,horizontal: 15),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(50), // Optional rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Shadow color
                spreadRadius: 1, // How far the shadow spreads
                blurRadius: 5, // How soft the shadow is
                offset: Offset(2, 2), // Position of shadow
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Prevent Row from taking full width
            children: [
              Text(
                '+ ${tokenRewards.toStringAsFixed(0)} ',
                style: TextStyle(color: colorScheme.onPrimary,fontSize: 13,fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5), // Spacing between text and icon
              Icon(Icons.diamond_rounded, color: colorScheme.onPrimary,size: 20,),
            ],
          ),
        ),
      ),
    ),
  );
}
