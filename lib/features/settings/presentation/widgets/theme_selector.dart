import 'package:flashi/app/state/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSelector extends StatelessWidget {
  final bool isShowCloseBtn;

  const ThemeSelector({super.key, required this.isShowCloseBtn});

  @override
  Widget build(BuildContext context) {
    // Access the theme provider to manage theme-related settings
    final themeProvider = Provider.of<ThemeProvider>(context);

    const themeModes = ThemeMode.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Appearance",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        DropdownButton<ThemeMode>(
          value: themeProvider.themeMode,
          isExpanded: true,
          items: themeModes.map((mode) {
            return DropdownMenuItem(
              value: mode,
              child: Row(
                children: [
                  // Icon representation of the theme mode
                  Icon(
                    mode == ThemeMode.light
                        ? Icons.light_mode
                        : mode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    mode == ThemeMode.light
                        ? "Light Mode"
                        : mode == ThemeMode.dark
                            ? "Dark Mode"
                            : "System Default",
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newMode) {
            if (newMode != null) {
              themeProvider.setThemeMode(newMode);
            }
          },
        ),
        const SizedBox(height: 10),
        const Text("Adjust Font Size",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        Slider(
          value: themeProvider.fontScale,
          min: 0.5, // Min font scale (50%)
          max: 1.0, // Max font scale (200%)
          divisions: 15,
          label: themeProvider.fontScale.toStringAsFixed(1),
          onChanged: (value) {
            themeProvider.updateFontSize(value);
          },
        ),
      ],
    );
  }
}
