import 'package:flashi/util/helpers/wepage_launcher.dart';
import 'package:flutter/material.dart';

void showUpdateDialog(BuildContext context, String currentVersion, String latestVersion, String downloadLink) {
  final colorScheme = Theme.of(context).colorScheme;

  showDialog(
    barrierDismissible: false,  // Keep this as false to prevent closing by tapping outside
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          // Prevent the back button from closing the dialog
          return Future.value(false);
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: colorScheme.surface,
          title: Row(
            children: [
              Icon(
                Icons.update_rounded,
                color: colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                "Update Required",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Text(
            "Your current app version, ${currentVersion}, is outdated. To experience the newest features and improvements, please update to version ${latestVersion}. If you prefer, you can still use the app offline.",
            style: TextStyle(
                color: colorScheme.primary,
                fontSize: 15
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(colorScheme.primary),
              ),
              onPressed: () {
                // Redirect to the update site
                WebPageLauncher(downloadLink).launch();
              },
              child: Text(
                "Update Now",
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}