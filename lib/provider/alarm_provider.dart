import 'package:flutter/material.dart';

class AlarmProvider with ChangeNotifier {
  // List of alarms
  List<Map<String, dynamic>> _alarms = [
    // {
    //   'status' : 'Completed',
    //   'goalTime': DateTime.now().add(Duration(days: 2)),
    //   'setName': 'setName1',
    //   'dateCreated': DateTime.now(),
    // },
    // {
    //   'status' : 'Completed',
    //   'goalTime': DateTime.now().add(Duration(days: 1)),
    //   'setName': 'setName2',
    //   'dateCreated': DateTime.now(),
    // }
  ];

  String _searchText = '';

  TextEditingController searchController = TextEditingController();

  // Getter to access the alarms list
  List<Map<String, dynamic>> get alarms => _alarms;

  String get searchText => _searchText;

  // Update the search query and notify listeners
  void updateSearchQuery(String query) {
    _searchText = query;
    notifyListeners();  // Notify listeners to update UI
  }

  // Create a new alarm
  void addAlarm(Map<String, dynamic> alarm) {
    _alarms.add(alarm);
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
      notifyListeners();  // Notify listeners to update UI
    }
  }

  // Update the status of an existing alarm by its name
  void updateAlarmStatus(String setName, String newStatus) {
    int index = _alarms.indexWhere((alarm) => alarm['alarmName'] == setName);
    if (index != -1) {
      _alarms[index]['status'] = newStatus;  // Only update the status field
      notifyListeners();  // Notify listeners to update UI
    }
  }


  // Delete an alarm by its name
  void deleteAlarm(String alarmName) {
    _alarms.removeWhere((alarm) => alarm['alarmName'] == alarmName);
    notifyListeners();  // Notify listeners to update UI
  }
}
