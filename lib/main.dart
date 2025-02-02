
import 'package:flashlearn/home.dart';
import 'package:flashlearn/provider/bottom_navigation_provider.dart';
import 'package:flashlearn/provider/notes_provider.dart';
import 'package:flashlearn/provider/onboarding_provider.dart';
import 'package:flashlearn/provider/pdf_provider.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/provider/reviewer_settings_provider.dart';
import 'package:flashlearn/provider/save_info_ads_provider.dart';
import 'package:flashlearn/provider/sort_provider.dart';
import 'package:flashlearn/provider/study_scheduler_provider.dart';
import 'package:flashlearn/provider/task_provider.dart';
import 'package:flashlearn/provider/text_reader_provider.dart';
import 'package:flashlearn/provider/theme_provider.dart';
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
  await Hive.openBox('timerBox'); // Box for storing timerBox
  await Hive.openBox('scheduler'); // Box for storing scheduler
  await Hive.openBox('task'); // Box for storing task
  await Hive.openBox('textReader'); // Box for storing task

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
        ChangeNotifierProvider(create: (_) => TaskProvider()), // Add StudySchedulerProvider
        ChangeNotifierProvider(create: (_) => TextReaderProvider()), // Add TextReaderProvider
        ChangeNotifierProvider(create: (_) => PdfProvider()), // Add TextReaderProvider
        ChangeNotifierProvider(
            create: (context) => QuizProvider(
                criterionSet: Provider.of<SortProvider>(context,listen: false).dropdownValueSet,
                criterionCard: Provider.of<SortProvider>(context,listen: false).dropdownValueCard)

        ), // Add QuizProvider
      ],
      child: const RocketLearn(),
    ),
  );
}


class RocketLearn extends StatefulWidget {
  const RocketLearn({super.key});

  @override
  State<RocketLearn> createState() => _RocketLearnState();
}

class _RocketLearnState extends State<RocketLearn> {



  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FlashLearn",
      home: const Home(),
      theme:  themeProvider.getLightTheme(),
      darkTheme: themeProvider.getDarkTheme(),
      themeMode: themeProvider.themeMode,
    );
  }
}

