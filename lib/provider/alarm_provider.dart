import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AlarmProvider with ChangeNotifier {

  final Box _alarmsBox = Hive.box('settings'); // Hive box for settings

  List<Map<String, dynamic>> _alarms = [];

  String _searchText = '';

  TextEditingController searchController = TextEditingController();

  // Getter to access the alarms list
  List<Map<String, dynamic>> get alarms => _alarms;

  String get searchText => _searchText;

  // Constructor to load alarms from Hive on startup
  AlarmProvider() {
    loadAlarms();
  }

  // Load alarms from Hive into the list
  void loadAlarms() {
    if (_alarmsBox.isNotEmpty) {
      _alarms = List<Map<String, dynamic>>.from(_alarmsBox.values);
      notifyListeners();  // Notify listeners after loading
    }
  }

  // Save alarms to Hive
  void saveAlarms() {
    _alarmsBox.clear();  // Clear the previous data in Hive box
    for (var alarm in _alarms) {
      _alarmsBox.add(alarm);  // Add each alarm to Hive
    }
  }

  // Update the search query and notify listeners
  void updateSearchQuery(String query) {
    _searchText = query;
    notifyListeners();  // Notify listeners to update UI
  }

  // Create a new alarm
  void addAlarm(Map<String, dynamic> alarm) {
    _alarms.add(alarm);
    saveAlarms();  // Save updated alarms to Hive
    notifyListeners();  // Notify listeners to update UI
  }

  // Filter alarms based on search text or specific parameters
  List<Map<String, dynamic>> filterAlarms() {
    if (_searchText.isEmpty) {
      return _alarms;  // If no search text, return all alarms
    }

    return _alarms.where((alarm) {
      bool matchesSetName = alarm['setName']
          .toLowerCase()
          .contains(_searchText.toLowerCase());
      return matchesSetName; // Return true if matches any
    }).toList();
  }

  // Update an existing alarm by its name
  void updateAlarm(String setName, Map<String, dynamic> updatedAlarm) {
    int index = _alarms.indexWhere((alarm) => alarm['setName'] == setName);
    if (index != -1) {
      _alarms[index] = updatedAlarm;
      saveAlarms();  // Save updated alarms to Hive
      notifyListeners();  // Notify listeners to update UI
    }
  }

  // Update the status of an existing alarm by its name
  void updateAlarmStatus(String setName, String newStatus) {
    int index = _alarms.indexWhere((alarm) => alarm['setName'] == setName);
    if (index != -1) {
      _alarms[index]['status'] = newStatus;  // Only update the status field
      saveAlarms();  // Save updated alarms to Hive
      notifyListeners();  // Notify listeners to update UI
    }
  }

  // Delete an alarm by its name
  void deleteAlarm(String alarmName) {
    _alarms.removeWhere((alarm) => alarm['alarmName'] == alarmName);
    saveAlarms();  // Save updated alarms to Hive
    notifyListeners();  // Notify listeners to update UI
  }
}
