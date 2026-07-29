import 'dart:io';

import 'package:flashi/app/state/app_navigation_provider.dart';
import 'package:flashi/features/ai/application/ai_generation_provider.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AppNavigationProvider', () {
    test('notifies only when the selected destination changes', () {
      final provider = AppNavigationProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.selectDestination(1);
      provider.selectDestination(2);
      provider.selectDestination(2);

      expect(provider.currentIndex, 2);
      expect(notifications, 1);
    });
  });

  group('QuizProvider', () {
    late Directory hiveDirectory;
    late Box<dynamic> quizBox;

    setUpAll(() async {
      hiveDirectory = await Directory.systemTemp.createTemp('flashi_provider_');
      Hive.init(hiveDirectory.path);
      quizBox = await Hive.openBox<dynamic>('quiz_provider_test');
    });

    setUp(() async {
      await quizBox.clear();
    });

    tearDownAll(() async {
      await quizBox.close();
      await hiveDirectory.delete(recursive: true);
    });

    test('persists mutations and guards missing card updates', () async {
      final provider = QuizProvider(
        criterionSet: 'Alphabetical',
        criterionCard: 'Newest',
        settingsBox: quizBox,
      );

      provider.addQuizSet({
        'name': 'Biology',
        'cards': <Map<String, dynamic>>[],
        'numberOfQuiz': 0,
      });

      expect(
        provider.toggleIgnore(
          quizSetName: 'Biology',
          question: 'Missing',
          isIgnore: false,
        ),
        isFalse,
      );
      expect((quizBox.get('quizSets') as List).single['name'], 'Biology');

      provider.dispose();
    });

    test('ignores stale async replacements', () async {
      final provider = QuizProvider(
        criterionSet: 'Alphabetical',
        criterionCard: 'Newest',
        settingsBox: quizBox,
      );

      final older = Future<List<Map<String, dynamic>>>.delayed(
        const Duration(milliseconds: 20),
        () => [
          {'id': 1, 'name': 'Old'},
        ],
      );
      final newer = Future.value([
        {'id': 2, 'name': 'New'},
      ]);

      final olderUpdate = provider.updateQuizSets(older, merge: false);
      final newerUpdate = provider.updateQuizSets(newer, merge: false);
      await Future.wait([olderUpdate, newerUpdate]);

      expect(provider.quizSets.single['name'], 'New');
      provider.dispose();
    });
  });

  group('AiGenerationProvider', () {
    test('publishes maintenance configuration from an injected client',
        () async {
      final provider = AiGenerationProvider(
        httpClient: MockClient(
          (_) async => http.Response(
            '{"under_maintenance":true,"reason_maintenance_ai":"Upgrade"}',
            200,
          ),
        ),
      );

      await provider.fetchLatestVersion();

      expect(provider.isFetchData, isTrue);
      expect(provider.isUnderMaintenance, isTrue);
      expect(provider.reasonMaintenance, 'Upgrade');
      expect(provider.errorMessage, isNull);
      provider.dispose();
    });

    test('exposes configuration request failures without throwing', () async {
      final provider = AiGenerationProvider(
        httpClient: MockClient((_) async => http.Response('Unavailable', 503)),
      );

      await provider.fetchLatestVersion();

      expect(provider.isFetchData, isFalse);
      expect(provider.errorMessage, contains('503'));
      provider.dispose();
    });
  });
}
