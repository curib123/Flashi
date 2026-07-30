import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_semantic_colors.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showWatchAdDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelText,
  required String confirmText,
  required VoidCallback onWatchAd,
}) {
  showAppDialog<void>(
    context: context,
    builder: (context) => Consumer<AiCreditProvider>(
      builder: (context, credits, child) {
        final semantic = Theme.of(context).extension<AppSemanticColors>()!;
        final available = credits.adsWatchedToday < credits.maxAdsPerDay &&
            credits.adCooldown == 0;
        return AppDialog(
          icon: Icons.play_circle_outline_rounded,
          title: title,
          description: message,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: AppRadii.medium,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.video_library_outlined),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${credits.adsWatchedToday} of '
                        '${credits.maxAdsPerDay} ads watched today',
                      ),
                    ),
                  ],
                ),
              ),
              if (credits.adCooldown > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: semantic.warning),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Available again in ${credits.adCooldown} seconds',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelText),
            ),
            FilledButton.icon(
              onPressed: available
                  ? () {
                      Navigator.pop(context);
                      onWatchAd();
                    }
                  : null,
              icon: Icon(
                available ? Icons.play_arrow_rounded : Icons.timer_outlined,
              ),
              label: Text(
                credits.adCooldown > 0
                    ? 'Wait ${credits.adCooldown}s'
                    : confirmText,
              ),
            ),
          ],
        );
      },
    ),
  );
}
