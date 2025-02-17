
import 'package:flashi/home.dart';
import 'package:flashi/provider/ai_model_logic_provider.dart';
import 'package:flashi/provider/ai_model_provider.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/provider/check_version_provider.dart';
import 'package:flashi/provider/notes_provider.dart';
import 'package:flashi/provider/onboarding_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/reviewer_settings_provider.dart';
import 'package:flashi/provider/save_info_ads_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flashi/provider/study_scheduler_provider.dart';
import 'package:flashi/provider/task_provider.dart';
import 'package:flashi/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter(); // Initialize Hive
// Open different boxes for various settings or data
  await Hive.openBox('theme'); // Box for theme settings
  await Hive.openBox('sort'); // Box for sorting preferences
  await Hive.openBox('reviewer_settings'); // Box for reviewer-related settings
  await Hive.openBox('quiz'); // Box for quiz data
  await Hive.openBox('notes'); // Box for storing notes
  await Hive.openBox('onboarding'); // Box for storing onboarding
  await Hive.openBox('timerBox'); // Box for storing timerBox
  await Hive.openBox('scheduler'); // Box for storing scheduler
  await Hive.openBox('task'); // Box for storing task
  await Hive.openBox('textReader'); // Box for storing task
  await Hive.openBox('pdf'); // Box for storing task

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavigationProvider()), // Add BottomNavigationProvider
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Add ThemeProvider
        ChangeNotifierProvider(create: (_) => SortProvider()), // Add SortProvider
        ChangeNotifierProvider(create: (_) => ReviewerSettingsProvider()), // Add SortProvider
        ChangeNotifierProvider(create: (_) => NotesProvider()), // Add SortProvider
        ChangeNotifierProvider(create: (_) => OnboardingProvider()), // Add OnboardingProvider
        ChangeNotifierProvider(create: (_) => SaveInfoAdsProvider()), // Add SaveInfoAdsProvider
        ChangeNotifierProvider(create: (_) => StudySchedulerProvider()), // Add StudySchedulerProvider
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AiModelProvider()), // Add TextReaderProvider
        ChangeNotifierProvider(create: (_) => AiModelLogicProvider()), // Add TextReaderProvider
        ChangeNotifierProvider(create: (_) => CheckVersionProvider()), // Add TextReaderProvider

        ChangeNotifierProvider(
            create: (context) => QuizProvider(
                criterionSet: Provider.of<SortProvider>(context,listen: false).dropdownValueSet,
                criterionCard: Provider.of<SortProvider>(context,listen: false).dropdownValueCard)

        ), // Add QuizProvider
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
      home: const Home(),
      theme:  themeProvider.getLightTheme(),
      darkTheme: themeProvider.getDarkTheme(),
      themeMode: themeProvider.themeMode,
    );
  }
}

