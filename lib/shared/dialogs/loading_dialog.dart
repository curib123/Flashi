import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';
import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context, {required String text}) {
  showAppDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AppDialog(
        icon: Icons.auto_awesome_rounded,
        title: 'Working on it',
        canClose: false,
        body: Row(
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    ),
  );
}
