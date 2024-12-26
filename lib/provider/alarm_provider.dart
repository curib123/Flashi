import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AlarmProvider with ChangeNotifier {
  final Box _alarmsBox = Hive.box('alarmsBox'); // Hive box for settings

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
      _alarms = List<Map<String, dynamic>>.from(_alarmsBox.values.map((e) => Map<String, dynamic>.from(e)));
      notifyListeners(); // Notify listeners after loading
    }
  }

  // Save alarms to Hive
  void saveAlarms() {
    _alarmsBox.clear(); // Clear the previous data in Hive box
    for (var alarm in _alarms) {
      _alarmsBox.add(Map<String, dynamic>.from(alarm)); // Add each alarm to Hive as a Map
    }
  }

  // Update the search query and notify listeners
  void updateSearchQuery(String query) {
    _searchText = query;
    notifyListeners(); // Notify listeners to update UI
  }

  // Create a new alarm
  void addAlarm(Map<String, dynamic> alarm) {
    _alarms.add(alarm);
    saveAlarms(); // Save updated alarms to Hive
    notifyListeners(); // Notify listeners to update UI
  }

  // Filter alarms based on search text or specific parameters
  List<Map<String, dynamic>> filterAlarms() {
    if (_searchText.isEmpty) {
      return alarms; // If no search text, return all alarms
    }

    return alarms.where((alarm) {
      bool matchesSetName = alarm['setName']
          .toLowerCase()
          .contains(_searchText.toLowerCase());
      // Optionally, add more fields to search on in future
      return matchesSetName;
    }).toList();
  }

  // Update an existing alarm by its name
  void updateAlarm(String setName, Map<String, dynamic> updatedAlarm) {
    int index = _alarms.indexWhere((alarm) => alarm['setName'] == setName);
    if (index != -1) {
      _alarms[index] = updatedAlarm;
      saveAlarms(); // Save updated alarms to Hive
      notifyListeners(); // Notify listeners to update UI
    }
  }

  // Update the status of all alarms
  void updateAlarmStatus() {
    for (int index = 0; index < alarms.length; index++) {
      var alarm = alarms[index];

      // Ensure the goalTime exists and is a valid DateTime
      if (alarm['goalTime'] != null && alarm['goalTime'] is DateTime) {
        Duration remainingTime = alarm['goalTime'].difference(DateTime.now());

        // Calculate the status based on remaining time
        String status = '';
        if (remainingTime.isNegative) {
          status = "Completed";
        } else if (remainingTime.inDays > 0) {
          status = "Upcoming";
        } else {
          status = "Today";
        }

        // Update the status field of the alarm
        alarms[index]['status'] = status;
      } else {
        alarms[index]['status'] = 'Invalid time'; // Handle invalid goalTime
      }
    }

    // Save updated alarms to Hive
    saveAlarms();

    // Notify listeners to update UI
    notifyListeners();
  }

  void deleteAlarm(String setName) {
    // Find the alarm with the matching 'setName'
    final alarmToRemove = _alarms.firstWhere(
          (alarm) => alarm['setName'] == setName,

    );

    if (alarmToRemove == null) {
      // Alarm not found
      debugPrint("No alarm found with setName: $setName");
    } else {
      // Remove the found alarm
      _alarms.remove(alarmToRemove);
      debugPrint("Alarm with setName: $setName deleted.");
      print(alarms);
      saveAlarms();
      notifyListeners();
    }
  }


}
