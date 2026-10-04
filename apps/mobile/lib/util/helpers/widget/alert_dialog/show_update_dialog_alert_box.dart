import 'package:flashi/util/helpers/classes/other/wepage_launcher.dart';
import 'package:flutter/material.dart';

void showUpdateDialog(
  BuildContext context,
  String currentVersion,
  String latestVersion,
  String downloadLink,
  String patchNote,
) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;

      return PopScope(
        canPop: false,
        child: AlertDialog(
          icon: Icon(
            Icons.system_update_alt_rounded,
            color: colorScheme.primary,
            size: 34,
          ),
          title: const Text(
            'Update required',
            textAlign: TextAlign.center,
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version $currentVersion → $latestVersion',
                  style: Theme.of(dialogContext).textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 14),
                Text(
                  "What's new",
                  style: Theme.of(dialogContext).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      patchNote,
                      style: Theme.of(dialogContext).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton.icon(
              onPressed: () => WebPageLauncher(downloadLink).launch(),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Update now'),
            ),
          ],
        ),
      );
    },
  );
}
