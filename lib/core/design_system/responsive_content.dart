import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'app_spacing.dart';

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.contentMaxWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.sizeOf(context).width < AppBreakpoints.compact
        ? AppSpacing.md
        : AppSpacing.lg;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: AppSpacing.lg,
              ),
          child: child,
        ),
      ),
    );
  }
}
