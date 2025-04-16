import 'package:flashi/home.dart';
import 'package:flashi/provider/DailyQuestionProvider.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/ai_model_logic_provider.dart';
import 'package:flashi/provider/chatbot_provider.dart';
import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/provider/check_version_provider.dart';
import 'package:flashi/provider/history_provider.dart';
import 'package:flashi/provider/notes_provider.dart';
import 'package:flashi/provider/onboarding_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/reviewer_settings_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flashi/provider/theme_provider.dart';
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

  await saveAPIKey('TZjSrnSAjyflYyNyFmPnMfHHSZ4Mw33q');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavigationProvider()), // Add BottomNavigationProvider
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Add ThemeProvider
        ChangeNotifierProvider(create: (_) => SortProvider()), // Add SortProvider
        ChangeNotifierProvider(create: (_) => ReviewerSettingsProvider()), // Add SortProvider
        ChangeNotifierProvider(create: (_) => NotesProvider()), // Add SortProvider
        ChangeNotifierProvider(create: (_) => OnboardingProvider()), // Add OnboardingProvider
        ChangeNotifierProvider(create: (_) => FetchDataFromJsonProvider()), // Add TextReaderProvider
        ChangeNotifierProvider(create: (_) => AiModelLogicProvider()), // Add AiModelLogicProvider
        ChangeNotifierProvider(create: (_) => CheckVersionProvider()), // Add CheckVersionProvider
        ChangeNotifierProvider(create: (_) => ChatBotProvider()), // Add CheckVersionProvider
        ChangeNotifierProvider(create: (_) => AiCreditProvider()), // Add CheckVersionProvider
        ChangeNotifierProvider(create: (_) => DailyQuestionProvider()), // Add CheckVersionProvider
        ChangeNotifierProvider(create: (_) => HistoryProvider()), // Add CheckVersionProvider
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

