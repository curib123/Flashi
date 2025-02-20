import 'dart:convert';
import 'package:flashi/util/helpers/classes/api/ai/core/api_key_secure_storage.dart';
import 'package:http/http.dart' as http;

class ChatbotApi {
  static const String apiUrl = "https://api.mistral.ai/v1/chat/completions";
  static String? _cachedApiKey;
  static final http.Client _client = http.Client(); // Persistent HTTP client

  static Future<String?> _getCachedAPIKey() async {
    if (_cachedApiKey == null) {
      _cachedApiKey = await getAPIKey();
    }
    return _cachedApiKey;
  }

  static Future<String> sendMessage(List<Map<String, String>> messages) async {
    try {
      String? apiKey = await _getCachedAPIKey();

      if (apiKey == null || apiKey.isEmpty) {
        return "Error: API Key not found!";
      }

      // Extract only the last two messages
      List<Map<String, String>> lastTwoMessages =
      messages.length > 2 ? messages.sublist(messages.length - 2) : messages;

      // Format messages for API request
      List<Map<String, String>> formattedMessages = lastTwoMessages.map((msg) {
        return {
          "role": msg['sender'] == 'user' ? "user" : "assistant",
          "content": msg['text'] ?? ""
        };
      }).toList();

      final response = await _client.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
          "Accept-Encoding": "gzip", // Enables compression if API supports it
        },
        body: jsonEncode({
          "model": "pixtral-12b-2409", // Ensure the model name is correct
          "messages": formattedMessages,
          "max_tokens":400, // Reduced for faster response
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('choices') && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'];
        } else {
          return "Error: No valid response from API.";
        }
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }
}
