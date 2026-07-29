import 'package:flashi/app/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('route names are stable and hierarchical', () {
    expect(AppRoutes.home, '/');
    expect(AppRoutes.noteEditor, '/notes/editor');
    expect(AppRoutes.quizCards, '/quiz-sets/cards');
    expect(AppRoutes.historyEditor, '/history/editor');
  });

  test('typed routes reject missing or incorrect arguments', () {
    expect(
      () => AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.noteEditor),
      ),
      throwsA(isA<FlutterError>()),
    );
    expect(
      () => AppRouter.onGenerateRoute(
        const RouteSettings(
          name: AppRoutes.reviewer,
          arguments: 'wrong arguments',
        ),
      ),
      throwsA(isA<FlutterError>()),
    );
  });

  testWidgets('unknown routes render a safe not-found page', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('Home')),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    Navigator.of(tester.element(find.text('Home'))).pushNamed('/missing');
    await tester.pumpAndSettle();

    expect(find.text('Page not found: /missing'), findsOneWidget);
  });
}
