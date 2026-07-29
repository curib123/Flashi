import 'dart:io';

import 'package:flashi/app/state/theme_provider.dart';
import 'package:flashi/core/state/sort_provider.dart';
import 'package:flashi/core/updates/application/app_update_provider.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/features/ai/application/ai_generation_provider.dart';
import 'package:flashi/features/ai/application/generation_config_provider.dart';
import 'package:flashi/features/chat/application/chat_provider.dart';
import 'package:flashi/features/dashboard/application/daily_question_provider.dart';
import 'package:flashi/features/history/application/history_provider.dart';
import 'package:flashi/features/notes/application/notes_provider.dart';
import 'package:flashi/features/onboarding/application/onboarding_provider.dart';
import 'package:flashi/features/reviewer/application/reviewer_settings_provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  late Directory hiveDirectory;
  final boxes = <String, Box<dynamic>>{};

  Future<Box<dynamic>> openBox(String name) async {
    final box = await Hive.openBox<dynamic>(name);
    boxes[name] = box;
    return box;
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
    hiveDirectory = await Directory.systemTemp.createTemp('flashi_features_');
    Hive.init(hiveDirectory.path);

    for (final name in [
      'theme_test',
      'sort_test',
      'generation_test',
      'notes_test',
      'history_test',
      'onboarding_test',
      'reviewer_test',
      'chatMessages',
      'DailyQuestionProvider',
    ]) {
      await openBox(name);
    }
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await Future.wait(boxes.values.map((box) => box.clear()));
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  group('Settings and shared application state', () {
    test('theme settings persist normalized values', () async {
      final box = boxes['theme_test']!;
      final provider = ThemeProvider(box: box);
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider
        ..setScheme(FlexScheme.greyLaw)
        ..setThemeMode(ThemeMode.dark)
        ..updateFontSize(4);

      expect(provider.currentScheme, FlexScheme.greyLaw);
      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.fontScale, 1);
      expect(box.get('themeMode'), ThemeMode.dark.index);
      expect(notifications, 2);
      provider.dispose();
    });

    test('sort preferences persist and reject duplicate changes', () {
      final box = boxes['sort_test']!;
      final provider = SortProvider(box: box);
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider
        ..updateSortValueSet('Alphabetical')
        ..updateSortValueSet('Alphabetical')
        ..updateSortValueCard('Oldest')
        ..updateSortValueNote('Tiles')
        ..updateSortValueTask('Blocks')
        ..updateSortValuePdf('Tiles');

      expect(provider.dropdownValueSet, 'Alphabetical');
      expect(provider.dropdownValueCard, 'Oldest');
      expect(provider.dropdownValueNote, 'Tiles');
      expect(provider.dropdownValueTask, 'Blocks');
      expect(provider.dropdownValuePdf, 'Tiles');
      expect(notifications, 5);
      provider.dispose();
    });

    test('reviewer settings validate and persist user choices', () {
      final box = boxes['reviewer_test']!;
      final provider = ReviewerSettingsProvider(box: box);

      provider
        ..updateFlashCardFlippingDirection(FlipDirection.HORIZONTAL)
        ..updateTimeDuration(25)
        ..updateTimeDuration(0);

      expect(provider.flashCardFlippingDirection, FlipDirection.HORIZONTAL);
      expect(provider.timeDuration, 25);
      expect(box.get('timeDuration'), 25);
      provider.dispose();
    });
  });

  group('Application updates', () {
    test('detects a newer semantic version and exposes release metadata',
        () async {
      final provider = AppUpdateProvider(
        client: MockClient(
          (_) async => http.Response(
            '{"latest_version":"1.7.0","download_link":"https://example.com",'
            '"patch_note":"Improvements"}',
            200,
          ),
        ),
        packageInfoLoader: () async => PackageInfo(
          appName: 'Flashi',
          packageName: 'com.example.flashi',
          version: '1.6.3',
          buildNumber: '12',
        ),
      );

      expect(await provider.checkAppVersion(), isTrue);
      expect(provider.updateAvailable, isTrue);
      expect(provider.currentVersion, '1.6.3');
      expect(provider.latestVersion, '1.7.0');
      expect(provider.patchNote, 'Improvements');
      expect(provider.isChecking, isFalse);
      provider.dispose();
    });

    test('handles release endpoint failures without throwing', () async {
      final provider = AppUpdateProvider(
        client: MockClient((_) async => http.Response('Unavailable', 503)),
        packageInfoLoader: () async => PackageInfo(
          appName: 'Flashi',
          packageName: 'com.example.flashi',
          version: '1.6.3',
          buildNumber: '12',
        ),
      );

      expect(await provider.checkAppVersion(), isFalse);
      expect(provider.lastError, isNotNull);
      expect(provider.latestVersion, '1.6.3');
      provider.dispose();
    });
  });

  group('AI feature', () {
    test('generation configuration loads, updates, and persists options',
        () async {
      final box = boxes['generation_test']!;
      final provider = GenerationConfigProvider(
        box: box,
        client: MockClient(
          (_) async => http.Response(
            '{"ai_models":[{"model_name":"fast"}],'
            '"listOfQuizQuestionTypes":[{"name":"Multiple Choice"}],'
            '"ListOfMaxLength":[5,10]}',
            200,
          ),
        ),
      );

      await provider.fetchLatestVersion();
      provider
        ..updateModel('fast')
        ..updateQuizQuestionType('Multiple Choice')
        ..updateListOfMaxLength(5)
        ..updateCreditsPerLength(2);

      expect(provider.listOfModels, ['fast']);
      expect(provider.listOfQuizQuestionTypes, ['Multiple Choice']);
      expect(provider.listOfMaxLength, [5, 10]);
      expect(provider.model, 'fast');
      expect(provider.maxLength, 5);
      expect(provider.creditsPerLength, 2);
      expect(box.get('model'), 'fast');
      expect(provider.lastError, isNull);
      provider.dispose();
    });

    test('AI credits initialize and mutate through injected platform services',
        () async {
      final now = DateTime.utc(2026, 7, 29);
      final provider = AiCreditProvider(
        deviceIdLoader: () async => 'test-device',
        networkTimeLoader: () async => now,
        internetChecker: () async => true,
      );
      await provider.ready;

      expect(provider.isInitialized, isTrue);
      expect(provider.credits, provider.defaultCredits);
      expect(provider.lastUpdated, now);
      expect(await provider.hasInternet(), isTrue);

      await provider.useCredit(3);
      await provider.addCredits(5);
      provider.updateAddedCredits(2);
      await provider.handleDataChange(now: now.add(const Duration(days: 1)));

      expect(provider.credits, 14);
      expect(provider.adsWatchedToday, 0);
      expect(provider.lastUpdated, now.add(const Duration(days: 1)));
      provider.dispose();
    });

    test('generation state normalizes topic updates and request failures',
        () async {
      final provider = AiGenerationProvider(
        httpClient: MockClient((_) async => http.Response('Unavailable', 500)),
      );
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider
        ..updateTopicAndDescription('Physics', 'Motion')
        ..updateTopicAndDescription('Physics', 'Motion');
      await provider.fetchLatestVersion();

      expect(provider.topic, 'Physics');
      expect(provider.description, 'Motion');
      expect(provider.errorMessage, contains('500'));
      expect(notifications, 2);
      provider.dispose();
    });
  });

  group('Content, favorites, and onboarding features', () {
    test('notes support add, search, favorite, edit, delete, and persistence',
        () {
      final box = boxes['notes_test']!;
      final provider = NotesProvider(box: box);
      final createdAt = DateTime.utc(2026, 7, 29);

      provider.addNote({
        'id': 1,
        'title': 'Physics',
        'content': 'Motion',
        'created_at': createdAt,
        'favorite': false,
      });
      provider.toggleFavoriteByTitle('Physics');
      provider.onSearchChanged('phys');

      expect(provider.filterNotes(), hasLength(1));
      expect(provider.filterFavorite().single['title'], 'Physics');

      provider.editNoteByTitle('Physics', {
        'id': 1,
        'title': 'Mechanics',
        'content': 'Forces',
        'created_at': createdAt,
        'favorite': true,
      });
      expect(provider.searchNotesByTitle('mechanics'), hasLength(1));

      provider.deleteNoteByTitle('Mechanics');
      expect(provider.notes, isEmpty);
      expect(box.get('notes'), isEmpty);
      provider.dispose();
    });

    test('history merges unique items and orders newest entries first', () {
      final box = boxes['history_test']!;
      final provider = HistoryProvider(box: box);
      final older = DateTime.utc(2026, 7, 28);
      final newer = DateTime.utc(2026, 7, 29);

      provider.updateHistory([
        {'id': 1, 'title': 'Older', 'created_at': older},
        {'id': 2, 'title': 'Newer', 'created_at': newer},
      ], merge: false);
      provider.updateHistory([
        {'id': 2, 'title': 'Newer', 'created_at': newer},
      ], merge: true);

      expect(provider.history, hasLength(2));
      expect(provider.filterHistory().first['title'], 'Newer');
      provider.dispose();
    });

    test('notes keep large collection reads indexed and cached', () {
      final provider = NotesProvider(box: boxes['notes_test']!);
      final createdAt = DateTime.utc(2026, 7, 29);
      final notes = List.generate(
        10000,
        (index) => <String, dynamic>{
          'id': index,
          'title': 'Note $index',
          'content': 'Content $index',
          'created_at': createdAt.subtract(Duration(minutes: index)),
          'favorite': index % 100 == 0,
        },
      );
      final stopwatch = Stopwatch()..start();

      provider.updateNotes(notes, merge: false);
      provider.onSearchChanged('Note 9999');
      final firstSearch = provider.filterNotes();
      final cachedSearch = provider.filterNotes();
      provider.toggleFavoriteByTitle('Note 9999');
      stopwatch.stop();

      expect(firstSearch.single['id'], 9999);
      expect(identical(firstSearch, cachedSearch), isTrue);
      expect(provider.filterFavorite(), hasLength(101));
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
      provider.dispose();
    });

    test('onboarding completion is persisted and idempotent', () async {
      final box = boxes['onboarding_test']!;
      final provider = OnboardingProvider(box: box);
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.completeOnboarding();
      await provider.completeOnboarding();

      expect(provider.isFirstTime, isFalse);
      expect(box.get('isFirstTime'), isFalse);
      expect(notifications, 1);
      provider.dispose();
    });
  });

  group('Chat and dashboard features', () {
    test('chat loads defaults, copies external messages, and persists them',
        () {
      final box = boxes['chatMessages']!;
      final provider = ChatProvider();
      final source = [
        {'text': 'Stored message', 'sender': 'user'}
      ];

      expect(provider.messages.single['sender'], 'bot');
      provider.updateMessages(source);
      source.first['text'] = 'Changed outside';

      expect(provider.messages.single['text'], 'Stored message');
      expect((box.get('messages') as List).single['text'], 'Stored message');
      provider.dispose();
    });

    test('daily questions load immutable data and validate removals', () async {
      final box = boxes['DailyQuestionProvider']!;
      await box.put('DailyQuestionProvider', [
        {
          'question': 'Q',
          'correct_answer': 'A',
          'fake_choice_1': 'B',
          'fake_choice_2': 'C',
          'fake_choice_3': 'D',
        }
      ]);
      final provider = DailyQuestionProvider();

      expect(provider.funFacts, hasLength(1));
      provider.removeFunFactAt(-1);
      expect(provider.funFacts, hasLength(1));
      provider.removeFunFactAt(0);
      expect(provider.funFacts, isEmpty);
      expect(box.get('DailyQuestionProvider'), isEmpty);
      provider.dispose();
    });
  });
}
