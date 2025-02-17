import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiModelProvider with ChangeNotifier {
  String _model = '';
  int _maxLength = 0;
  String _quiz_question_type = '';
  List<String> listOfModels = [];
  List<String> listOfQuizQuestionTypes = [];
  List<int> ListOfMaxLength = [];

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
      List<dynamic> questionTypes = data['listOfQuizQuestionTypes'];

      // Update the listOfModels with the model names from the fetched data
      listOfModels = aiModels.map<String>((model) => model['model_name'] as String).toList();
      listOfQuizQuestionTypes = questionTypes.map<String>((model) => model['name'] as String).toList();
      ListOfMaxLength = List<int>.from(data['ListOfMaxLength']);

      // Notify listeners to update the UI
      notifyListeners();
    } else {
      print("Failed to load data");
    }
  }


}
