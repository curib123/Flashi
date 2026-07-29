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

    test('supports the complete quiz set and card mutation workflow', () {
      final provider = QuizProvider(
        criterionSet: 'Newest',
        criterionCard: 'Newest',
        settingsBox: quizBox,
      );
      final quizSet = <String, dynamic>{
        'name': 'Science',
        'description': 'Initial',
        'favorite': false,
        'cards': <Map<String, dynamic>>[],
        'numberOfQuiz': 0,
        'limitNumberOfQuiz': 1,
        'timestamp': DateTime.utc(2026, 7, 29),
      };

      provider.addQuizSet(quizSet);
      expect(provider.searchQuizSet(quizSetName: 'Science'), isNotNull);

      expect(
        provider.addCardToQuizSetNew(
          quizSetName: 'Science',
          card: {
            'question': 'What is matter?',
            'answer': 'Anything with mass',
            'keyword': 'matter',
            'isIgnore': false,
          },
        ),
        isTrue,
      );
      expect(
        provider.addCardToQuizSetNew(
          quizSetName: 'Science',
          card: {'question': 'Blocked by limit', 'answer': 'Blocked'},
        ),
        isFalse,
      );

      expect(
        provider.updateCardInQuizSet(
          quizSetName: 'Science',
          oldQuestion: 'What is matter?',
          newQuestion: 'Define matter',
          newAnswer: 'Anything that has mass',
        ),
        isTrue,
      );
      expect(
        provider.updateKeyWordInQuizSet(
          quizSetName: 'Science',
          oldKeyWord: 'matter',
          newKeyWord: 'mass',
        ),
        isTrue,
      );
      expect(
        provider.toggleIgnore(
          quizSetName: 'Science',
          question: 'Define matter',
          isIgnore: false,
        ),
        isTrue,
      );

      final storedSet = provider.searchQuizSet(quizSetName: 'Science')!;
      provider.toggleFavorite(storedSet);
      provider.updateSearchQuery('sci');

      expect(provider.filteredQuizSets, hasLength(1));
      expect(provider.filteredQuizSetsFavorite, hasLength(1));
      expect(provider.getNumberOfCardsInSet('Science'), 1);
      expect(provider.showAllCardsInSet('Science')!.single['keyword'], 'mass');

      expect(
        provider.removeCardFromQuizSet(
          quizSetName: 'Science',
          question: 'Define matter',
        ),
        isTrue,
      );
      expect(
        provider.editQuizSet(
          'Science',
          newName: 'Physical Science',
          newDescription: 'Updated',
        ),
        isTrue,
      );
      provider.removeQuizSet(
        provider.searchQuizSet(quizSetName: 'Physical Science')!,
      );

      expect(provider.quizSets, isEmpty);
      provider.dispose();
    });

    test('indexes thousands of quiz sets for bounded lookup performance',
        () async {
      final provider = QuizProvider(
        criterionSet: 'Newest',
        criterionCard: 'Newest',
        settingsBox: quizBox,
      );
      final quizSets = List.generate(
        5000,
        (index) => <String, dynamic>{
          'id': index,
          'name': 'Set $index',
          'cards': <Map<String, dynamic>>[],
          'numberOfQuiz': 0,
          'timestamp': DateTime.utc(2026, 7, 29),
        },
      );
      final stopwatch = Stopwatch()..start();

      await provider.updateQuizSets(Future.value(quizSets), merge: false);
      for (var index = 0; index < 10000; index++) {
        expect(
          provider.searchQuizSet(quizSetName: 'Set ${index % 5000}'),
          isNotNull,
        );
      }
      stopwatch.stop();

      expect(provider.quizSets, hasLength(5000));
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
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
