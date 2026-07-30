import 'package:flashi/core/design_system/app_semantic_colors.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void showFreeCreditsDialog({
  required BuildContext context,
  required String rewardText,
  required Function() onClaim,
}) {
  showAppDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final semantic = Theme.of(context).extension<AppSemanticColors>()!;
      return PopScope(
        canPop: false,
        child: AppDialog(
          icon: Icons.redeem_rounded,
          title: 'Daily reward',
          description: 'Your learning energy has been refreshed.',
          canClose: false,
          body: Column(
            children: [
              Icon(
                Icons.bolt_rounded,
                size: 48,
                color: semantic.warning,
              ).animate().scale(
                    duration: 360.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: AppSpacing.md),
              Text(
                rewardText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          actions: [
            FilledButton.icon(
              onPressed: () {
                onClaim();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Claim reward'),
            ),
          ],
        ),
      );
    },
  );
}
