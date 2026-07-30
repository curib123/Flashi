import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';
import 'package:flutter/material.dart';

void showDeleteConfirmationDialog({
  required BuildContext context,
  required String setName,
  required Function() onDelete,
}) {
  showAppDialog<void>(
    context: context,
    builder: (context) {
      final colors = Theme.of(context).colorScheme;
      return AppDialog(
        icon: Icons.delete_outline_rounded,
        title: 'Delete quiz set?',
        description: 'This action cannot be undone.',
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '“$setName” and all of its cards will be permanently removed.',
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () {
              Navigator.pop(context);
              onDelete();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: colors.errorContainer,
                  content: Row(
                    children: [
                      Icon(Icons.delete_rounded,
                          color: colors.onErrorContainer),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '$setName deleted',
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.delete_rounded),
            label: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
