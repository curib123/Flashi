import 'package:flashi/presentation/screen/main/wallet_history.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flutter/material.dart';
Widget BalanceToken(ColorScheme colorScheme, TokenProvider tokenProvider, BuildContext context) {
  return Material(
    color: Colors.transparent, // Keep the gradient background visible
    borderRadius: BorderRadius.circular(10), // Ensure ripple effect follows border radius
    child: InkWell(
      borderRadius: BorderRadius.circular(10), // Apply the same border radius for ripple effect
      onTap: () {
        // Add your onTap logic here
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WalletHistory()));
      },
      splashColor: colorScheme.primary.withOpacity(0.3), // Highlight color on tap
      highlightColor: colorScheme.primary.withOpacity(0.1), // Subtle effect when tapped
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.7),
              colorScheme.primary.withOpacity(0.9),
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tokens Available",
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          "${tokenProvider.currentTokens}",
                          style: TextStyle(
                            fontSize: 15,
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.diamond_rounded, size: 25, color: colorScheme.onPrimary),
                      ],
                    ),
                    SizedBox(width: 5),
                    Row(
                      children: [
                        Text(
                          "= ${tokenProvider.convertedValue}",
                          style: TextStyle(
                            fontSize: 15,
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 1),
                        Icon(Icons.attach_money_rounded, size: 25, color: colorScheme.onPrimary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 25, color: colorScheme.onPrimary),
          ],
        ),
      ),
    ),
  );
}
