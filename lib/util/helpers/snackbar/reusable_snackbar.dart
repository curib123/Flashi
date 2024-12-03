import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// Reusable Snackbar function
void showCustomSnackbar({
  required BuildContext context,
  required String title,
  required String message,
  required ContentType contentType, // Content type, e.g., success or failure
}) {
  final snackBar = SnackBar(
    duration:const Duration(milliseconds: 500),
    margin: EdgeInsets.symmetric(vertical: 10),
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent, // Makes the Snackbar's background transparent
    content: AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: contentType, // Options: ContentType.success, ContentType.failure, etc.
    ),
  );

  // Hide the current Snackbar (if any) and show the new one
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
