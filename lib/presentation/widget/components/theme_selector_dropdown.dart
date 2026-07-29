import 'package:flashi/app/state/theme_provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSelector extends StatelessWidget {
  final bool isShowCloseBtn;

  const ThemeSelector({super.key, required this.isShowCloseBtn});

  @override
  Widget build(BuildContext context) {
    // Access the theme provider to manage theme-related settings
    final themeProvider = Provider.of<ThemeProvider>(context);

    // List of available theme schemes and theme modes
    const schemes = FlexScheme.values;
    const themeModes = ThemeMode.values;

    final aestheticFonts = [
      {'name': 'Inter', 'description': 'Neutral, modern, and highly readable.'},
      {'name': 'Roboto', 'description': 'Versatile, clean, and readable.'},
      {'name': 'Poppins', 'description': 'Modern with rounded edges.'},
      {'name': 'Lato', 'description': 'Friendly and warm.'},
      {'name': 'Montserrat', 'description': 'Bold and impactful.'},
      {'name': 'Nunito', 'description': 'Balanced and rounded.'},
      {'name': 'Raleway', 'description': 'Elegant and clean.'},
      {'name': 'Merriweather', 'description': 'Classic and readable.'},
      {'name': 'Fira Sans', 'description': 'Clear and versatile.'},
      {
        'name': 'Playfair Display',
        'description': 'Elegant serif with a modern twist.'
      },
      {'name': 'Bebas Neue', 'description': 'Strong and timeless.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section for selecting a theme
        const Text("Select Theme",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButton<FlexScheme>(
          value: themeProvider.currentScheme,
          isExpanded: true,
          items: schemes.map((scheme) {
            return DropdownMenuItem(
              value: scheme,
              child: Row(
                children: [
                  // Color preview for the theme
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: FlexColor.schemes[scheme]?.light.primary ??
                          Colors.grey,
                    ),
                  ),
                  Text(FlexColor.schemes[scheme]?.name ?? scheme.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (newScheme) {
            if (newScheme != null) {
              themeProvider.setScheme(newScheme);
            }
          },
        ),

        const SizedBox(height: 16),

        // Section for selecting a theme mode
        const Text("Select Theme Mode",
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

        // Section for selecting a font
        const Text("Select Font",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const Text("Need Internet",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: themeProvider.currentFont,
          isExpanded: true,
          items: aestheticFonts.map((font) {
            return DropdownMenuItem(
              value: font['name'],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(font['name']!,
                      style: TextStyle(fontFamily: font['name'])),
                  Text(font['description']!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          }).toList(),
          onChanged: (newFont) {
            if (newFont != null) {
              themeProvider.setFont(newFont);
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
