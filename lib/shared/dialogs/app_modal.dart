import 'package:flashi/core/design_system/app_motion.dart';
import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flutter/material.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'Close dialog',
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: Colors.black.withValues(alpha: .45),
    transitionDuration: AppMotion.standard,
    pageBuilder: (context, _, __) => builder(context),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.entranceCurve,
        reverseCurve: AppMotion.exitCurve,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .975, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.body,
    this.description,
    this.icon,
    this.actions = const [],
    this.maxWidth = 520,
    this.canClose = true,
  });

  final String title;
  final String? description;
  final IconData? icon;
  final Widget body;
  final List<Widget> actions;
  final double maxWidth;
  final bool canClose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: media.size.height - (AppSpacing.xl * 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: AppRadii.medium,
                      ),
                      child: Icon(icon, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (description case final description?) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (canClose)
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: body,
              ),
            ),
            if (actions.isNotEmpty) ...[
              Divider(height: 1, color: colors.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: actions,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool avoidKeyboard = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      final keyboard =
          avoidKeyboard ? MediaQuery.viewInsetsOf(context).bottom : 0.0;
      return Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 720,
              maxHeight: MediaQuery.sizeOf(context).height * .88,
            ),
            child: builder(context),
          ),
        ),
      );
    },
  );
}

class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.title,
    this.description,
  });

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (description case final description?) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
