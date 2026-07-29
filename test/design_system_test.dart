import 'package:flashi/core/design_system/app_surface.dart';
import 'package:flashi/core/design_system/app_theme.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('design system renders in light and dark modes', (tester) async {
    for (final theme in [
      AppTheme.light(FlexScheme.tealM3, 'Montserrat'),
      AppTheme.dark(FlexScheme.tealM3, 'Montserrat'),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: AppSurface(child: Text('Flashi')),
          ),
        ),
      );

      expect(find.text('Flashi'), findsOneWidget);
    }
  });
}
