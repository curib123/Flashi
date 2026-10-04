import 'package:flashi/app.dart';
import 'package:flashi/data/services/api_client.dart';
import 'package:flashi/data/services/startio_service.dart';
import 'package:flashi/data/study_repository.dart';
import 'package:flashi/features/app_state.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/generation_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = await StudyRepository.open();
  await Hive.initFlutter();
  final legacyQuizBox = await Hive.openBox<dynamic>('quiz');
  await repository.migrateLegacyQuizSets(
    legacyQuizBox.get('quizSets', defaultValue: const <dynamic>[]) as dynamic,
  );

  final state = AppState(repository);
  await state.reload();

  final api = ApiClient();
  await api.restoreSession();

  final auth = AuthProvider(api);
  await auth.restore();

  final credits = AiCreditProvider(api);
  if (auth.signedIn) {
    await credits.refresh();
  }

  final generation = GenerationProvider(api);
  final ads = StartIoService();
  await ads.configureFromBackend(api);

  runApp(
    FlashiApp(
      state: state,
      auth: auth,
      generation: generation,
      credits: credits,
    ),
  );
}
