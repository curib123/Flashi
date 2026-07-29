import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flashi/core/config/app_environment.dart';
import 'package:http/http.dart' as http;

class TriviaService {
  static const String triviaAPI = AppEnvironment.triviaApiUrl;

  static Future<List<Map<String, String>>> fetchTrivia() async {
    try {
      final response = await http.get(Uri.parse(triviaAPI));

      if (response.statusCode == 200) {
        List<dynamic> triviaList = jsonDecode(response.body);
        List<Map<String, String>> triviaQuestions = [];

        for (var trivia in triviaList) {
          String question = trivia['question'];
          String correctAnswer = trivia['correctAnswer'];
          List<String> incorrectAnswers =
              List<String>.from(trivia['incorrectAnswers']);

          while (incorrectAnswers.length < 3) {
            incorrectAnswers.add('Unknown ${incorrectAnswers.length + 1}');
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
        developer.log('Trivia API request failed: ${response.statusCode}.');
        return [];
      }
    } catch (e) {
      developer.log('Error fetching trivia.', error: e);
      return [];
    }
  }
}
