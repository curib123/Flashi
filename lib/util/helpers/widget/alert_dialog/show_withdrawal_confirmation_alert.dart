import 'package:flutter/material.dart';

void showWithdrawConfirmationDialog(
    BuildContext context,
    String paymentMethod,
    String receiversName,
    String amount,
    ColorScheme colorScheme,
    VoidCallback onConfirm,
    ) {
  IconData methodIcon = Icons.account_balance; // Default icon

  if (paymentMethod == "GCash") {
    methodIcon = Icons.phone_android;
  } else if (paymentMethod == "PayPal") {
    methodIcon = Icons.account_balance_wallet;
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Withdraw Confirmation",
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Column(
            children: [
              Icon(methodIcon, size: 50, color: colorScheme.primary),
              SizedBox(height: 10),
              Text(
                "Confirm Withdrawal",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You're withdrawing:",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.attach_money_rounded, color: colorScheme.primary, size: 35),
                  Text(
                    "$amount",
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ],
              ),
              Divider(height: 20, thickness: 1, color: colorScheme.onSurface.withOpacity(0.3)),
              Text(
                "Receiver:",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
              ),
              SizedBox(height: 5),
              Text(
                receiversName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              SizedBox(height: 10),
              Text(
                "Payment Method: $paymentMethod",
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.secondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
              child: Text("Confirm", style: TextStyle(color: colorScheme.onPrimary)),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: child,
      );
    },
  );
}