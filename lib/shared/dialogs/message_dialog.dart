import 'package:flashi/core/design_system/app_motion.dart';
import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_semantic_colors.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flutter/material.dart';

void showMessageDialog(
  BuildContext context,
  String title,
  String message, {
  String type = 'info',
}) {
  final semantic = Theme.of(context).extension<AppSemanticColors>()!;
  final status = switch (type) {
    'success' => _DialogStatus(
        label: 'Success',
        icon: Icons.check_circle_rounded,
        color: semantic.success,
        container: semantic.successContainer,
        onContainer: semantic.onSuccessContainer,
      ),
    'error' => _DialogStatus(
        label: 'Error',
        icon: Icons.error_rounded,
        color: Theme.of(context).colorScheme.error,
        container: Theme.of(context).colorScheme.errorContainer,
        onContainer: Theme.of(context).colorScheme.onErrorContainer,
      ),
    'warning' => _DialogStatus(
        label: 'Warning',
        icon: Icons.warning_amber_rounded,
        color: semantic.warning,
        container: semantic.warningContainer,
        onContainer: semantic.onWarningContainer,
      ),
    _ => _DialogStatus(
        label: 'Information',
        icon: Icons.info_rounded,
        color: semantic.info,
        container: semantic.infoContainer,
        onContainer: semantic.onInfoContainer,
      ),
  };

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    transitionDuration: AppMotion.standard,
    pageBuilder: (context, _, __) {
      return AlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: status.container,
            borderRadius: AppRadii.medium,
            border: Border.all(color: status.color),
          ),
          child: Icon(status.icon, color: status.onContainer, size: 28),
        ),
        title: Column(
          children: [
            Text(
              status.label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.entranceCurve,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .98, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _DialogStatus {
  const _DialogStatus({
    required this.label,
    required this.icon,
    required this.color,
    required this.container,
    required this.onContainer,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color container;
  final Color onContainer;
}
