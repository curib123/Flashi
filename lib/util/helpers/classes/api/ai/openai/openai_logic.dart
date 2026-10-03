import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flashi/util/helpers/classes/api/ai/core/api_key_secure_storage.dart';
import 'package:flutter/foundation.dart';

class OpenAiLogic {
  static Future<List<Map<String, String>>> generateQuestionsOpenAi(
    String content,
  ) async {
    final apiKey = (await getAPIKey())?.trim();

    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('OpenAI API key is not configured.');
      return [];
    }

    OpenAI.apiKey = apiKey;

    final chunks = splitTextIntoChunks(content, 1000);
    final allQuestions = <Map<String, String>>[];

    for (final chunk in chunks) {
      final questions = await processChunkOpenai(chunk);
      allQuestions.addAll(questions);
      if (allQuestions.length >= 20) break;
    }

    return allQuestions.take(20).toList();
  }

  static Future<List<Map<String, String>>> processChunkOpenai(
    String textChunk,
  ) async {
    final prompt = """
Generate 20 identification-type questions and answers from the following text:

"$textChunk"

Format:
[
  {"question": "It is <definition/explanation>.", "answer": "<concept/term>"}
]

Ensure the questions are direct and clear. Keep answers concise.
""";

    try {
      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        maxTokens: 400,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'You are an expert quiz generator.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
      );

      final aiResponse =
          response.choices.first.message.content?.first.text?.trim() ?? '';

      if (aiResponse.isEmpty) {
        debugPrint('OpenAI returned an empty quiz response.');
        return [];
      }

      return parseJsonQuestions(aiResponse);
    } catch (error) {
      debugPrint('OpenAI quiz generation failed: $error');
      return [];
    }
  }

  static List<Map<String, String>> parseJsonQuestions(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) return [];

      return decoded.whereType<Map>().map((item) {
        return item.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }).toList();
    } catch (error) {
      debugPrint('OpenAI quiz response could not be parsed: $error');
      return [];
    }
  }

  static List<String> splitTextIntoChunks(String text, int chunkSize) {
    final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    final chunks = <String>[];

    for (var index = 0; index < words.length; index += chunkSize) {
      final end = (index + chunkSize).clamp(0, words.length);
      chunks.add(words.sublist(index, end).join(' '));
    }

    return chunks;
  }
}
