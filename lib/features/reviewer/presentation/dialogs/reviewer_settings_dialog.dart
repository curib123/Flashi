import 'package:flashi/features/reviewer/presentation/widgets/reviewer_settings_content.dart';
import 'package:flutter/material.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';

void showReviewerSettingsDialog({
  required BuildContext context,
}) {
  showAppDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AppDialog(
        icon: Icons.tune_rounded,
        title: 'Study settings',
        description: 'Adjust timing, direction, and review behavior.',
        body: const ReviewerSettingsContent(),
        actions: [
          OutlinedButton(
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
