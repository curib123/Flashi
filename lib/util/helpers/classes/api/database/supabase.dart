import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

Future<void> setSupabaseAPIKey(String key) async {
  await storage.write(key: 'supabase_api_key', value: key);
}

Future<String?> getSupabaseAPIKey() async {
  return await storage.read(key: 'supabase_api_key');
}