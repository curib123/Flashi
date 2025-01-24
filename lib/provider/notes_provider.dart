import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class NotesProvider with ChangeNotifier {
  // Box for storing notes
  final Box _quizBox = Hive.box('notes');

  // Initial sample data (use a regular variable instead of final)
  List<Map<String, dynamic>> _notes = [];

  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  // Getter for notes list
  List<Map<String, dynamic>> get notes => _notes;

  // Search query
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  // Constructor
  NotesProvider() {
    loadNotesHive();  // Load notes when the provider is initialized
  }

  // Method to handle search query change
  void onSearchChanged(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  // Method to filter note list by title
  List<Map<String, dynamic>> filterNotesByTitle() {
    return _notes
        .where((note) => note['title'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }


  List<Map<String, dynamic>> filterFavorate() {
    return _notes.where((note) {
      return note['favorite'] == true; // Check if the note is marked as favorite
    }).toList();
  }


  // Add a new note
  void addNote(Map<String, dynamic> note) {
    _notes.add(note);
    saveNotesHive();  // Save to Hive after adding a note
    notifyListeners();
  }

  // Edit a note by title
  void editNoteByTitle(String title, Map<String, dynamic> updatedNote) {
    final index = _notes.indexWhere((note) => note['title'] == title);
    if (index != -1) {
      _notes[index] = updatedNote;
      saveNotesHive();  // Save to Hive after editing a note
      notifyListeners();
    }
  }

  // Toggle favorite status of a note by title
  void toggleFavoriteByTitle(String title) {
    final index = _notes.indexWhere((note) => note['title'] == title);
    if (index != -1) {
      _notes[index]['favorite'] = !_notes[index]['favorite'];
      saveNotesHive();  // Save to Hive after toggling favorite status
      notifyListeners();
    }
  }

  // Delete a note by title
  void deleteNoteByTitle(String title) {
    final index = _notes.indexWhere((note) => note['title'] == title);
    if (index != -1) {
      _notes.removeAt(index);
      saveNotesHive();  // Save to Hive after deleting a note
      notifyListeners();
    }
  }

  // Search notes by title (case-insensitive)
  List<Map<String, dynamic>> searchNotesByTitle(String query) {
    return _notes.where((note) {
      return note['title'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Load notes from Hive storage
  void loadNotesHive() {
    var notesFromStorage = _quizBox.get('notes', defaultValue: []);

    if (notesFromStorage is List) {
      _notes = List<Map<String, dynamic>>.from(
        notesFromStorage.map((item) {
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

  // Save the current notes list to Hive storage
  void saveNotesHive() {
    _quizBox.put('notes', _notes);  // Save the entire list to Hive
    loadNotesHive();
  }
}
