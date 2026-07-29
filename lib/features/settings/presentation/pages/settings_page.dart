import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/app_surface.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/features/reviewer/presentation/widgets/reviewer_settings_content.dart';
import 'package:flashi/features/settings/presentation/widgets/theme_selector.dart';
import 'package:flashi/shared/widgets/app_page_header.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(
              title: 'Settings',
              description: 'Make Flashi feel and work the way you prefer.',
            ),
            Expanded(
              child: ResponsiveContent(
                maxWidth: AppBreakpoints.expanded,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= AppBreakpoints.medium;
                    final sections = [
                      const _SettingsSection(
                        icon: Icons.school_outlined,
                        title: 'Study preferences',
                        description: 'Configure how review sessions behave.',
                        child: ReviewerSettingsContent(),
                      ),
                      const _SettingsSection(
                        icon: Icons.contrast_outlined,
                        title: 'Appearance',
                        description:
                            'Choose your theme, typeface, and text size.',
                        child: ThemeSelector(isShowCloseBtn: false),
                      ),
                    ];
                    if (!wide) {
                      return ListView.separated(
                        itemCount: sections.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.xl),
                        itemBuilder: (_, index) => sections[index],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var index = 0;
                            index < sections.length;
                            index++) ...[
                          Expanded(child: sections[index]),
                          if (index != sections.length - 1)
                            const SizedBox(width: AppSpacing.lg),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      emphasized: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}
