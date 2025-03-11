import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flashi/util/helpers/widget/modals/show_gcash_number_dialog.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
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

    final tokenProvider = Provider.of<TokenProvider>(context,listen: false);
    final authProvider = Provider.of<AuthProvider>(context,listen: false);
    Future.delayed(Duration.zero, () async {
      await   tokenProvider.fetchTokens(authProvider.user_id);
      await tokenProvider.updateGcashNumber(tokenProvider.getUserGcashNumber(authProvider.user_id));
      await tokenProvider.updateIsReviewing(authProvider.user_id);
      await  tokenProvider.fetchPayoutDate();
    });

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
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BalanceToken(colorScheme, tokenProvider,context),
                SizedBox(height: 10),

                _DefaultPaymentMethod(colorScheme,tokenProvider,authProvider,context),
                SizedBox(height: 10),

                _PayoutList(colorScheme, tokenProvider, context,authProvider),
                SizedBox(height: 10),
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

  Widget _PayoutList(ColorScheme colorScheme, TokenProvider tokenProvider, BuildContext context, AuthProvider authProvider) {
    int userTokens = tokenProvider.currentTokens;
    List payoutOptions = tokenProvider.payoutOptions;

    return Center(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.3, // Adjust for better card proportions
        ),
        itemCount: payoutOptions.length,
        itemBuilder: (context, index) {
          var payout = payoutOptions[index];
          int requiredTokens = payout["tokens"] ?? 0;
          int amount = payout["amount"] ?? 0;
          bool isMinimumToken = tokenProvider.minimumTokens == requiredTokens;
          bool isUnlocked = isMinimumToken || (userTokens >= requiredTokens && tokenProvider.isSuccessFullFirstPayout);

          return GestureDetector(
            onTap: () async {
              await tokenProvider.updateIsReviewing(authProvider.user_id);
              if (isUnlocked) {
                if (tokenProvider.isRedeemAvailable) {
                  if (tokenProvider.gCashNumber.isNotEmpty) {
                    if (!tokenProvider.isReviewing) {
                      if (await tokenProvider.redeemTokens(authProvider.user_id, amount, context)) {
                        showAuthDialog(context, type: "info", "Reviewing", "Under Review Process");
                        _showSnackBar(context, 'Token Redeemed! $requiredTokens', Colors.green);
                      }
                    } else {
                      showAuthDialog(context, type: "Warning", "Reviewing", "You Have Reviewing Transaction Under Review");
                      _showSnackBar(context, 'Under Reviewing Process.', Colors.orange);
                    }
                  } else {
                    showGcashNumberModal(context, (number) async {
                      await tokenProvider.updateGcashNumber(number as Future<String?>);
                    });
                    _showSnackBar(context, 'Add GCash Number.', Colors.orange);
                  }
                } else {
                  showAuthDialog(context, type: "Info", "Unavailable", "Withdrawal is currently unavailable.");
                  _showSnackBar(context, 'Withdrawal is currently unavailable.', Colors.orange);
                }
              } else {
                showAuthDialog(context, type: "Warning", "Warning", "Unlock requirements to redeem tokens!");
                _showSnackBar(context, 'Unlock requirements to redeem tokens!', Colors.red);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isUnlocked || isMinimumToken
                      ? [colorScheme.tertiary.withOpacity(1), colorScheme.tertiary.withOpacity(0.5)]
                      : [Colors.grey.shade500, Colors.grey.shade300],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$requiredTokens',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.diamond_rounded, size: 25,color: FlexColor.goldDarkPrimary,),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '= $amount Pesos',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Icon(
                    isUnlocked ? Icons.lock_open_rounded : Icons.lock,
                    color: colorScheme.onPrimary,
                    size: 24,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bgColor),
    );
  }

  Widget _BalanceToken(ColorScheme colorScheme, TokenProvider tokenProvider,BuildContext context){
    return  Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary.withOpacity(1),
            colorScheme.secondary.withOpacity(0.5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tokens Available", // Show current tokens for withdrawal
            style: TextStyle(
                fontSize: 18,
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Row(
                children: [
                  Text(
                    "${tokenProvider.currentTokens}", // Show current tokens for withdrawal
                    style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.diamond_rounded, size: 25,color: FlexColor.goldDarkPrimary,),
                ],
              ),
              SizedBox(width: 10),
              Text(
                "=  ${tokenProvider.convertedValue} Pesos", // Show current tokens for withdrawal
                style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold
                ),
              )
            ],
          ),


        ],
      ),
    );
  }
  Widget _DefaultPaymentMethod(
      ColorScheme colorScheme, TokenProvider tokenProvider, AuthProvider authProvider, BuildContext context) {

    String selectedMethod = tokenProvider.payoutMethod;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.9),
            colorScheme.secondary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wallet_rounded, color: colorScheme.onSecondary, size: 30),
              SizedBox(width: 10),
              Text(
                "Default Payment Method",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedMethod,
              dropdownColor: colorScheme.primary.withOpacity(0.8),
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.onPrimary),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  tokenProvider.updatePayoutMethod(newValue);
                }
              },
              items: tokenProvider.paymentMethods.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(
                        value == "GCash"
                            ? Icons.phone_android
                            : value == "PayPal"
                            ? Icons.account_balance_wallet
                            : Icons.account_balance, // Default for bank
                        size: 24,
                        color: colorScheme.onSecondary,
                      ),
                      SizedBox(width: 10),
                      Text(value, style: TextStyle(color: colorScheme.onPrimary, fontSize: 16)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),

          // Payment Details Section
          if (selectedMethod == "GCash")
            GestureDetector(
              onTap: () {
                showGcashNumberModal(context, (number) async {
                  await tokenProvider.updateUserGcashNumber(authProvider.user_id, number);
                  await tokenProvider.updateGcashNumber(
                      (await tokenProvider.getUserGcashNumber(authProvider.user_id)) as Future<String?>);
                });
              },
              child: _buildPaymentField("GCash Number", tokenProvider.gCashNumber, colorScheme),
            )
          else if (selectedMethod == "PayPal")
            GestureDetector(
              onTap: () {
               showGcashNumberModal(context, (number){});
              },
              child: _buildPaymentField("PayPal Email ","", colorScheme),
            ),
        ],
      ),
    );
  }



// Payment Field UI
  Widget _buildPaymentField(String label, String value, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.onPrimary.withOpacity(0.5)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        color: colorScheme.surface.withOpacity(0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}