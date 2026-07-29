import 'package:flashi/core/design_system/app_surface.dart';
import 'package:flashi/core/design_system/app_theme.dart';
import 'package:flashi/shared/widgets/app_page_header.dart';
import 'package:flashi/shared/widgets/empty_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('design system renders in light and dark modes', (tester) async {
    for (final theme in [
      AppTheme.light(),
      AppTheme.dark(),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Column(
              children: [
                AppPageHeader(
                  title: 'Flashi',
                  description: 'Learn with clarity',
                ),
                Expanded(
                  child: AppSurface(
                    emphasized: true,
                    child: AppEmptyState(
                      icon: Icons.layers_outlined,
                      title: 'No quiz sets yet',
                      description: 'Create a quiz set to start learning.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Flashi'), findsOneWidget);
      expect(find.text('No quiz sets yet'), findsOneWidget);
    }
  });
}
