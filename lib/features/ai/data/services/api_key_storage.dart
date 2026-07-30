import 'package:flashi/core/config/app_environment.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
const _mistralApiKeyStorageKey = 'mistral_api_key';
const _legacyApiKeyStorageKey = 'openai_api_key';

Future<void> saveApiKey(String key) async {
  await storage.write(key: _mistralApiKeyStorageKey, value: key);
}

Future<String?> getApiKey() async {
  final storedKey = await storage.read(key: _mistralApiKeyStorageKey) ??
      await storage.read(key: _legacyApiKeyStorageKey);
  if (storedKey != null && storedKey.trim().isNotEmpty) {
    return storedKey.trim();
  }

  final environmentKey = AppEnvironment.mistralApiKey.trim();
  return environmentKey.isEmpty ? null : environmentKey;
}
