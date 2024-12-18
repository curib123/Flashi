import 'package:flashlearn/provider/theme_provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSelector extends StatelessWidget {

  final bool isShowCloseBtn;

  const ThemeSelector({super.key,required, required this.isShowCloseBtn });

  @override
  Widget build(BuildContext context) {
    // Access the theme provider to manage theme-related settings
    final themeProvider = Provider.of<ThemeProvider>(context);

    // List of available theme schemes and theme modes
    const schemes = FlexScheme.values;
    const themeModes = ThemeMode.values;

    // List of fonts with descriptions for user selection
    final aestheticFonts = [
      {'name': 'Roboto', 'description': 'Versatile, clean, and readable.'},
      {'name': 'Poppins', 'description': 'Modern with rounded edges.'},
      {'name': 'Lato', 'description': 'Friendly and warm.'},
      {'name': 'Montserrat', 'description': 'Bold and impactful.'},
      {'name': 'Oswald', 'description': 'Strong and eye-catching.'},
      {'name': 'Raleway', 'description': 'Elegant and clean.'},
      {'name': 'Nunito', 'description': 'Balanced and rounded.'},
      {'name': 'Merriweather', 'description': 'Classic and readable.'},
      {'name': 'Source Sans Pro', 'description': 'Modern and simple.'},
      {'name': 'Fira Sans', 'description': 'Clear and versatile.'},
      {'name': 'Playfair Display', 'description': 'Elegant serif with a modern twist.'},
      {'name': 'Anton', 'description': 'Bold and striking.'},
      {'name': 'Bangers', 'description': 'Fun and comic-inspired.'},
      {'name': 'VT323', 'description': 'Classic computer-style font.'},
      {'name': 'Russo One', 'description': 'Modern and athletic.'},
      {'name': 'Orbitron', 'description': 'Futuristic and tech-inspired.'},
      {'name': 'Zilla Slab', 'description': 'Contemporary slab serif.'},
      {'name': 'Amatic SC', 'description': 'Hand-drawn and creative.'},
      {'name': 'Dancing Script', 'description': 'Lively and cursive.'},
      {'name': 'Crimson Pro', 'description': 'Classic and sophisticated.'},
      {'name': 'Josefin Sans', 'description': 'Minimal and geometric.'},
      {'name': 'Inconsolata', 'description': 'A monospace font for designers.'},
      {'name': 'Bebas Neue', 'description': 'Strong and timeless.'},
      {'name': 'Muli', 'description': 'Clean and contemporary.'},
      {'name': 'Cabin', 'description': 'Rounded and modern.'},
      {'name': 'Abril Fatface', 'description': 'Elegant and impactful.'},
      {'name': 'Pacifico', 'description': 'Fun and handwritten.'},
      {'name': 'Arvo', 'description': 'Geometric slab serif.'},
      {'name': 'Exo 2', 'description': 'Futuristic and sleek.'},
      {'name': 'Libre Baskerville', 'description': 'Elegant serif for web.'},
      {'name': 'Cormorant Garamond', 'description': 'Sophisticated and classic serif.'},
      {'name': 'Titillium Web', 'description': 'Modern and narrow sans-serif.'},
      {'name': 'Quicksand', 'description': 'Rounded and friendly.'},
      {'name': 'Overpass', 'description': 'Inspired by highway signage.'},
      {'name': 'PT Serif', 'description': 'Readable and professional.'},
      {'name': 'Alfa Slab One', 'description': 'Bold slab serif with character.'},
      {'name': 'Noticia Text', 'description': 'Ideal for text-heavy layouts.'},
      {'name': 'Barlow', 'description': 'Low-contrast and geometric.'},
      {'name': 'Baloo', 'description': 'Playful and rounded.'},
      {'name': 'Manrope', 'description': 'Minimalist and futuristic.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section for selecting a theme
        const Text("Select Theme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButton<FlexScheme>(
          value: themeProvider.currentScheme ?? schemes.first,
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
                      color: FlexColor.schemes[scheme]?.light.primary ?? Colors.grey,
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
        const Text("Select Theme Mode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
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
              themeProvider.toggleThemeMode();
            }
          },
        ),

        const SizedBox(height: 16),

        // Section for selecting a font
        const Text("Select Font", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButton<String>(
          value: themeProvider.currentFont ?? aestheticFonts.first['name'],
          isExpanded: true,
          items: aestheticFonts.map((font) {
            return DropdownMenuItem(
              value: font['name'],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(font['name']!, style: TextStyle(fontFamily: font['name'])),
                  Text(font['description']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

        const SizedBox(height: 16),

        // Close button for the modal
        Align(
          alignment: Alignment.bottomRight,
          child: isShowCloseBtn ?  ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 5,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.pop(context); // Close the modal bottom sheet
            },
            child: const Text("Close"),
          ) : null
        ),
      ],
    );
  }
}
