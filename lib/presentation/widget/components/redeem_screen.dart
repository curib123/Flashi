import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flashi/util/helpers/widget/other/check_internet.dart';
import 'package:flashi/util/helpers/widget/other/empty_widgets.dart';
import 'package:flashi/util/helpers/widget/other/token_initialization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {

  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    fetchDataTokens(context, checkInternet);
  }

  Future<void> checkInternet(AuthProvider authProvider) async {
    bool result =    await isHaveInternet();

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
    return const RedeemScreenContent();
  }
}

class RedeemScreenContent extends StatelessWidget {
  const RedeemScreenContent({super.key,required });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return  Consumer2<TokenProvider,AuthProvider>(
        builder: (context, tokenProvider,authProvider, child) {
          return authProvider.user_id.isNotEmpty  ?  SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


              ],
            ),
          ) :isOfflineOrNotSignIn(colorScheme,context);
        },
      );
  }



}