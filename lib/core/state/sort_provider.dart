import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SortProvider extends ChangeNotifier {
  String _dropdownValueSet = 'Newest'; // Default value
  String _dropdownValueCard = 'Newest'; // Default value
  String _dropdownValueNote = 'Blocks'; // Default value
  String _dropdownValueTask = 'Tiles'; // Default value
  String _dropdownValuePdf = 'Blocks'; // Default value

  // Box for storing the selected sort value
  final Box<dynamic> _sortBox = Hive.box('sort');

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
  final List<String> _sortOptionsTask = [
    'Tiles',
    'Blocks',
  ];
  final List<String> _sortOptionsPdf = [
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
  String get dropdownValuePdf => _dropdownValuePdf;

  // Getter for sortOptions
  List<String> get sortOptionsSet => List.unmodifiable(_sortOptionsSet);
  List<String> get sortOptionsCard => List.unmodifiable(_sortOptionsCard);
  List<String> get sortOptionsNote => List.unmodifiable(_sortOptionsNote);
  List<String> get sortOptionsTask => List.unmodifiable(_sortOptionsTask);
  List<String> get sortOptionsPdf => List.unmodifiable(_sortOptionsPdf);

  SortProvider() {
    // Load saved sort value or use default
    _dropdownValueSet =
        _sortBox.get('selectedSortSet', defaultValue: 'Newest')!;
    _dropdownValueCard =
        _sortBox.get('selectedSortCard', defaultValue: 'Newest')!;
    _dropdownValueNote =
        _sortBox.get('selectedSortNote', defaultValue: 'Blocks')!;
    _dropdownValueTask =
        _sortBox.get('dropdownValueTask', defaultValue: 'Tiles')!;
    _dropdownValuePdf =
        _sortBox.get('dropdownValuePdf', defaultValue: 'Blocks')!;
  }

  // Update sort value and save it to Hive
  void updateSortValueSet(String newValue) {
    if (_dropdownValueSet == newValue) return;
    _dropdownValueSet = newValue;
    _sortBox.put('selectedSortSet', newValue); // Save to Hive
    notifyListeners();
  }

  // Update sort value and save it to Hive
  void updateSortValueNote(String newValue) {
    if (_dropdownValueNote == newValue) return;
    _dropdownValueNote = newValue;
    _sortBox.put('selectedSortNote', newValue); // Save to Hive
    notifyListeners();
  }

  // Update sort value and save it to Hive
  void updateSortValueTask(String newValue) {
    if (_dropdownValueTask == newValue) return;
    _dropdownValueTask = newValue;
    _sortBox.put('dropdownValueTask', newValue); // Save to Hive
    notifyListeners();
  }

  void updateSortValueCard(String newValue) {
    if (_dropdownValueCard == newValue) return;
    _dropdownValueCard = newValue;
    _sortBox.put('selectedSortCard', newValue); // Save to Hive
    notifyListeners();
  }

  void updateSortValuePdf(String newValue) {
    if (_dropdownValuePdf == newValue) return;
    _dropdownValuePdf = newValue;
    _sortBox.put('selectedSortPdf', newValue); // Save to Hive
    notifyListeners();
  }
}
