import 'dart:convert';
import 'dart:io';
import 'package:flashi/util/helpers/classes/api/ai/core/api_key_secure_storage.dart';
import 'package:http/http.dart' as http;

class ImageRecognition {
  static const String apiUrl = 'https://api.mistral.ai/v1/chat/completions';

  static Future<String> analyzeImage(
      Future<File?> imageFileFuture, String instruction) async {
    try {
      // Retrieve stored API key
      String? apiKey = await getAPIKey();
      if (apiKey == null || apiKey.isEmpty) {
        return 'Error: API key is missing.';
      }

      // Wait for the file to be available
      File? imageFile = await imageFileFuture;
      if (imageFile == null) {
        return 'Error: No image selected.';
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'pixtral-12b-2409',
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': instruction},
                {
                  'type': 'image_url',
                  'image_url': 'data:image/jpeg;base64,$base64Image'
                }
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }
}
