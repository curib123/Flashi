import 'package:flashi/app/app_shell.dart';
import 'package:flashi/app/state/app_navigation_provider.dart';
import 'package:flashi/app/state/theme_provider.dart';
import 'package:flashi/core/state/sort_provider.dart';
import 'package:flashi/features/dashboard/application/daily_question_provider.dart';
import 'package:flashi/features/onboarding/application/onboarding_provider.dart';
import 'package:flashi/features/reviewer/application/reviewer_settings_provider.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/provider/ai_model_logic_provider.dart';
import 'package:flashi/features/chat/application/chat_provider.dart';
import 'package:flashi/features/ai/application/generation_config_provider.dart';
import 'package:flashi/core/updates/application/app_update_provider.dart';
import 'package:flashi/features/history/application/history_provider.dart';
import 'package:flashi/features/notes/application/notes_provider.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/api/ai/core/api_key_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  await Hive.initFlutter(); // Initialize Hive
// Open different boxes for various settings or data
  await Hive.openBox('theme'); // Box for theme settings
  await Hive.openBox('sort'); // Box for sorting preferences
  await Hive.openBox('reviewer_settings'); // Box for reviewer-related settings
  await Hive.openBox('quiz'); // Box for quiz data
  await Hive.openBox('notes'); // Box for storing notes
  await Hive.openBox('onboarding'); // Box for storing onboarding
  await Hive.openBox('timerBox');
  await Hive.openBox('chatMessages');
  await Hive.openBox('fetchDataFromJson');
  await Hive.openBox('DailyQuestionProvider');
  await Hive.openBox('history');

  await saveAPIKey('');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppNavigationProvider()),
        ChangeNotifierProvider(
            create: (_) => ThemeProvider()), // Add ThemeProvider
        ChangeNotifierProvider(
            create: (_) => SortProvider()), // Add SortProvider
        ChangeNotifierProvider(
            create: (_) => ReviewerSettingsProvider()), // Add SortProvider
        ChangeNotifierProvider(
            create: (_) => NotesProvider()), // Add SortProvider
        ChangeNotifierProvider(
            create: (_) => OnboardingProvider()), // Add OnboardingProvider
        ChangeNotifierProvider(create: (_) => GenerationConfigProvider()),
        ChangeNotifierProvider(
            create: (_) => AiModelLogicProvider()), // Add AiModelLogicProvider
        ChangeNotifierProvider(create: (_) => AppUpdateProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(
            create: (_) => AiCreditProvider()), // Add CheckVersionProvider
        ChangeNotifierProvider(
            create: (_) => DailyQuestionProvider()), // Add CheckVersionProvider
        ChangeNotifierProvider(
            create: (_) => HistoryProvider()), // Add CheckVersionProvider
        ChangeNotifierProvider(
            create: (context) => QuizProvider(
                criterionSet: Provider.of<SortProvider>(context, listen: false)
                    .dropdownValueSet,
                criterionCard: Provider.of<SortProvider>(context, listen: false)
                    .dropdownValueCard)), // Add QuizProvider
      ],
      child: const Flashi(),
    ),
  );
}

class Flashi extends StatelessWidget {
  const Flashi({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flashi Ai",
      home: const AppShell(),
      theme: themeProvider.getLightTheme(),
      darkTheme: themeProvider.getDarkTheme(),
      themeMode: themeProvider.themeMode,
    );
  }
}
