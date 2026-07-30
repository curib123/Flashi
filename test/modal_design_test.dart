import 'package:flashi/core/design_system/app_theme.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shared dialog presents structured content and actions',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showAppDialog<void>(
                context: context,
                builder: (context) => AppDialog(
                  icon: Icons.tune,
                  title: 'Modal title',
                  description: 'Helpful description',
                  actions: [
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ],
                  body: const Text('Modal content'),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Modal title'), findsOneWidget);
    expect(find.text('Helpful description'), findsOneWidget);
    expect(find.text('Modal content'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Modal title'), findsNothing);
  });

  testWidgets('shared bottom sheet includes a drag handle and safe content',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showAppBottomSheet<void>(
                context: context,
                builder: (_) => const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppSheetHeader(
                      title: 'Sheet title',
                      description: 'Sheet description',
                    ),
                    Text('Sheet content'),
                  ],
                ),
              ),
              child: const Text('Open sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Sheet title'), findsOneWidget);
    expect(find.text('Sheet description'), findsOneWidget);
    expect(find.text('Sheet content'), findsOneWidget);
  });
}
