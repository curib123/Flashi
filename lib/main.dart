
import 'package:flashlearn/home.dart';
import 'package:flashlearn/provider/bottom_navigation_provider.dart';
import 'package:flashlearn/provider/notes_provider.dart';
import 'package:flashlearn/provider/onboarding_provider.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/provider/reviewer_settings_provider.dart';
import 'package:flashlearn/provider/sort_provider.dart';
import 'package:flashlearn/provider/theme_provider.dart';
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



  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavigationProvider()), // Add BottomNavigationProvider
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Add ThemeProvider
        ChangeNotifierProvider(create: (_) => SortProvider()), // Add SortProvider
        ChangeNotifierProvider(create: (_) => ReviewerSettingsProvider()), // Add SortProvider
        ChangeNotifierProvider(create: (_) => NotesProvider()), // Add SortProvider
        ChangeNotifierProvider(create: (_) => OnboardingProvider()), // Add SortProvider
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


class RocketLearn extends StatelessWidget {
  const RocketLearn({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FlashLearn",
      home: const Home(),
      theme: themeProvider.getLightTheme(),
      darkTheme: themeProvider.getDarkTheme(),
      themeMode: themeProvider.themeMode,
    );
  }
}

