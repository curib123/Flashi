import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/app_surface.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/features/reviewer/presentation/widgets/reviewer_settings_content.dart';
import 'package:flashi/features/settings/presentation/widgets/theme_selector.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ResponsiveContent(
        maxWidth: AppBreakpoints.readingMaxWidth,
        child: ListView(
          children: const [
            _SectionHeader(
              title: 'Study preferences',
              description: 'Configure how review sessions behave.',
            ),
            SizedBox(height: AppSpacing.sm),
            AppSurface(child: ReviewerSettingsContent()),
            SizedBox(height: AppSpacing.xl),
            _SectionHeader(
              title: 'Appearance',
              description: 'Choose the theme, typeface, and text size.',
            ),
            SizedBox(height: AppSpacing.sm),
            AppSurface(
              child: ThemeSelector(isShowCloseBtn: false),
            ),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
