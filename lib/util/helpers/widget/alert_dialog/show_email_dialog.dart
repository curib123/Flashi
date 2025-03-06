import 'package:flashi/provider/auth_provider.dart';
import 'package:flutter/material.dart';

void showEmailResetInputDialog(BuildContext context, AuthProvider authProvider) {
  final theme = Theme.of(context);
  final TextEditingController emailController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Center( // Center title
          child: Text(
            "Reset Password",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter your email to receive a password reset link.",
                  textAlign: TextAlign.center, // Center text
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center, // Center input text
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter your email",
                    filled: true,
                    fillColor: theme.colorScheme.primary.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.email, color: theme.colorScheme.primary),
                  ),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center, // Center buttons
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              authProvider.emailController.text = emailController.text;
              Navigator.pop(context); // Close dialog
              await authProvider.resetPassword(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Send"),
          ),
        ],
      );
    },
  );
}
