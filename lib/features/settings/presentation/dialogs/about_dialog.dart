import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/updates/application/app_update_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showAppAboutDialog(BuildContext context) {
  final updates = context.read<AppUpdateProvider>();

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close about dialog',
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Flashi',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Quiz Maker & Learner',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _AboutItem(
                    icon: Icons.rocket_launch_outlined,
                    label: 'Version',
                    value: updates.currentVersion.isEmpty
                        ? 'Unknown'
                        : updates.currentVersion,
                  ),
                  const _AboutItem(
                    icon: Icons.code_outlined,
                    label: 'Developer',
                    value: 'Curib Tech',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AboutItem extends StatelessWidget {
  const _AboutItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
