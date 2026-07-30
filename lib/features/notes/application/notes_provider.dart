import 'package:flashi/shared/state/persisted_content_provider.dart';

class NotesProvider extends PersistedContentProvider {
  NotesProvider({super.box}) : super(boxName: 'notes', storageKey: 'notes');

  String? _cachedQuery;
  List<Map<String, dynamic>>? _cachedResults;

  List<Map<String, dynamic>> get notes => items;

  void updateNotes(
    List<Map<String, dynamic>> newNotes, {
    required bool merge,
  }) {
    _clearNoteSearchCache();
    updateItems(newNotes, merge: merge);
  }

  void onSearchChanged(String value) {
    if (value != searchQuery) _clearNoteSearchCache();
    updateSearchQuery(value);
  }

  List<Map<String, dynamic>> filterNotes() {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return filteredItems();
    if (_cachedQuery == query && _cachedResults != null) {
      return _cachedResults!;
    }

    final matches = notes.where((note) {
      final title = (note['title'] ?? '').toString().toLowerCase();
      final content = (note['content'] ?? '').toString().toLowerCase();
      return title.contains(query) || content.contains(query);
    }).toList()
      ..sort((a, b) {
        final first = a['created_at'];
        final second = b['created_at'];
        if (first is! DateTime || second is! DateTime) return 0;
        return second.compareTo(first);
      });
    _cachedQuery = query;
    return _cachedResults = List.unmodifiable(matches);
  }

  List<Map<String, dynamic>> filterFavorite() => favoriteItems();

  void addNote(Map<String, dynamic> note) {
    _clearNoteSearchCache();
    addItem(note);
  }

  void editNoteByTitle(String title, Map<String, dynamic> updatedNote) {
    _clearNoteSearchCache();
    editItemByTitle(title, updatedNote);
  }

  void deleteNoteByTitle(String title) {
    _clearNoteSearchCache();
    deleteItemByTitle(title);
  }

  @override
  void toggleFavoriteByTitle(String title) {
    _clearNoteSearchCache();
    super.toggleFavoriteByTitle(title);
  }

  List<Map<String, dynamic>> searchNotesByTitle(String query) =>
      searchByTitle(query);

  Map<String, dynamic>? noteByTitle(String title) {
    for (final note in notes) {
      if (note['title'] == title) return note;
    }
    return null;
  }

  bool hasNoteTitle(String title, {String? excludingTitle}) {
    final normalized = title.trim().toLowerCase();
    return notes.any((note) {
      final existing = (note['title'] ?? '').toString();
      return existing != excludingTitle &&
          existing.trim().toLowerCase() == normalized;
    });
  }

  void _clearNoteSearchCache() {
    _cachedQuery = null;
    _cachedResults = null;
  }
}
