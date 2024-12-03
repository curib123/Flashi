import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SortProvider with ChangeNotifier {
  String _dropdownValue = 'Newest';  // Default value

  // Box for storing the selected sort value
  Box<dynamic> _sortBox = Hive.box('settings');

  final List<String> _sortOptions = [
    'Newest',
    'Oldest',
    'Alphabetical',
    'Reverse Alphabetical',
    'Number of Quizzes',
  ];

  // Getter for dropdownValue
  String get dropdownValue => _dropdownValue;

  // Getter for sortOptions
  List<String> get sortOptions => _sortOptions;

  SortProvider() {
    // Load saved sort value or use default
    _dropdownValue = _sortBox.get('selectedSort', defaultValue: 'Newest')!;
    notifyListeners();
  }

  // Update sort value and save it to Hive
  // Update sort value and notify listeners
  void updateSortValue(String newValue) {
    _dropdownValue = newValue;
    _sortBox.put('selectedSort', newValue);  // Save to Hive
    notifyListeners();
  }
}