import 'package:flashi/features/settings/presentation/dialogs/theme_dialog.dart';
import 'package:flutter/material.dart';

class ThemeSettingsButton extends StatelessWidget {
  final ColorScheme colorScheme;
  const ThemeSettingsButton({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 68,
      right: 5,
      child: GestureDetector(
        onTap: () => {openThemeSelector(context)},
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(50)),
          child: Icon(
            Icons.color_lens,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
