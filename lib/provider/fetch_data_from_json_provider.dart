import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class FetchDataFromJsonProvider with ChangeNotifier {
  final Box _fetchDataFromJson = Hive.box('fetchDataFromJson');

  String _model = '';
  int _ListOfMaxLength = 0;
  int _creditsPerLength = 0;
  String _quiz_question_type = '';
  List<String> listOfModels = [];
  List<String> listOfQuizQuestionTypes = [];
  List<int> listOfMaxLength = [];


  String get model => _model;
  int get ListOfMaxLength => _ListOfMaxLength;
  int get creditsPerLength => _creditsPerLength;
  String get quiz_question_type => _quiz_question_type;

  /// Load data from Hive
  void hiveLoad() {
    _model = _fetchDataFromJson.get('model', defaultValue: '');
    _ListOfMaxLength = _fetchDataFromJson.get('maxLength', defaultValue: 20);
    _quiz_question_type = _fetchDataFromJson.get('quiz_question_type', defaultValue: '');

    listOfModels = List<String>.from(_fetchDataFromJson.get('listOfModels', defaultValue: []));
    listOfQuizQuestionTypes = List<String>.from(_fetchDataFromJson.get('listOfQuizQuestionTypes', defaultValue: []));
    listOfMaxLength = List<int>.from(_fetchDataFromJson.get('listOfMaxLength', defaultValue: []));

    notifyListeners();
  }

  /// Save data to Hive
  void hiveSave() {
    _fetchDataFromJson.put('model', _model);
    _fetchDataFromJson.put('maxLength', _ListOfMaxLength);
    _fetchDataFromJson.put('quiz_question_type', _quiz_question_type);

    _fetchDataFromJson.put('listOfModels', listOfModels);
    _fetchDataFromJson.put('listOfQuizQuestionTypes', listOfQuizQuestionTypes);
    _fetchDataFromJson.put('listOfMaxLength', listOfMaxLength);
  }

  void updateCreditsPerLength(int value){
    _creditsPerLength = value;
    notifyListeners();
  }

  /// Update functions with Hive saving
  void updateModel(String newModel) {
    _model = newModel;
    hiveSave();
    notifyListeners();
  }

  void updateQuizQuestionType(String newValue) {
    _quiz_question_type = newValue;
    hiveSave();
    notifyListeners();
  }

  void updateListOfMaxLength(int newValue) {
    _ListOfMaxLength = newValue;
    hiveSave();
    notifyListeners();
  }

  /// Fetch latest version from API
  Future<void> fetchLatestVersion() async {
    final response = await http.get(Uri.parse('https://curib123.github.io/flashi_/flashi.json'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      listOfModels = List<String>.from(data['ai_models'].map((model) => model['model_name']));
      listOfQuizQuestionTypes = List<String>.from(data['listOfQuizQuestionTypes'].map((type) => type['name']));
      listOfMaxLength = List<int>.from(data['ListOfMaxLength']);

      hiveSave(); // Save the fetched data to Hive
      notifyListeners();
    } else {
      print("Failed to load data");
    }
  }
}
