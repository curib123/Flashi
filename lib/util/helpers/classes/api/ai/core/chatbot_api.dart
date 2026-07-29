import 'dart:convert';
import 'dart:async'; // Import required for timeout
import 'package:flashi/util/helpers/classes/api/ai/core/api_key_secure_storage.dart';
import 'package:http/http.dart' as http;

class ChatbotApi {
  static const String apiUrl = "https://api.mistral.ai/v1/chat/completions";
  static String? _cachedApiKey;
  static final http.Client _client = http.Client(); // Persistent HTTP client
  static const Duration timeoutDuration =
      Duration(seconds: 60); // Timeout duration

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
        return "API Key missing or invalid.";
      }

      // Extract only the last two messages
      List<Map<String, String>> lastTwoMessages = messages.length > 2
          ? messages.sublist(messages.length - 2)
          : messages;

      // Format messages for API request
      List<Map<String, String>> formattedMessages = lastTwoMessages.map((msg) {
        return {
          "role": msg['sender'] == 'user' ? "user" : "assistant",
          "content": msg['text'] ?? ""
        };
      }).toList();

      final response = await _client
          .post(
            Uri.parse(apiUrl),
            headers: {
              "Authorization": "Bearer $apiKey",
              "Content-Type": "application/json",
              "Accept-Encoding": "gzip",
            },
            body: jsonEncode({
              "model": "pixtral-12b-2409",
              "messages": formattedMessages,
              "max_tokens": 500,
            }),
          )
          .timeout(timeoutDuration); // Apply 60-second timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('choices') && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'];
        } else {
          return "No valid response from the assistant.";
        }
      } else {
        return "Request failed. Maybe weak internet access. Try again.";
      }
    } on TimeoutException {
      return "Request timed out. Please check your internet connection and try again.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }
}
