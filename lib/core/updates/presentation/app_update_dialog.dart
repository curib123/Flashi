import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/services/external_link_service.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';
import 'package:flutter/material.dart';

void showAppUpdateDialog(
  BuildContext context,
  String currentVersion,
  String latestVersion,
  String downloadLink,
  String patchNote,
) {
  showAppDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AppDialog(
        icon: Icons.system_update_alt_rounded,
        title: 'Update required',
        description: 'Version $latestVersion is ready to install.',
        canClose: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("What's new", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: AppRadii.medium,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Text(patchNote),
            ),
          ],
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => ExternalLinkService(downloadLink).launch(),
            icon: const Icon(Icons.download_rounded),
            label: const Text('Update now'),
          ),
        ],
      ),
    ),
  );
}
