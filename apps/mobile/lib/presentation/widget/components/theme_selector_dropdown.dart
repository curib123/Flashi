import 'package:flashi/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSelector extends StatelessWidget {
  final bool isShowCloseBtn;

  const ThemeSelector({
    super.key,
    required this.isShowCloseBtn,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _modeChip(context, provider, ThemeMode.system, 'System',
                Icons.brightness_auto_outlined),
            _modeChip(context, provider, ThemeMode.light, 'Light',
                Icons.light_mode_outlined),
            _modeChip(context, provider, ThemeMode.dark, 'Dark',
                Icons.dark_mode_outlined),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Text size',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Text(
              provider.fontScale.toStringAsFixed(2) + 'x',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Slider(
          value: provider.fontScale,
          min: 0.85,
          max: 1.25,
          divisions: 8,
          onChanged: provider.updateFontSize,
        ),
        Text(
          'Flashi uses its bundled Montserrat typeface so the UI stays consistent even when you are offline.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }

  Widget _modeChip(
    BuildContext context,
    ThemeProvider provider,
    ThemeMode mode,
    String label,
    IconData icon,
  ) {
    return ChoiceChip(
      selected: provider.themeMode == mode,
      onSelected: (_) => provider.setThemeMode(mode),
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
