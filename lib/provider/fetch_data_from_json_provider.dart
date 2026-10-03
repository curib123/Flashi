import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class FetchDataFromJsonProvider with ChangeNotifier {
  static const _configUrl =
      'https://curib123.github.io/flashi_/flashi.json';
  static const _fallbackModels = <String>['mistral-small-latest'];
  static const _fallbackQuizTypes = <String>[
    'Identification',
    'Fill_In_The_Blank',
    'Definition',
    'Enumeration',
    'True_False',
  ];
  static const _fallbackLengths = <int>[10, 20, 30, 40, 50];

  final Box _fetchDataFromJson = Hive.box('fetchDataFromJson');

  String _model = _fallbackModels.first;
  int _ListOfMaxLength = _fallbackLengths.first;
  int _creditsPerLength = 1;
  String _quiz_question_type = _fallbackQuizTypes.first;

  List<String> listOfModels = List<String>.from(_fallbackModels);
  List<String> listOfQuizQuestionTypes =
      List<String>.from(_fallbackQuizTypes);
  List<int> listOfMaxLength = List<int>.from(_fallbackLengths);

  String get model => _model;
  int get ListOfMaxLength => _ListOfMaxLength;
  int get creditsPerLength => _creditsPerLength;
  String get quiz_question_type => _quiz_question_type;

  FetchDataFromJsonProvider() {
    hiveLoad();
  }

  void hiveLoad() {
    _model = (_fetchDataFromJson.get(
      'model',
      defaultValue: _model,
    ) as String?) ??
        _fallbackModels.first;

    final storedLength = _fetchDataFromJson.get(
      'maxLength',
      defaultValue: _ListOfMaxLength,
    );
    if (storedLength is int) {
      _ListOfMaxLength = storedLength;
    }

    _quiz_question_type = (_fetchDataFromJson.get(
      'quiz_question_type',
      defaultValue: _quiz_question_type,
    ) as String?) ??
        _fallbackQuizTypes.first;

    listOfModels = _readStringList(
      'listOfModels',
      fallback: _fallbackModels,
    );
    listOfQuizQuestionTypes = _readStringList(
      'listOfQuizQuestionTypes',
      fallback: _fallbackQuizTypes,
    );
    listOfMaxLength = _readIntList(
      'listOfMaxLength',
      fallback: _fallbackLengths,
    );

    _normalizeSelections();
    _creditsPerLength = _calculateCreditCost(_ListOfMaxLength);
  }

  List<String> _readStringList(
    String key, {
    required List<String> fallback,
  }) {
    final value = _fetchDataFromJson.get(key);
    if (value is List && value.isNotEmpty) {
      return value.map((item) => item.toString()).toList();
    }
    return List<String>.from(fallback);
  }

  List<int> _readIntList(
    String key, {
    required List<int> fallback,
  }) {
    final value = _fetchDataFromJson.get(key);
    if (value is List && value.isNotEmpty) {
      final parsed = value
          .map((item) => item is int ? item : int.tryParse(item.toString()))
          .whereType<int>()
          .toList();
      if (parsed.isNotEmpty) return parsed;
    }
    return List<int>.from(fallback);
  }

  void _normalizeSelections() {
    if (!listOfModels.contains(_model)) {
      _model = listOfModels.first;
    }
    if (!listOfQuizQuestionTypes.contains(_quiz_question_type)) {
      _quiz_question_type = listOfQuizQuestionTypes.first;
    }
    if (!listOfMaxLength.contains(_ListOfMaxLength)) {
      _ListOfMaxLength = listOfMaxLength.first;
    }
  }

  Future<void> hiveSave() async {
    await _fetchDataFromJson.put('model', _model);
    await _fetchDataFromJson.put('maxLength', _ListOfMaxLength);
    await _fetchDataFromJson.put(
      'quiz_question_type',
      _quiz_question_type,
    );
    await _fetchDataFromJson.put('listOfModels', listOfModels);
    await _fetchDataFromJson.put(
      'listOfQuizQuestionTypes',
      listOfQuizQuestionTypes,
    );
    await _fetchDataFromJson.put('listOfMaxLength', listOfMaxLength);
  }

  void updateCreditsPerLength(int value) {
    _creditsPerLength = value < 1 ? 1 : value;
    notifyListeners();
  }

  void updateModel(String newModel) {
    if (!listOfModels.contains(newModel) || newModel == _model) return;
    _model = newModel;
    hiveSave();
    notifyListeners();
  }

  void updateQuizQuestionType(String newValue) {
    if (!listOfQuizQuestionTypes.contains(newValue) ||
        newValue == _quiz_question_type) {
      return;
    }
    _quiz_question_type = newValue;
    hiveSave();
    notifyListeners();
  }

  void updateListOfMaxLength(int newValue) {
    if (!listOfMaxLength.contains(newValue)) return;
    _ListOfMaxLength = newValue;
    _creditsPerLength = _calculateCreditCost(newValue);
    hiveSave();
    notifyListeners();
  }

  int _calculateCreditCost(int length) {
    final index = listOfMaxLength.indexOf(length);
    if (index >= 0) return index + 1;

    final fallback = length ~/ 10;
    return fallback < 1 ? 1 : fallback;
  }

  Future<void> fetchLatestVersion() async {
    final response = await http
        .get(Uri.parse(_configUrl))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw StateError(
        'AI configuration request failed (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid AI configuration payload.');
    }

    final models = decoded['ai_models'];
    final quizTypes = decoded['listOfQuizQuestionTypes'];
    final lengths = decoded['ListOfMaxLength'];

    if (models is List && models.isNotEmpty) {
      final parsedModels = models
          .map((item) {
            if (item is Map) return item['model_name']?.toString();
            return item?.toString();
          })
          .whereType<String>()
          .where((item) => item.trim().isNotEmpty)
          .toList();
      if (parsedModels.isNotEmpty) {
        listOfModels = parsedModels;
      }
    }

    if (quizTypes is List && quizTypes.isNotEmpty) {
      final parsedTypes = quizTypes
          .map((item) {
            if (item is Map) return item['name']?.toString();
            return item?.toString();
          })
          .whereType<String>()
          .where((item) => item.trim().isNotEmpty)
          .toList();
      if (parsedTypes.isNotEmpty) {
        listOfQuizQuestionTypes = parsedTypes;
      }
    }

    if (lengths is List && lengths.isNotEmpty) {
      final parsedLengths = lengths
          .map(
            (item) => item is int ? item : int.tryParse(item.toString()),
          )
          .whereType<int>()
          .where((item) => item > 0)
          .toList();
      if (parsedLengths.isNotEmpty) {
        listOfMaxLength = parsedLengths;
      }
    }

    _normalizeSelections();
    _creditsPerLength = _calculateCreditCost(_ListOfMaxLength);
    await hiveSave();
    notifyListeners();
  }
}
