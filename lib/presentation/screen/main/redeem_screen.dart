import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
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
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Icon(
              Icons.notes_rounded,
              size: 30,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: ReusableTitleContent(
          colorScheme: colorScheme,
          title: "Redeem",
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
                _BalanceToken(colorScheme, tokenProvider,context),
                SizedBox(height: 30),
                _PayoutList(colorScheme, tokenProvider, context,authProvider),
                SizedBox(height: 30),
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
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

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: tokenProvider.payoutOptions.map((payout) {
        int requiredTokens = payout["tokens"] ?? 0;
        int amount = payout["amount"] ?? 0;
        bool isMinimumToken = tokenProvider.minimumTokens == requiredTokens;
        bool isUnlocked = isMinimumToken || (userTokens >= requiredTokens && tokenProvider.isUnlockedLowerPayouts);

        return GestureDetector(
          onTap: () async {
            if (isUnlocked) {
              if (tokenProvider.isRedeemAvailable) {
                await tokenProvider.redeemTokens(authProvider.user_id, requiredTokens, context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Token Redeemed! $requiredTokens'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Redemption is currently unavailable.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Unlock requirements to redeem tokens!'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Container(
            width: 150,
            height: 120,
            padding: const EdgeInsets.all(12),
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
    );
  }

  Widget _BalanceToken(ColorScheme colorScheme, TokenProvider tokenProvider,BuildContext context){
    return  Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.9),
            colorScheme.secondaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12.0,
            offset: Offset(4, 4),
          ),

        ],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Withdraw via GCash", // Label for GCash withdrawal
            style: TextStyle(
                fontSize: 20,
                color: colorScheme.primary,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Tokens Available", // Show current tokens for withdrawal
            style: TextStyle(
                fontSize: 18,
                color: colorScheme.primary,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 15),
          Text(
            "${tokenProvider.currentTokens} tokens =  ${tokenProvider.convertedValue} Pesos", // Show current tokens for withdrawal
            style: TextStyle(
                fontSize: 18,
                color: colorScheme.primary,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}