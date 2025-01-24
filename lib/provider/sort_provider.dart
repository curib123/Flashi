import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SortProvider with ChangeNotifier {
  String _dropdownValueSet = 'Newest';  // Default value
  String _dropdownValueCard = 'Newest';  // Default value
  String _dropdownValueNote = 'Blocks';  // Default value
  String _dropdownValueTask = 'Tiles';  // Default value

  // Box for storing the selected sort value
  Box<dynamic> _sortBox = Hive.box('sort');

  final List<String> _sortOptionsSet = [
    'Newest',
    'Oldest',
    'Alphabetical',
    'Reverse Alphabetical',
    'Number of Quizzes',
  ];

  final List<String> _sortOptionsNote = [
    'Tiles',
    'Blocks',
  ];
 final List<String> _sortOptionsTask= [
    'Tiles',
    'Blocks',
  ];

  final List<String> _sortOptionsCard = [
    'Newest',
    'Oldest',
    'Alphabetical',
    'Reverse Alphabetical',
  ];

  // Getter for dropdownValue
  String get dropdownValueSet => _dropdownValueSet;
  String get dropdownValueCard => _dropdownValueCard;
  String get dropdownValueNote => _dropdownValueNote;
  String get dropdownValueTask => _dropdownValueTask;

  // Getter for sortOptions
  List<String> get sortOptionsSet => _sortOptionsSet;
  List<String> get sortOptionsCard => _sortOptionsCard;
  List<String> get sortOptionsNote => _sortOptionsNote;
  List<String> get sortOptionsTask => _sortOptionsTask;

  SortProvider() {
    // Load saved sort value or use default
    _dropdownValueSet = _sortBox.get('selectedSortSet', defaultValue: 'Newest')!;
    _dropdownValueCard = _sortBox.get('selectedSortCard', defaultValue: 'Newest')!;
    _dropdownValueNote = _sortBox.get('selectedSortNote', defaultValue: 'Tiles')!;
    _dropdownValueTask = _sortBox.get('dropdownValueTask', defaultValue: 'Tiles')!;
    notifyListeners();
  }

  // Update sort value and save it to Hive
  void updateSortValueSet(String newValue) {
    _dropdownValueSet = newValue;
    _sortBox.put('selectedSortSet', newValue);  // Save to Hive
    notifyListeners();
  }

  // Update sort value and save it to Hive
  void updateSortValueNote(String newValue) {
    _dropdownValueNote = newValue;
    _sortBox.put('selectedSortNote', newValue);  // Save to Hive
    notifyListeners();
  }

  // Update sort value and save it to Hive
  void updateSortValueTask(String newValue) {
    _dropdownValueTask = newValue;
    _sortBox.put('dropdownValueTask', newValue);  // Save to Hive
    notifyListeners();
  }

  void updateSortValueCard(String newValue) {
    _dropdownValueCard = newValue;
    _sortBox.put('selectedSortCard', newValue);  // Save to Hive
    notifyListeners();
  }
}