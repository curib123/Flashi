import 'package:flashlearn/presentation/widget/components/reviewer_settings_alert_content.dart';
import 'package:flutter/material.dart';

void reviewerSettingsAlertBox({
  required BuildContext context,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      return AlertDialog(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        elevation: 15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        // Dialog Title
        title: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Text(
            "Reviewer Settings",
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Dialog Content
        content: const ReviewerSettingsAlertContent(),
        scrollable: true,

        // Actions
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
        actions: [
          // Cancel Button
          _buildActionButton(
            context: context,
            label: "Cancel",
            color: colorScheme.error,
            textColor: colorScheme.onError,
            onPressed: () => Navigator.of(context).pop(),
          ),

          // Save Button
          _buildActionButton(
            context: context,
            label: "Save",
            color: colorScheme.secondary,
            textColor: colorScheme.onPrimary,
            onPressed: () {
              // Trigger updates in the Provider
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// Helper widget for Buttons
Widget _buildActionButton({
  required BuildContext context,
  required String label,
  required Color color,
  required Color textColor,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    ),
    onPressed: onPressed,
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
