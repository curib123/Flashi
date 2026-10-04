import 'package:flashi/app.dart';
import 'package:flashi/data/services/api_client.dart';
import 'package:flashi/data/services/auth_service.dart';
import 'package:flashi/data/services/backup_service.dart';
import 'package:flashi/data/services/generation_service.dart';
import 'package:flashi/data/services/startio_service.dart';
import 'package:flashi/data/services/sync_service.dart';
import 'package:flashi/data/session_store.dart';
import 'package:flashi/data/study_repository.dart';
import 'package:flashi/features/app_state.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = await StudyRepository.open();
  final state = AppState(repository);
  await state.reload();

  final session = SessionStore();
  await session.load();
  final api = ApiClient(session);
  final auth = AuthService(api, session);
  final generation = GenerationService(api);
  final backup = BackupService();
  final sync = SyncService(api, repository);

  // Start.io remains centralized. Runtime enable/test/placement flags come from
  // /api/v1/config; the native App ID stays build-time configuration.
  final ads = StartIoService();
  try {
    final config = await api.get('/api/v1/config');
    final adConfig = config['ads'];
    if (adConfig is Map && adConfig['enabled'] == true) {
      await ads.configure(testMode: adConfig['testMode'] != false);
    }
  } catch (_) {
    // Offline/manual study must never be blocked by remote config.
  }

  runApp(
    FlashiApp(
      state: state,
      generation: generation,
      auth: auth,
      backup: backup,
      sync: sync,
    ),
  );
}
