import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class GenerationConfigProvider extends ChangeNotifier {
  final Box<dynamic> _configurationBox = Hive.box('fetchDataFromJson');

  String _model = 'mistral-small-latest';
  int _maxLength = 10;
  int _creditsPerLength = 0;
  String _quizQuestionType = 'Identification';
  List<String> _models = [];
  List<String> _quizQuestionTypes = [];
  List<int> _maxLengths = [];

  String get model => _model;
  int get maxLength => _maxLength;
  int get creditsPerLength => _creditsPerLength;
  String get quizQuestionType => _quizQuestionType;
  List<String> get listOfModels => List.unmodifiable(_models);
  List<String> get listOfQuizQuestionTypes =>
      List.unmodifiable(_quizQuestionTypes);
  List<int> get listOfMaxLength => List.unmodifiable(_maxLengths);

  GenerationConfigProvider() {
    hiveLoad();
  }

  /// Load data from Hive
  void hiveLoad() {
    _model = _configurationBox.get('model', defaultValue: _model);
    _maxLength = _configurationBox.get('maxLength', defaultValue: _maxLength);
    _quizQuestionType = _configurationBox.get(
      'quiz_question_type',
      defaultValue: _quizQuestionType,
    );

    _models = List<String>.from(
      _configurationBox.get('listOfModels', defaultValue: []),
    );
    _quizQuestionTypes = List<String>.from(
      _configurationBox.get('listOfQuizQuestionTypes', defaultValue: []),
    );
    _maxLengths = List<int>.from(
      _configurationBox.get('listOfMaxLength', defaultValue: []),
    );
  }

  /// Save data to Hive
  void hiveSave() {
    _configurationBox.put('model', _model);
    _configurationBox.put('maxLength', _maxLength);
    _configurationBox.put('quiz_question_type', _quizQuestionType);

    _configurationBox.put('listOfModels', _models);
    _configurationBox.put('listOfQuizQuestionTypes', _quizQuestionTypes);
    _configurationBox.put('listOfMaxLength', _maxLengths);
  }

  void updateCreditsPerLength(int value) {
    if (_creditsPerLength == value) return;
    _creditsPerLength = value;
    notifyListeners();
  }

  /// Update functions with Hive saving
  void updateModel(String newModel) {
    if (_model == newModel) return;
    _model = newModel;
    hiveSave();
    notifyListeners();
  }

  void updateQuizQuestionType(String newValue) {
    if (_quizQuestionType == newValue) return;
    _quizQuestionType = newValue;
    hiveSave();
    notifyListeners();
  }

  void updateListOfMaxLength(int newValue) {
    if (_maxLength == newValue) return;
    _maxLength = newValue;
    hiveSave();
    notifyListeners();
  }

  /// Fetch latest version from API
  Future<void> fetchLatestVersion() async {
    final response = await http
        .get(Uri.parse('https://curib123.github.io/flashi_/flashi.json'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _models = List<String>.from(
        data['ai_models'].map((model) => model['model_name']),
      );
      _quizQuestionTypes = List<String>.from(
        data['listOfQuizQuestionTypes'].map((type) => type['name']),
      );
      _maxLengths = List<int>.from(data['ListOfMaxLength']);

      hiveSave(); // Save the fetched data to Hive
      notifyListeners();
    } else {
      debugPrint('Failed to load generation configuration');
    }
  }
}
