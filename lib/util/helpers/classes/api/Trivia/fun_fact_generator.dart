import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class TriviaGenerator {
  static const String triviaAPI = "https://the-trivia-api.com/api/questions?limit=30";

  static Future<List<String>> fetchTrivia() async {
    try {
      final response = await http.get(Uri.parse(triviaAPI));

      if (response.statusCode == 200) {
        List<dynamic> triviaList = jsonDecode(response.body);
        List<String> triviaFacts = [];

        for (var trivia in triviaList) {
          String question = trivia['question'];
          String answer = trivia['correctAnswer'];
          triviaFacts.add("Did you know? $question ($answer)");
        }

        // Shuffle to ensure randomness in order
        triviaFacts.shuffle(Random());

        return triviaFacts;
      } else {
        print("Trivia API Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching trivia: $e");
      return [];
    }
  }
}
