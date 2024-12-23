import 'package:flashlearn/home.dart';
import 'package:flashlearn/provider/alarm_provider.dart';
import 'package:flashlearn/provider/bottom_navigation_provider.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/provider/reviewer_settings_provider.dart';
import 'package:flashlearn/provider/sort_provider.dart';
import 'package:flashlearn/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Ensure that widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open individual boxes
  await Hive.openBox('settings'); // Open a box named 'settings'
  await Hive.openBox('alarmsBox'); // Open a box named 'alarmsBox'

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SortProvider()),
        ChangeNotifierProvider(create: (_) => ReviewerSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProvider(
          create: (context) => QuizProvider(
            criterionSet: Provider.of<SortProvider>(context, listen: false).dropdownValueSet,
            criterionCard: Provider.of<SortProvider>(context, listen: false).dropdownValueCard,
          ),
        ),
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
