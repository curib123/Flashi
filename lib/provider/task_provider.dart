import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskProvider with ChangeNotifier {
  // Box for storing tasks (assumed to be opened in main.dart)
  final Box _taskBox = Hive.box('task');

  TaskProvider() {
    loadTasks(); // Load tasks when the TaskProvider is created
  }

  // List of study tasks
  List<Map<String, dynamic>> studyTasks = [];

  TextEditingController taskNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Clear the controller
  void clearController() {
    taskNameController.clear();
  }

  void onSearchQuery(String newValue) {
    searchQuery = newValue;
    notifyListeners();
  }

  // Load tasks from Hive into the studyTasks list
  void loadTasks() {
    List<Map<String, dynamic>> savedTasks = [];
    for (var task in _taskBox.values) {
      savedTasks.add(Map<String, dynamic>.from(task));
    }
    studyTasks = savedTasks.reversed.toList();
    notifyListeners();
  }

  // Save tasks to Hive
  void saveTasks() {
    _taskBox.clear(); // Clear previous tasks
    for (var task in studyTasks) {
      _taskBox.add(task); // Save each task into Hive
    }
    notifyListeners();
  }

  // Create a new task
  void addTask(Map<String, dynamic> task) {
    studyTasks.add(task);
    saveTasks(); // Save to Hive after adding a new task
    notifyListeners();
  }

  // Read all tasks
  List<Map<String, dynamic>> getAllTasks() {
    return studyTasks.reversed.toList();
  }

  // Update a task
  void updateTask(String taskName, String newTaskName) {
    final index = studyTasks.indexWhere((task) => task['taskName'] == taskName);
    if (index != -1) {
      studyTasks[index]['taskName'] = newTaskName;
      studyTasks[index]['isUpdated'] = true;
      studyTasks[index]['dateTime'] = DateTime.now();
      saveTasks(); // Save updated tasks to Hive
      notifyListeners();
    }
  }

  // Toggle checked status of a task
  void toggleCheckedTask(String taskName, bool newValue) {
    final index = studyTasks.indexWhere((task) => task['taskName'] == taskName);
    if (index != -1) {
      studyTasks[index]['isChecked'] = newValue;
      saveTasks(); // Save updated tasks to Hive
      notifyListeners();
    }
  }

  // Delete a task
  void deleteTask(String taskName) {
    studyTasks.removeWhere((task) => task['taskName'] == taskName);
    saveTasks(); // Save updated tasks to Hive
    notifyListeners();
  }

  List<Map<String, dynamic>> searchTasksByName() {
    if (searchQuery.isNotEmpty) {
      return studyTasks.where((task) {
        return task['taskName']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      }).toList();
    }
    return studyTasks;
  }
}




