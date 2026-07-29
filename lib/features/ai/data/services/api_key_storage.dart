import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<void> saveApiKey(String key) async {
  await storage.write(key: 'openai_api_key', value: key);
}

Future<String?> getApiKey() => storage.read(key: 'openai_api_key');
