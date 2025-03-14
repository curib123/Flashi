import 'dart:ui';
import 'package:flashi/presentation/screen/main/referral_code_screen.dart';
import 'package:flashi/presentation/screen/main/wallet_history.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flutter/material.dart';


Widget BalanceToken(ColorScheme colorScheme, TokenProvider tokenProvider, BuildContext context) {
  return Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WalletHistory()),
        );
      },
      splashColor: colorScheme.primary.withOpacity(0.2),
      highlightColor: colorScheme.primary.withOpacity(0.1),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glass blur effect
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wallet Balance",
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          "${tokenProvider.currentTokens}",
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.primary.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.diamond_rounded, size: 18, color: colorScheme.primary),

                        SizedBox(width: 8),

                        Text(
                          "= ${tokenProvider.convertedValue}",
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.primary.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.attach_money_rounded, size: 18, color: colorScheme.primary),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget inviteBtnContainer(ColorScheme colorScheme, BuildContext context, TokenProvider tokenProvider) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReferralCodeScreen()),
      );
    },
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.primaryContainer.withOpacity(0.15), // Glass effect
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Invite & Earn Rewards!",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Earn 1000 tokens per friend! Your friend gets ${tokenProvider.invite_reward} tokens too!",
                      style: TextStyle(
                        color: colorScheme.primary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colorScheme.primary.withOpacity(0.8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class DailyActivitiesTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final ColorScheme colorScheme;
  final void Function(double) onClaim;
  final double tokenRewards;

  const DailyActivitiesTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.colorScheme,
    required this.onClaim,
    required this.tokenRewards,
  }) : super(key: key);

  @override
  _DailyActivitiesTileState createState() => _DailyActivitiesTileState();
}

class _DailyActivitiesTileState extends State<DailyActivitiesTile> {
  bool isTapped = false;

  void handleTap() {
    setState(() => isTapped = true);
    Future.delayed(Duration(milliseconds: 150), () {
      setState(() => isTapped = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 5),
        margin: EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: isTapped ? widget.colorScheme.primary.withOpacity(0.15) : widget.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Colors.transparent,
          leading: Icon(widget.icon, color: widget.colorScheme.primary, size: 20),
          title: Text(
            widget.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
          trailing: GestureDetector(
            onTap: () => widget.onClaim(widget.tokenRewards),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(vertical: 7, horizontal: 16),
              decoration: BoxDecoration(
                color: widget.colorScheme.primary,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${widget.tokenRewards.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: widget.colorScheme.onPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.diamond_rounded, color: widget.colorScheme.onPrimary, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}