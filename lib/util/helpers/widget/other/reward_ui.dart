import 'package:flashi/provider/token_provider.dart';
import 'package:flutter/material.dart';

Widget BalanceToken(ColorScheme colorScheme, TokenProvider tokenProvider,BuildContext context){
  return  Container(
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          colorScheme.secondaryContainer.withOpacity(0.7),
          colorScheme.secondary.withOpacity(0.9),

        ],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ),
      borderRadius: BorderRadius.all(Radius.circular(10)),

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
                Icon(Icons.diamond_rounded, size: 25,color: colorScheme.onPrimary,),
              ],
            ),
            SizedBox(width: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "=  ${tokenProvider.convertedValue} ", // Show current tokens for withdrawal
                  style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(width: 5),
                Icon(Icons.attach_money_rounded, size: 25, color: colorScheme.onPrimary),
              ],
            ),

          ],
        ),


      ],
    ),
  );
}