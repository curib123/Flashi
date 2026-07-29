import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flashi/util/helpers/classes/api/ai/core/api_key_secure_storage.dart';

class OpenAiLogic {
  static Future<List<Map<String, String>>> generateQuestionsOpenAi(
      String content) async {
// Retrieve the stored API key securely
    final apiKey = await getAPIKey();

// Ensure the key is not null before assigning
    if (apiKey != null && apiKey.isNotEmpty) {
      OpenAI.apiKey = apiKey;
    } else {
      throw StateError('OpenAI API key is not configured');
    }

    List<String> chunks = splitTextIntoChunks(content, 1000);
    List<Map<String, String>> allQuestions = [];

    for (String chunk in chunks) {
      List<Map<String, String>> questions = await processChunkOpenai(chunk);
      allQuestions.addAll(questions);
      if (allQuestions.length >= 20) break;
    }

    return allQuestions.take(20).toList();
  }

  static Future<List<Map<String, String>>> processChunkOpenai(
      String textChunk) async {
    final prompt = """
  Generate 20 identification-type questions and answers from the following text:

  "$textChunk"

  Format:
  [
    {"question": "It is <definition/explanation>.", "answer": "<concept/term>"}
  ]
  
  Ensure the questions are direct and clear. The answers should be concise, ideally within one sentence.
  """;

    try {
      final response = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini",
        maxTokens: 400,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                    "You are an expert quiz generator.")
              ]),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
              ])
        ],
      );

      String aiResponse =
          response.choices.first.message.content?.first.text ?? "";
      print(aiResponse);
      return parseJsonQuestions(aiResponse);
    } catch (e) {
      print("Error processing chunk: $e");
      return [];
    }
  }

  static List<Map<String, String>> parseJsonQuestions(String jsonString) {
    try {
      final List<dynamic> decodedList = jsonDecode(jsonString);

      return decodedList.map((item) {
        return Map<String, String>.from(
            item.map((key, value) => MapEntry(key, value.toString())));
      }).toList();
    } catch (e) {
      print("Error parsing JSON: $e");
      return [];
    }
  }

  /// Splits large text into smaller chunks (e.g., 1000 words per chunk)
  static List<String> splitTextIntoChunks(String text, int chunkSize) {
    List<String> words = text.split(' ');
    List<String> chunks = [];
    for (int i = 0; i < words.length; i += chunkSize) {
      chunks.add(words
          .sublist(
              i, i + chunkSize > words.length ? words.length : i + chunkSize)
          .join(' '));
    }
    return chunks;
  }
}
