import 'package:flutter/material.dart';

class NotesProvider with ChangeNotifier {
  // Initial sample data
  final List<Map<String, dynamic>> _notes = [
    {'title': 'Meeting Notes', 'content': 'Discuss project status', 'date_created': DateTime.now().subtract(Duration(days: 1)), 'favorite': true},
    {'title': 'Shopping List', 'content': 'Buy groceries', 'date_created': DateTime.now().subtract(Duration(days: 2)), 'favorite': false},
  ];

  // Getter for notes list
  List<Map<String, dynamic>> get notes => _notes;

  // Add a new note
  void addNote(Map<String, dynamic> note) {
    _notes.add(note);
    notifyListeners();
  }

  // Edit a note by title
  void editNoteByTitle(String title, Map<String, dynamic> updatedNote) {
    final index = _notes.indexWhere((note) => note['title'] == title);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  // Toggle favorite status of a note by title
  void toggleFavoriteByTitle(String title) {
    final index = _notes.indexWhere((note) => note['title'] == title);
    if (index != -1) {
      _notes[index]['favorite'] = !_notes[index]['favorite'];
      notifyListeners();
    }
  }

  // Delete a note by title
  void deleteNoteByTitle(String title) {
    final index = _notes.indexWhere((note) => note['title'] == title);
    if (index != -1) {
      _notes.removeAt(index);
      notifyListeners();
    }
  }

  // Search notes by title (case-insensitive)
  List<Map<String, dynamic>> searchNotesByTitle(String query) {
    return _notes.where((note) {
      return note['title'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }


}
