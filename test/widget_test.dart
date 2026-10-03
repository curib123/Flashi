import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/widget/components/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Flashi theme uses Material 3 and the brand seed', () {
    final theme = FlashiDesign.light();
    expect(theme.useMaterial3, isTrue);
    expect(theme.fontFamily, 'Montserrat');
  });

  testWidgets('Primary navigation exposes all study destinations',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FlashiDesign.light(),
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            currentIndex: 1,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Assistant'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
  });
}
