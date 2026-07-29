import 'dart:convert';

import 'package:flashi/core/config/app_environment.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class GenerationConfigProvider extends ChangeNotifier {
  GenerationConfigProvider({
    Box<dynamic>? box,
    http.Client? client,
  })  : _box = box ?? Hive.box<dynamic>('fetchDataFromJson'),
        _client = client ?? http.Client(),
        _ownsClient = client == null {
    _load();
  }

  static final Uri _configurationUri =
      Uri.parse(AppEnvironment.releaseConfigUrl);

  final Box<dynamic> _box;
  final http.Client _client;
  final bool _ownsClient;

  String _model = 'mistral-small-latest';
  int _maxLength = 10;
  int _creditsPerLength = 0;
  String _quizQuestionType = 'Identification';
  List<String> _models = const [];
  List<String> _quizQuestionTypes = const [];
  List<int> _maxLengths = const [];
  bool _isLoading = false;
  Object? _lastError;

  String get model => _model;
  int get maxLength => _maxLength;
  int get creditsPerLength => _creditsPerLength;
  String get quizQuestionType => _quizQuestionType;
  List<String> get listOfModels => _models;
  List<String> get listOfQuizQuestionTypes => _quizQuestionTypes;
  List<int> get listOfMaxLength => _maxLengths;
  bool get isLoading => _isLoading;
  Object? get lastError => _lastError;

  void updateCreditsPerLength(int value) {
    if (_creditsPerLength == value) return;
    _creditsPerLength = value;
    notifyListeners();
  }

  void updateModel(String model) {
    if (_model == model) return;
    _model = model;
    _persistAndNotify();
  }

  void updateQuizQuestionType(String type) {
    if (_quizQuestionType == type) return;
    _quizQuestionType = type;
    _persistAndNotify();
  }

  void updateListOfMaxLength(int length) {
    if (_maxLength == length) return;
    _maxLength = length;
    _creditsPerLength = _calculateEnergyCost(length);
    _persistAndNotify();
  }

  Future<void> fetchLatestVersion() async {
    if (_isLoading) return;
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await _client.get(_configurationUri);
      if (response.statusCode != 200) {
        throw http.ClientException(
          'Unable to load generation configuration (${response.statusCode})',
          _configurationUri,
        );
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _models = List<String>.unmodifiable(
        (data['ai_models'] as List)
            .map((model) => (model as Map)['model_name'].toString()),
      );
      _quizQuestionTypes = List<String>.unmodifiable(
        (data['listOfQuizQuestionTypes'] as List)
            .map((type) => (type as Map)['name'].toString()),
      );
      _maxLengths = List<int>.unmodifiable(
        (data['ListOfMaxLength'] as List).map((value) => value as int),
      );
      _creditsPerLength = _calculateEnergyCost(_maxLength);
      _persist();
    } catch (error) {
      _lastError = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _load() {
    _model = _box.get('model', defaultValue: _model) as String;
    _maxLength = _box.get('maxLength', defaultValue: _maxLength) as int;
    _quizQuestionType = _box.get(
      'quiz_question_type',
      defaultValue: _quizQuestionType,
    ) as String;
    _models = List<String>.unmodifiable(
      List<String>.from(_box.get('listOfModels', defaultValue: const [])),
    );
    _quizQuestionTypes = List<String>.unmodifiable(
      List<String>.from(
        _box.get('listOfQuizQuestionTypes', defaultValue: const []),
      ),
    );
    _maxLengths = List<int>.unmodifiable(
      List<int>.from(_box.get('listOfMaxLength', defaultValue: const [])),
    );
    _creditsPerLength = _calculateEnergyCost(_maxLength);
  }

  int _calculateEnergyCost(int length) {
    final configuredIndex = _maxLengths.indexOf(length);
    if (configuredIndex >= 0) return configuredIndex + 1;
    return (length / 10).ceil().clamp(1, 100);
  }

  void _persistAndNotify() {
    _persist();
    notifyListeners();
  }

  void _persist() {
    _box
      ..put('model', _model)
      ..put('maxLength', _maxLength)
      ..put('quiz_question_type', _quizQuestionType)
      ..put('listOfModels', _models)
      ..put('listOfQuizQuestionTypes', _quizQuestionTypes)
      ..put('listOfMaxLength', _maxLengths);
  }

  @override
  void dispose() {
    if (_ownsClient) _client.close();
    super.dispose();
  }
}
