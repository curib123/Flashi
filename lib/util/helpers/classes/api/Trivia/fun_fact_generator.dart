import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class TriviaGenerator {
  static const String triviaAPI = "https://the-trivia-api.com/api/questions?limit=30";

  static Future<List<Map<String, String>>> fetchTrivia() async {
    try {
      final response = await http.get(Uri.parse(triviaAPI));

      if (response.statusCode == 200) {
        List<dynamic> triviaList = jsonDecode(response.body);
        List<Map<String, String>> triviaQuestions = [];

        for (var trivia in triviaList) {
          String question = trivia['question'];
          String correctAnswer = trivia['correctAnswer'];
          List<String> incorrectAnswers = List<String>.from(trivia['incorrectAnswers']);

          // Ensure there are at least two fake choices
          if (incorrectAnswers.length < 2) {
            incorrectAnswers.add("Unknown"); // Fallback fake choice
          }

          triviaQuestions.add({
            "question": question,
            "correct_answer": correctAnswer,
            "fake_choice_1": incorrectAnswers[0],
            "fake_choice_2": incorrectAnswers[1],
            "fake_choice_3": incorrectAnswers[2],
          });
        }

        // Shuffle questions to add randomness
        triviaQuestions.shuffle(Random());

        return triviaQuestions;
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
