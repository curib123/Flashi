import 'package:flashi/presentation/widget/components/reviewer_settings_alert_content.dart';
import 'package:flashi/presentation/widget/components/theme_selector_dropdown.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onPrimary,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
