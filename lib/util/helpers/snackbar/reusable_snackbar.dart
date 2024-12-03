import 'package:flutter/material.dart';

// Reusable Snackbar function
void showCustomSnackbar({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 2), // Default duration
}) {

  final colorScheme =  Theme.of(context).colorScheme;
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color:colorScheme.primary), // Message text style
    ),
    backgroundColor: colorScheme.primaryContainer,
    duration: duration,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(vertical: 70, horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  // Show the Snackbar
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar() // Ensure no duplicate Snackbars
    ..showSnackBar(snackBar);
}
