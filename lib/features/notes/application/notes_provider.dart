import 'package:flashi/shared/state/persisted_content_provider.dart';

class NotesProvider extends PersistedContentProvider {
  NotesProvider({super.box}) : super(boxName: 'notes', storageKey: 'notes');

  List<Map<String, dynamic>> get notes => items;

  void updateNotes(
    List<Map<String, dynamic>> newNotes, {
    required bool merge,
  }) =>
      updateItems(newNotes, merge: merge);

  void onSearchChanged(String value) => updateSearchQuery(value);
  List<Map<String, dynamic>> filterNotes() => filteredItems();
  List<Map<String, dynamic>> filterFavorite() => favoriteItems();

  void addNote(Map<String, dynamic> note) => addItem(note);
  void editNoteByTitle(String title, Map<String, dynamic> updatedNote) =>
      editItemByTitle(title, updatedNote);
  void deleteNoteByTitle(String title) => deleteItemByTitle(title);
  List<Map<String, dynamic>> searchNotesByTitle(String query) =>
      searchByTitle(query);
}
