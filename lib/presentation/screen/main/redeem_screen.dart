import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flashi/util/helpers/widget/modals/show_gcash_number_dialog.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
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

    final tokenProvider = Provider.of<TokenProvider>(context,listen: false);
    final authProvider = Provider.of<AuthProvider>(context,listen: false);
    Future.delayed(Duration.zero,() async {
      await tokenProvider.updateIsReviewing(authProvider.user_id);
      await tokenProvider.getUserGcashNumber(authProvider.user_id);
    });
    checkInternet();
  }

  Future<void> checkInternet() async {
    bool result =   await InternetConnection().hasInternetAccess;

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
    }

    print("Internet Connection: $isConnected");
  }

  @override
  Widget build(BuildContext context) {
    return const RedeemScreenContent();
  }
}

class RedeemScreenContent extends StatelessWidget {
  const RedeemScreenContent({super.key});

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
        foregroundColor: colorScheme.onPrimary,
        title: ReusableTitleContent(
          colorScheme: colorScheme,
          title: "Withdrawal",
          onUpgradePro: () {},
          onSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ),
      body: Consumer2<TokenProvider,AuthProvider>(
        builder: (context, tokenProvider,authProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DefaultPaymentMethod(colorScheme,tokenProvider,authProvider,context),
                SizedBox(height: 20),
                _BalanceToken(colorScheme, tokenProvider,context),
                SizedBox(height: 20),
                _PayoutList(colorScheme, tokenProvider, context,authProvider),
                SizedBox(height: 20),
                _DateOfPayout(colorScheme, tokenProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _DateOfPayout(ColorScheme colorScheme, TokenProvider tokenProvider) {
    return FutureBuilder<String?>(
      future: tokenProvider.fetchRemainingTime(tokenProvider.payoutDate, tokenProvider),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPayoutContainer(
            colorScheme,
            "Fetching payout info...",
            Icons.hourglass_empty,
            colorScheme.primary,
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return _buildPayoutContainer(
            colorScheme,
            "Error fetching payout date",
            Icons.error,
            Colors.red,
          );
        }

        String remainingTime = snapshot.data!;
        bool isPayoutReady = remainingTime.startsWith("✅");

        return _buildPayoutContainer(
          colorScheme,
          remainingTime,
          isPayoutReady ? Icons.check_circle : Icons.timer,
          isPayoutReady ? Colors.green : colorScheme.primary,
        );
      },
    );
  }

  Widget _buildPayoutContainer(
      ColorScheme colorScheme, String message, IconData icon, Color borderColor) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: borderColor),
          SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: borderColor),
          ),
        ],
      ),
    );
  }

  Widget _PayoutList(ColorScheme colorScheme, TokenProvider tokenProvider, BuildContext context,AuthProvider authProvider) {
    int userTokens = tokenProvider.currentTokens;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12.0,
        runSpacing: 12.0,
        children: tokenProvider.payoutOptions.map((payout) {
          int requiredTokens = payout["tokens"] ?? 0;
          int amount = payout["amount"] ?? 0;
          bool isMinimumToken = tokenProvider.minimumTokens == requiredTokens;
          bool isUnlocked = isMinimumToken || (userTokens >= requiredTokens && tokenProvider.isSuccessFullFirstPayout);

          return GestureDetector(
            onTap: () async {
              Future.delayed(Duration.zero,() async {
                await tokenProvider.updateIsReviewing(authProvider.user_id);
              });
              if (isUnlocked) {
                if (tokenProvider.isRedeemAvailable ) {

                  if(tokenProvider.gCashNumber.isNotEmpty){
                    if(!tokenProvider.isReviewing){
                      if(  await tokenProvider.redeemTokens(authProvider.user_id, amount, context) ){
                        showAuthDialog(context,type: "info" ,"Reviewing", "Under Review Process");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Token Redeemed! $requiredTokens'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }else{
                      showAuthDialog(context,type: "Warning" ,"Reviewing", "You Have Reviewing Transaction Under Review");
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Under Reviewing Process.'),
                            backgroundColor: Colors.orange,
                          )
                      );
                    }
                  }else{
                   showGcashNumberModal(context, (number) async {
                    await tokenProvider.updateGcashNumber(number as Future<String?>);
                   });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Add GCash Number.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }

                } else {
                  showAuthDialog(context,type: "Info" ,"Unavailable", "Withdrawal is currently unavailable.");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Withdrawal is currently unavailable.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } else {
                showAuthDialog(context,type: "Warning" ,"Warning", "Unlock requirements to redeem tokens!");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Unlock requirements to redeem tokens!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isUnlocked || isMinimumToken
                      ? [colorScheme.primaryContainer.withOpacity(0.9), colorScheme.secondaryContainer.withOpacity(0.1)]
                      : [Colors.grey.shade500, Colors.grey.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$requiredTokens Tokens',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '= $amount Pesos',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Icon(
                    isUnlocked ? Icons.lock_open_rounded : Icons.lock,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _BalanceToken(ColorScheme colorScheme, TokenProvider tokenProvider,BuildContext context){
    return  Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 40,horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.9),
            colorScheme.secondaryContainer.withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(15),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tokens Available", // Show current tokens for withdrawal
            style: TextStyle(
                fontSize: 18,
                color: colorScheme.primary,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 10),
          Text(
            "${tokenProvider.currentTokens} tokens =  ${tokenProvider.convertedValue} Pesos", // Show current tokens for withdrawal
            style: TextStyle(
                fontSize: 15,
                color: colorScheme.primary,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }


  Widget _DefaultPaymentMethod(ColorScheme colorScheme,TokenProvider tokenProvider,AuthProvider authProvider,BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.9),
            colorScheme.secondaryContainer.withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),

      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Align items properly
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet, // Wallet icon
                    color: colorScheme.secondary,
                    size: 30,
                  ),
                  SizedBox(width: 10), // Adjusted spacing for better alignment
                  Text(
                    "Default Payment Method:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.g_mobiledata_rounded,
                        size: 35, // Adjusted icon size for better balance
                        color: Colors.blue, // Optional: Add GCash theme color
                      ),
                      Text(
                        "Cash",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: (){
                      showGcashNumberModal(context, (number) async {
                        await tokenProvider.updateUserGcashNumber(authProvider.user_id, number);
                        await tokenProvider.updateGcashNumber( (await tokenProvider.getUserGcashNumber(authProvider.user_id)) as Future<String?>);
                      });
                    },
                      child: Text(tokenProvider.gCashNumber,style: TextStyle(color:colorScheme.primary.withOpacity(0.8)),)
                  )
                ],
              ),
            ],
          ),
        ],
      )

    );
  }
}