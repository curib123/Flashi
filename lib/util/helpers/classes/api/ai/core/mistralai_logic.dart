import 'dart:convert';
import 'package:flashi/util/helpers/classes/api/ai/core/api_key_secure_storage.dart';
import 'package:http/http.dart' as http;

class MistralAiLogic {
  static Future<List<Map<String, String>>> generateQuestionsFromFile(String content,String modelType,String type,int maxLength) async {
    await saveAPIKey('TZjSrnSAjyflYyNyFmPnMfHHSZ4Mw33q'); // Save API key (remove if stored separately)

    String? apiKey = await getAPIKey(); // Retrieve stored API key

    if (apiKey == null || apiKey.isEmpty) {
      print("API Key not found!");
      return [];
    }

    List<String> chunks = splitTextIntoChunks(content, 1000);
    List<Map<String, String>> allQuestions = [];

    for (String chunk in chunks) {
      List<Map<String, String>> questions = await processChunkMistral(chunk, apiKey,modelType,type,maxLength);
      allQuestions.addAll(questions);
      if (allQuestions.length >= maxLength) break;
    }

    return allQuestions.take(maxLength).toList();
  }
  static Future<List<Map<String, String>>> processChunkMistral(String textChunk, String apiKey,String modelType,String type,int maxLength) async {
    final String mistralEndpoint = "https://api.mistral.ai/v1/chat/completions";

    String generatePrompt() {
      switch (type) {
        case 'Identification':
          return """
      Generate ${maxLength} summarize identification questions and answers from the following text in this format accurately dont put title,heading or guide:
      Question: It is <definition/explanation/short question>.
      Answer: <term/answer>
      TEXT:
      "$textChunk"
      Example Output:
      Question: It is the process of converting food into energy?
      Answer: Metabolism
      Question: It is the capital city of France.
      Answer: Paris
      """;
        case 'Fill_In_The_Blank':
          return """
      Generate ${maxLength} summarize fill-in-the-blank  questions and answers from the following text in this format accurately dont put title,heading or guide:
      TEXT:
      "$textChunk"
      Example Output:
      Question: The process of converting food into energy is called _____?
      Answer: Metabolism
      Question: The capital city of France is _____?
      Answer: Paris
      """;
        case 'Definition':
          return """
      Generate ${maxLength} summarize Definition  questions and answers from the following text in this format accurately dont put title,heading or guide:
      TEXT:
      "$textChunk"
      Example Output:
      Question: The process of converting food into energy?
        Answer: Metabolism
      Question: The capital city of France?
       Answer: Paris
      """;
        case 'Enumeration':
          return """
      Generate ${maxLength} summarize enumeration-type  questions and answers from the following text in this format accurately dont put title,heading or guide:
      TEXT:
      "$textChunk"
      Example Output:
      Question: List the stages of cell division?
      Answer: Prophase, Metaphase, Anaphase, Telophase
      Question: Name the primary colors.
      Answer: Red, Blue, Yellow
      """;
        case 'True_False':
          return """
      Generate ${maxLength}  true or false  questions and answers from the following text in this format accurately dont put title,heading or guide:
      TEXT:
      "$textChunk"
      Example Output:
      Question: Metabolism is the process of breaking down food into nutrients. (True/False)?
      Answer: True
      Question: The capital of Germany is Paris. (True/False)?
      Answer: False
      """;
        default:
          return "Invalid question type";
      }
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
            {"role": "system", "content": "You are an expert quiz generator that is correct and accurate."},
            {"role": "user", "content": generatePrompt()}
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



  static Future<List<Map<String, String>>> generateQuestionsCustomAiGenerated(
      String topic,String description, String modelType, String type, int maxLength) async {

    await saveAPIKey('TZjSrnSAjyflYyNyFmPnMfHHSZ4Mw33q'); // Save API key (remove if stored separately)

    String? apiKey = await getAPIKey(); // Retrieve stored API key

    if (apiKey == null || apiKey.isEmpty) {
      print("API Key not found!");
      return [];
    }


    List<Map<String, String>> questions = await processChunkWithTitleDescription(
        topic,description, apiKey, modelType, type, maxLength
    );

    return questions.take(maxLength).toList();
  }

  static Future<List<Map<String, String>>> processChunkWithTitleDescription(
      String topic,String description, String apiKey, String modelType, String type, int maxLength) async {

    final String mistralEndpoint = "https://api.mistral.ai/v1/chat/completions";

    String generatePrompt() {
      switch (type) {
        case 'Identification':
          return """
Generate ${maxLength} concise identification questions and answers based on the given Topic: "$topic" and Description: "$description".
Each question should ask for a specific term or concept related to the topic.
Avoid guides,title,heading or extra information.

Example Output:
Question: What is the process of converting food into energy?
Answer: Metabolism
""";

        case 'Fill_In_The_Blank':
          return """
Generate ${maxLength} fill-in-the-blank questions and answers based on the given Topic: "$topic" and Description: "$description".
Each question should have a missing key term related to the topic.
Avoid guides,title,heading or extra information.

Example Output:
Question: The process of converting food into energy is called _____?
Answer: Metabolism
""";

        case 'Definition':
          return """
Generate ${maxLength} definition-based questions and answers based on the given Topic: "$topic" and Description: "$description".
Each question should ask for the meaning of a specific concept.
Avoid guides,title,heading or extra information.

Example Output:
Question: Define metabolism.
Answer: Metabolism is the process of converting food into energy.
""";

        case 'Enumeration':
          return """
Generate ${maxLength} enumeration-type questions and answers based on the given Topic: "$topic" and Description: "$description".
Each question should require listing multiple related items.
Avoid guides,title,heading or extra information.

Example Output:
Question: List the stages of cell division.
Answer: Prophase, Metaphase, Anaphase, Telophase
""";

        case 'True_False':
          return """
Generate ${maxLength} true or false questions and answers based on the given Topic: "$topic" and Description: "$description".
Each question should be a factual statement that can be answered with "True" or "False."
Avoid guides,title,heading or extra information.

Example Output:
Question: Metabolism is the process of breaking down food into nutrients. (True/False)?
Answer: True
""";

        default:
          return "Invalid question type.";
      }
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
            {"role": "system", "content": "You are an expert quiz generator that is facts and correct."},
            {"role": "user", "content": generatePrompt()}
          ],
          "max_tokens": 1000
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

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




}