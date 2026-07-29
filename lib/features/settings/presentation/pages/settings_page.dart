import 'package:flashi/presentation/widget/components/reviewer_settings_alert_content.dart';
import 'package:flashi/presentation/widget/components/theme_selector_dropdown.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.primary,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(),
        ),
        backgroundColor: colorScheme.onPrimary,
        foregroundColor: colorScheme.primary,
        title: Text(
          "Settings",
          style: TextStyle(color: colorScheme.primary),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: _settings(context),
      ),
    );
  }

  Widget _settings(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 30),
        const ReviewerSettingsAlertContent(),
        const SizedBox(height: 50),
        const ThemeSelector(
          isShowCloseBtn: false,
        ),
      ],
    );
  }
}
