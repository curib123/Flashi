import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/widget/components/reviewer_settings_alert_content.dart';
import 'package:flashi/presentation/widget/components/theme_selector_dropdown.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          FlashiDesign.pagePadding,
          8,
          FlashiDesign.pagePadding,
          40,
        ),
        children: [
          Text(
            'Personalize Flashi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Keep the interface comfortable and your study sessions focused.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(0.65),
                ),
          ),
          const SizedBox(height: 24),
          _SettingsCard(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            child: const ThemeSelector(isShowCloseBtn: false),
          ),
          const SizedBox(height: 16),
          const _SettingsCard(
            title: 'Study preferences',
            icon: Icons.tune_rounded,
            child: ReviewerSettingsAlertContent(),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(FlashiDesign.radius),
        border: Border.all(color: colors.outline.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
