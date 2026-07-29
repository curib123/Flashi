import 'package:flashi/shared/state/persisted_content_provider.dart';

class HistoryProvider extends PersistedContentProvider {
  HistoryProvider({super.box})
      : super(boxName: 'history', storageKey: 'history');

  List<Map<String, dynamic>> get history => items;

  void updateHistory(
    List<Map<String, dynamic>> newHistory, {
    required bool merge,
  }) =>
      updateItems(newHistory, merge: merge);

  void onSearchChanged(String value) => updateSearchQuery(value);
  List<Map<String, dynamic>> filterHistory() => filteredItems();
  List<Map<String, dynamic>> filterFavorite() => favoriteItems();
  void addHistory(Map<String, dynamic> historyItem) => addItem(historyItem);
  void editHistoryByTitle(
    String title,
    Map<String, dynamic> updatedHistoryItem,
  ) =>
      editItemByTitle(title, updatedHistoryItem);
  void deleteHistoryByTitle(String title) => deleteItemByTitle(title);
  List<Map<String, dynamic>> searchHistoryByTitle(String query) =>
      searchByTitle(query);
}
