import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_withdrawal_confirmation_alert.dart';
import 'package:flashi/util/helpers/widget/modals/show_payment_method_modal.dart';
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

class _RewardsScreenState extends State<RewardsScreen> {
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    fetchDataTokens(context, checkInternet);
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
          isEnergyShow: false,
          colorScheme: colorScheme,
          title: "Invite to Earn",
          onUpgradePro: () {},
          onSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ),
      body: Consumer2<TokenProvider, AuthProvider>(
        builder: (context, tokenProvider, authProvider, child) {
          return authProvider.user_id.isNotEmpty
              ? ListView(
            padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
            children: [
              BalanceToken(colorScheme, tokenProvider, context),
              const SizedBox(height: 5),
              inviteBtnContainer(colorScheme, context, tokenProvider),
              SizedBox(height: 10),
              _DefaultPaymentMethod(colorScheme,context),
              SizedBox(height: 10),
              _PayoutList(colorScheme, tokenProvider, context,authProvider),
              SizedBox(height: 10),
              _DateOfPayout(colorScheme, tokenProvider),

            ],
          )
              : isOfflineOrNotSignIn(colorScheme, context);
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
    double userTokens = tokenProvider.currentTokens;
    List payoutOptions = tokenProvider.payoutOptions;

    return Center(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1.8,
        ),
        itemCount: payoutOptions.length,
        itemBuilder: (context, index) {
          var payout = payoutOptions[index];
          double requiredTokens = payout["tokens"] ?? 0;
          double amount = payout["amount"] ?? 0;
          bool isMinimumToken = tokenProvider.minimumTokens == requiredTokens;
          bool isUnlocked = isMinimumToken || (userTokens >= requiredTokens && tokenProvider.isSuccessFullFirstPayout);

          return GestureDetector(
              onTap: () async {
                await tokenProvider.updateIsReviewing(authProvider.user_id);

                if (isUnlocked) {
                  if (tokenProvider.isRedeemAvailable) {
                    if((tokenProvider.payoutMethod == "GCash" && tokenProvider.gCashNumber.isNotEmpty && tokenProvider.gCashNumber.length >= 11) ||
                        (tokenProvider.payoutMethod == "PayPal" && tokenProvider.paypalEmail.isNotEmpty && EmailValidator.validate(tokenProvider.paypalEmail)))
                    {
                      if (!tokenProvider.isReviewing) {
                        showWithdrawConfirmationDialog(
                          context,
                          tokenProvider.payoutMethod,
                          tokenProvider.payoutMethod == "GCash" ? tokenProvider.gCashNumber : tokenProvider.paypalEmail,
                          amount.toString(),
                          colorScheme, () {
                          showLoadingDialog(context, text: "processing");
                          Future.delayed(Duration(seconds: 2),() async {
                            Navigator.pop(context);
                            await tokenProvider.redeemTokens(authProvider.user_id,amount ,requiredTokens,authProvider ,context);
                          });
                        },
                        );
                      } else {
                        showAuthDialog(context, type: "warning", "Pending Review", "You already have a transaction under review. \n Wait for approval.");
                        _showSnackBar(context, 'Your request is being processed. Please wait.', Colors.orange);
                      }
                    } else {
                      showPaymentMethodModal(context, tokenProvider.payoutMethod, (value) {
                        if (tokenProvider.payoutMethod == "GCash" && value.isNotEmpty) {
                          tokenProvider.updateGcashNumber(value);
                        } else if (tokenProvider.payoutMethod == "PayPal" && value.isNotEmpty) {
                          tokenProvider.updatePaypalEmail(value);
                        }
                      });
                      _showSnackBar(context, 'Please add your ${tokenProvider.payoutMethod} details to proceed.', Colors.orange);
                    }
                  } else {
                    showAuthDialog(context, type: "info", "Unavailable", "Withdrawals are currently unavailable. Please check back later.");
                    _showSnackBar(context, 'Withdrawals are temporarily unavailable. Please wait for the next payout.', Colors.orange);
                  }
                } else {
                  showAuthDialog(context, type: "warning", "Unlock Required", "You need to withdraw ${tokenProvider.minimumTokens} tokens first before accessing other payouts.");
                  _showSnackBar(context, 'Complete the required withdrawal to unlock more options.', Colors.red);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
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
                            color: colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.diamond_rounded, size: 20, color : colorScheme.primary),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '= $amount',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.attach_money_rounded, size: 20, color: colorScheme.primary),
                      ],
                    ),
                    SizedBox(height: 5),
                    Icon(
                      isUnlocked ? Icons.lock_open_rounded : Icons.lock,
                      color:colorScheme.primary,
                      size: 24,
                    ),
                  ],
                ),
              )

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

  Widget _DefaultPaymentMethod(ColorScheme colorScheme, BuildContext context) {
    return Consumer2<TokenProvider, AuthProvider>(
      builder: (context, tokenProvider, authProvider, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: tokenProvider.payoutMethod,
                      dropdownColor: colorScheme.onPrimary,
                      icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 14,
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
                                    : Icons.account_balance,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              SizedBox(width: 8),
                              Text(value, style: TextStyle(color: colorScheme.primary, fontSize: 14)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Payment Details Section
                  if (tokenProvider.payoutMethod == "GCash")
                    GestureDetector(
                      onTap: () {
                        showPaymentMethodModal(context, "GCash", (value) {
                          tokenProvider.updateGcashNumber(value.isEmpty ? "" : value);
                        });
                      },
                      child: _buildPaymentField("GCash Number", tokenProvider.gCashNumber, colorScheme),
                    )
                  else if (tokenProvider.payoutMethod == "PayPal")
                    GestureDetector(
                      onTap: () {
                        showPaymentMethodModal(context, "PayPal", (value) {
                          tokenProvider.updatePaypalEmail(value.isEmpty ? "" : value);
                        });
                      },
                      child: _buildPaymentField("PayPal Email", tokenProvider.paypalEmail, colorScheme),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



// Payment Field UI
  Widget _buildPaymentField(String label, String value, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.primary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.primary.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: value.length >= 16 ? 12 : 16,
            ),
          ),
        ],
      ),
    );
  }
}