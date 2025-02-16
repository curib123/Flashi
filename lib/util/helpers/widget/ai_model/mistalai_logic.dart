import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flashi/util/helpers/widget/ai_model/api_key.dart';

class MistralAiLogic {
  static Future<List<Map<String, String>>> generateQuestionsMistral(String content,String modelType,String type,int maxLength,var questionTypes) async {
    await saveAPIKey('TZjSrnSAjyflYyNyFmPnMfHHSZ4Mw33q'); // Save API key (remove if stored separately)

    String? apiKey = await getAPIKey(); // Retrieve stored API key

    if (apiKey == null || apiKey.isEmpty) {
      print("API Key not found!");
      return [];
    }

    List<String> chunks = splitTextIntoChunks(content, 1000);
    List<Map<String, String>> allQuestions = [];

    for (String chunk in chunks) {
      List<Map<String, String>> questions = await processChunkMistral(chunk, apiKey,modelType,type,maxLength,questionTypes);
      allQuestions.addAll(questions);
      if (allQuestions.length >= maxLength) break;
    }

    return allQuestions.take(maxLength).toList();
  }
  static Future<List<Map<String, String>>> processChunkMistral(String textChunk, String apiKey,String modelType,String type,int maxLength,var questionTypes) async {
    final String mistralEndpoint = "https://api.mistral.ai/v1/chat/completions";

     String generatePrompt(String type, int maxLength, String textChunk, var questionTypes) {
      // Return the prompt for the corresponding type, or a default message if not found
      return questionTypes[type] ?? "Invalid question type";
    }



    try {
      final response = await http.post(
        Uri.parse(mistralEndpoint),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "model": modelType, // Updated to a known model name
          "messages": [
            {"role": "system", "content": "You are an expert quiz generator."},
            {"role": "user", "content": generatePrompt(type,maxLength,textChunk,questionTypes)}
          ],
          "max_tokens": 1000
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Ensure 'choices' exists, is a list, and contains at least one item
        if (responseData.containsKey('choices') &&
            responseData['choices'] is List &&
            responseData['choices'].isNotEmpty) {

          String aiResponse = responseData['choices'][0]['message']?['content']?.trim() ?? "";

          if (aiResponse.isNotEmpty) {
            print(aiResponse);
            return await parseTextQuestions(aiResponse);
          } else {
            print("No valid content received from Mistral AI.");
            return [];
          }
        } else {
          print("Unexpected API response structure: ${response.body}");
          return [];
        }
      } else {
        print("Mistral API Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error processing chunk with Mistral: $e");
      return [];
    }
  }


  static Future<List<Map<String, String>>> parseTextQuestions(String text) async {
    final List<Map<String, String>> parsedQuestions = [];

    final RegExp regExp = RegExp(
      r'Question:\s*(.+?)\s*\nAnswer:\s*(.+?)\s*(?:\n|$)',
      multiLine: true,
      dotAll: true,
    );

    await Future.delayed(Duration.zero); // Ensures async execution

    for (final match in regExp.allMatches(text)) {
      String question = match.group(1)?.trim() ?? "Incomplete question";
      String answer = match.group(2)?.trim() ?? "Incomplete answer";

      parsedQuestions.add({"question": question, "answer": answer});
    }

    return parsedQuestions;
  }



  static List<String> splitTextIntoChunks(String text, int chunkSize) {
    List<String> words = text.split(' ');
    List<String> chunks = [];
    for (int i = 0; i < words.length; i += chunkSize) {
      chunks.add(words.sublist(i, i + chunkSize > words.length ? words.length : i + chunkSize).join(' '));
    }
    return chunks;
  }
}
