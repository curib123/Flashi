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
                SizedBox(height: 10),

              ],
            ),
          ) :isOfflineOrNotSignIn(colorScheme,context);
        },
      ),
    );
  }
}
