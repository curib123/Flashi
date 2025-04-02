import 'dart:ui';

import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class ReferralCodeScreen extends StatefulWidget {
  const ReferralCodeScreen({super.key});

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.onPrimary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Makes the Scaffold inherit the gradient
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onPrimary,
            ),
          ),
          backgroundColor: Colors.transparent, // Makes the AppBar inherit the gradient
          elevation: 0, // Removes the AppBar shadow
          title: Text("Invite Friends", style: TextStyle(color: colorScheme.onPrimary,fontWeight: FontWeight.bold,fontSize: 25)),
          centerTitle: true,
        ),
        body: Consumer2<TokenProvider,AuthProvider>(
          builder: (context, tokenProvider,authProvider, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 _rules(colorScheme,tokenProvider),
                  SizedBox(height: 20),
                  downloadLink('https://flashi.en.uptodown.com/android/download', context,colorScheme),
                  SizedBox(height: 20),
                  _referralCode(colorScheme, tokenProvider,context),
                  SizedBox(height: 20),
                  _enterReferralCode(colorScheme, tokenProvider,authProvider,tokenProvider.getAllReferralCodes(), context),
                  SizedBox(height: 20,),
                  _statisticsRow(colorScheme),


                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _rules(ColorScheme colorScheme, TokenProvider tokenProvider,) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.primary.withOpacity(0.3),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ruleItem(
            colorScheme,
            "Share your unique referral code with your friends and get  ${tokenProvider.invite_reward} tokens for every friend who enters your code. Your friend will also receive ${tokenProvider.invite_reward} tokens."
        ),
        _ruleItem(
            colorScheme,
            "Redeem your collected tokens for Gcash money and enjoy real rewards!"
        ),

      ],
    ),
  );
}

Widget _ruleItem(ColorScheme colorScheme, String text) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 1),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: colorScheme.onPrimary,fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

Widget _referralCode(ColorScheme colorScheme, TokenProvider tokenProvider, BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.primary.withOpacity(0.3),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "Your referral code: \n ${tokenProvider.referralCode}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(Icons.copy, size: 18,color: colorScheme.onPrimary,),
          label: Text("Copy"),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: tokenProvider.referralCode));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Referral code copied!"),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          },
        ),
      ],
    ),
  );
}



Widget _enterReferralCode(ColorScheme colorScheme, TokenProvider tokenProvider,AuthProvider authProvider,getAllReferralCodes, BuildContext context)  {
  TextEditingController _controller = TextEditingController();
  FlutterSecureStorage storage = FlutterSecureStorage();

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.primary.withOpacity(0.3),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Enter your Friends Code",
              hintStyle: TextStyle(fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.primaryContainer.withOpacity(0.5),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text("Enter Code"),
          onPressed: () async {
            String enteredCode = _controller.text.trim();
            final String deviceId = await tokenProvider.getDeviceId();
            await storage.read(key: deviceId,);
            bool isCodeExistInDevice = (await tokenProvider.getDevicesReferralCode()).isEmpty;
            print(isCodeExistInDevice);

            if (enteredCode.isNotEmpty && tokenProvider.referralCode != enteredCode) {
              // Handle referral code submission (replace this with your logic)
              if (await tokenProvider.isReferredByEmpty(authProvider.user_id) && isCodeExistInDevice) {
                if (await tokenProvider.isReferralCodeValid(enteredCode)) {
                  await tokenProvider.SaveReferredBy(authProvider.user_id, enteredCode);
                  final String deviceId = await tokenProvider.getDeviceId();
                  await storage.write(key: deviceId, value: enteredCode);
                  showAuthDialog(
                      context,
                      type: "success",
                      "Referral Code Applied",
                     "You earned ${tokenProvider.invite_reward} tokens."
                  );
                } else {
                  showAuthDialog(
                      context,
                      type: "warning",
                      "Referral Code Invalid",
                       "Invalid referral code. Please enter a valid code."
                  );
                }
              } else {
                showAuthDialog(
                    context,
                    type: "warning",
                    "Already Reffered",
                     "This Device has already been referred by someone ."
                );
              }


              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Referral code used: $enteredCode"),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            }else{
              showAuthDialog(context,type:  "warning", "Referral Code Invalid",  "Enter other Referral code to get ${tokenProvider.invite_reward} tokens. ");
            }
          },
        ),
      ],
    ),
  );
}

Widget _statisticsRow(ColorScheme colorScheme) {
  return Consumer2<TokenProvider, AuthProvider>(
    builder: (context, tokenProvider, authProvider, child) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.primary.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.diamond_rounded, color: colorScheme.onPrimary,
                      size: 28),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Earned Tokens",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${tokenProvider.totalInviteToken}", // Fetch from provider
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.person, color: colorScheme.onPrimary, size: 28),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ToTal Invites",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${tokenProvider.totalInvite}", // Fetch from provider
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

}

Widget downloadLink(String downloadLink, BuildContext context, ColorScheme colorScheme) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withOpacity(0.1),
    ),
    child: ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Share this link with your friends!",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Tell your friends to download and install the app. Once they open it, they can enter your referral code to receive bonus tokens. The more friends who use your code, the more rewards you earn!",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            downloadLink,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: colorScheme.primary),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: colorScheme.primary),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: downloadLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Link copied to clipboard!"),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: colorScheme.secondary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

}