import 'dart:async';

import 'package:flashi/app/navigation/app_router.dart';
import 'package:flashi/app/state/app_navigation_provider.dart';
import 'package:flashi/app/state/theme_provider.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/core/ads/ad_unit_id.dart';
import 'package:flashi/core/state/sort_provider.dart';
import 'package:flashi/features/dashboard/application/daily_question_provider.dart';
import 'package:flashi/features/onboarding/application/onboarding_provider.dart';
import 'package:flashi/features/reviewer/application/reviewer_settings_provider.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/features/ai/application/ai_generation_provider.dart';
import 'package:flashi/features/chat/application/chat_provider.dart';
import 'package:flashi/features/ai/application/generation_config_provider.dart';
import 'package:flashi/core/updates/application/app_update_provider.dart';
import 'package:flashi/features/history/application/history_provider.dart';
import 'package:flashi/features/notes/application/notes_provider.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final adsInitialization = MobileAds.instance.initialize();

  await Future.wait<Object?>([
    for (final boxName in const [
      'theme',
      'sort',
      'reviewer_settings',
      'quiz',
      'notes',
      'onboarding',
      'timerBox',
      'chatMessages',
      'fetchDataFromJson',
      'DailyQuestionProvider',
      'history',
    ])
      Hive.openBox<dynamic>(boxName),
  ]);

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
        ChangeNotifierProvider(create: (_) => AiGenerationProvider()),
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

  unawaited(
    adsInitialization.then(
      (_) => AdManager().loadBannerAds(AdUnitId.bannerAdUnitId),
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
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
    );
  }
}
