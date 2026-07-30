import 'package:flashi/shared/dialogs/app_modal.dart';
import 'package:flutter/material.dart';

void showAddSlotAlertDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
}) {
  showAppDialog<void>(
    context: context,
    builder: (context) => AppDialog(
      icon: Icons.add_card_outlined,
      title: 'Add two card slots?',
      description: 'This uses 1 energy from your balance.',
      body: const Text(
        'The additional slots are added to this quiz set immediately.',
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          icon: const Icon(Icons.bolt_rounded),
          label: const Text('Use 1 energy'),
        ),
      ],
    ),
  );
}
