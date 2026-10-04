import 'package:flashi/core/config/app_env.dart';
import 'package:flashi/data/services/api_client.dart';
import 'package:flashi/data/services/startio_service.dart';
import 'package:flashi/home.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/app_config_provider.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/provider/generation_provider.dart';
import 'package:flashi/provider/check_version_provider.dart';
import 'package:flashi/provider/history_provider.dart';
import 'package:flashi/provider/onboarding_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/reviewer_settings_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flashi/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('theme');
  await Hive.openBox('sort');
  await Hive.openBox('reviewer_settings');
  await Hive.openBox('quiz');
  await Hive.openBox('onboarding');
  await Hive.openBox('timerBox');
  await Hive.openBox('history');

  SupabaseClient? supabaseClient;
  if (AppEnv.supabaseConfigured) {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      publishableKey: AppEnv.supabasePublishableKey,
    );
    supabaseClient = Supabase.instance.client;
  }

  final apiClient = ApiClient(
    accessTokenProvider: () =>
        supabaseClient?.auth.currentSession?.accessToken ?? '',
  );
  final startIo = StartIoService();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<StartIoService>.value(value: startIo),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)..restore()),
        ChangeNotifierProvider(
          create: (_) => AppConfigProvider(apiClient, startIo)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => AiCreditProvider(apiClient, startIo),
        ),
        ChangeNotifierProvider(
          create: (_) => GenerationProvider(apiClient),
        ),
        ChangeNotifierProvider(create: (_) => BottomNavigationProvider()),
        ChangeNotifierProvider(create: (_) => CheckVersionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SortProvider()),
        ChangeNotifierProvider(create: (_) => ReviewerSettingsProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(
          create: (context) => QuizProvider(
            criterionSet: context.read<SortProvider>().dropdownValueSet,
            criterionCard: context.read<SortProvider>().dropdownValueCard,
          ),
        ),
      ],
      child: const Flashi(),
    ),
  );
}

class Flashi extends StatelessWidget {
  const Flashi({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashi',
      home: const Home(),
      theme: themeProvider.getLightTheme(),
      darkTheme: themeProvider.getDarkTheme(),
      themeMode: themeProvider.themeMode,
    );
  }
}
