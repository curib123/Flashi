import 'package:flashlearn/presentation/widget/components/reviewer_settings_alert_content.dart';
import 'package:flashlearn/presentation/widget/components/theme_selector_dropdown.dart';
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
        _sectionHeader('FlashCard Settings'),
        const ReviewerSettingsAlertContent(),
        const SizedBox(height: 20),
        _sectionHeader('Theme Settings'),
        const ThemeSelector(
          isShowCloseBtn: true,
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black, // Use a dynamic color if needed
        ),
      ),
    );
  }
}
