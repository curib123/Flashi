import 'package:flashi/core/services/external_link_service.dart';
import 'package:flutter/material.dart';

void showUpdateDialog(BuildContext context, String currentVersion,
    String latestVersion, String downloadLink, String patchNote) {
  final colorScheme = Theme.of(context).colorScheme;

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: colorScheme.surface,
          titlePadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actionsPadding: EdgeInsets.only(bottom: 15, right: 15),
          title: Row(
            children: [
              Icon(Icons.update_rounded, color: colorScheme.primary, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Update Required",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What's New",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(maxHeight: 150),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    patchNote,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  onPressed: () {
                    ExternalLinkService(downloadLink).launch();
                  },
                  child: Text(
                    "Update Now",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
