import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiModelProvider with ChangeNotifier {
  String _model = 'pixtral-12b-2409';
  int _maxLength = 20;
  String _quiz_question_type = 'Identification';
  Map<String, String> questionTypes = {};


  List<String> listOfModels = [
  ];

  List<String> listOfQuizQuestionTypes = [
   
  ];

  List<int> ListOfMaxLength = [
    20,
    30,
    40,
    50,
    60,
    70,
    80,
    90,
    100,
  ];

  String get model => _model;
  int get maxLength => _maxLength;
  String get quiz_question_type => _quiz_question_type;

  void updateModel(String newModel) {
    _model = newModel;
    notifyListeners();
  }

  void updateQuizQuestionType(String newValue) {
    _quiz_question_type = newValue;
    notifyListeners();
  }

  void updateMaxLength(int newValue) {
    _maxLength = newValue;
    notifyListeners();
  }

  Future<void> fetchLatestVersion() async {
    final response = await http.get(Uri.parse('https://curib123.github.io/flashi_/flashi.json'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Extract the AI models data
      List<dynamic> aiModels = data['ai_models'];

      // Update the listOfModels with the model names from the fetched data
      listOfModels = aiModels.map<String>((model) => model['model_name'] as String).toList();

      // Print details of the AI models (for debugging purposes)
      aiModels.forEach((model) {
        print('Model Name: ${model['model_name']}');
        print('Version: ${model['version']}');
        print('Description: ${model['description']}');
        print('---');
      });

      // Extract the questionTypes data
      questionTypes = Map<String, String>.from(data['questionTypes']);

      // Print all question types and their details (for debugging purposes)
      questionTypes.forEach((key, value) {
        listOfQuizQuestionTypes.add(key.toString());
      });

      // Notify listeners to update the UI
      notifyListeners();
    } else {
      print("Failed to load data");
    }
  }

}
