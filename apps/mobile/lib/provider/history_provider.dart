import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HistoryProvider with ChangeNotifier {
  // Box for storing history
  final Box _quizBox = Hive.box('history');

  // Initial sample data (use a regular variable instead of final)
  List<Map<String, dynamic>> _history = [];

  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  // Getter for history list
  List<Map<String, dynamic>> get history => _history;

  // Search query
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  // Constructor
  HistoryProvider() {
    loadHistoryHive();  // Load history when the provider is initialized
  }

  void updateHistory(List<Map<String, dynamic>> newHistory, {required bool merge}) {
    if (merge) {
      // Maintain a set to track unique entries based on both ID and title
      Set<String> existingKeys = _history.map((e) => "${e["id"]}-${e["title"]}").toSet();

      for (var newHistoryItem in newHistory) {
        String key = "${newHistoryItem["id"]}-${newHistoryItem["title"]}";
        if (!existingKeys.contains(key)) {
          _history.add(newHistoryItem);
          existingKeys.add(key);
        }
      }
    } else {
      // Directly replace existing history with the new ones
      _history = List.from(newHistory);
    }

    notifyListeners();
    saveHistoryHive();
  }

  // Method to handle search query change
  void onSearchChanged(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> filterHistory() {
    if (_searchQuery.isEmpty) {
      // Filter by timestamp when search query is empty
      return _history
          .where((historyItem) => historyItem['created_at'] != null) // Ensure the timestamp is not null
          .toList()
        ..sort((a, b) => b['created_at'].compareTo(a['created_at'])); // Sort by timestamp in descending order
    } else {
      // Filter by title when search query is not empty
      return _history
          .where((historyItem) => historyItem['title'].toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  List<Map<String, dynamic>> filterFavorite() {
    return _history.where((historyItem) {
      return historyItem['favorite'] == true; // Check if the history item is marked as favorite
    }).toList();
  }

  // Add a new history item
  void addHistory(Map<String, dynamic> historyItem) {
    _history.add(historyItem);
    saveHistoryHive();  // Save to Hive after adding a history item
    notifyListeners();
  }

  // Edit a history item by title
  void editHistoryByTitle(String title, Map<String, dynamic> updatedHistoryItem) {
    final index = _history.indexWhere((historyItem) => historyItem['title'] == title);
    if (index != -1) {
      _history[index] = updatedHistoryItem;
      saveHistoryHive();  // Save to Hive after editing a history item
      notifyListeners();
    }
  }

  // Toggle favorite status of a history item by title
  void toggleFavoriteByTitle(String title) {
    final index = _history.indexWhere((historyItem) => historyItem['title'] == title);
    if (index != -1) {
      _history[index]['favorite'] = !_history[index]['favorite'];
      saveHistoryHive();  // Save to Hive after toggling favorite status
      notifyListeners();
    }
  }

  // Delete a history item by title
  void deleteHistoryByTitle(String title) {
    final index = _history.indexWhere((historyItem) => historyItem['title'] == title);
    if (index != -1) {
      _history.removeAt(index);
      saveHistoryHive();  // Save to Hive after deleting a history item
      notifyListeners();
    }
  }

  // Search history items by title (case-insensitive)
  List<Map<String, dynamic>> searchHistoryByTitle(String query) {
    return _history.where((historyItem) {
      return historyItem['title'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Load history from Hive storage
  void loadHistoryHive() {
    var historyFromStorage = _quizBox.get('history', defaultValue: []);

    if (historyFromStorage is List) {
      _history = List<Map<String, dynamic>>.from(
        historyFromStorage.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else if (item is Map) {
            return Map<String, dynamic>.from(item);
          } else {
            return {};
          }
        }),
      );
    }
    notifyListeners();
  }

  // Save the current history list to Hive storage
  void saveHistoryHive() {
    _quizBox.put('history', _history);  // Save the entire list to Hive
    loadHistoryHive();
  }
}
