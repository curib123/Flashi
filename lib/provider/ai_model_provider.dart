import 'package:flutter/material.dart';

class AiModelProvider with ChangeNotifier{
  String _model = 'mistral-small-latest';
  int _maxLength = 20;
  String _quiz_question_type = 'Identification';

  List<String> listOfModels = [
    'mistral-small-latest',
    'pixtral-12b-2409',
    'open-mistral-nemo',
    'mistral-medium',

  ];
List<String> listOfQuizQuestionTypes = [

  'Identification',
  'Fill_In_The_Blank',
  'Definition',
  'Enumeration',
  'True_False',

  ];

  List<int> ListOfMaxLength = [
    20,
    30,
    40,
    50,
    60,
    70

  ];

  String get model => _model;
  int get maxLength => _maxLength;
  String get quiz_question_type => _quiz_question_type;

  void updateModel(String newModel){
    _model = newModel;
    notifyListeners();
  }

  void updateQuizQuestionType(String newValue){
    _quiz_question_type = newValue;
    notifyListeners();
  }
  void updateMaxLength(int newValue){
    _maxLength = newValue;
    notifyListeners();
  }
}