import 'package:flashi/features/reviewer/presentation/widgets/reviewer_settings_content.dart';
import 'package:flutter/material.dart';

void showReviewerSettingsDialog({
  required BuildContext context,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Study settings"),
        content: const ReviewerSettingsContent(),
        scrollable: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
