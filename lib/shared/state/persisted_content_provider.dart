import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

abstract class PersistedContentProvider extends ChangeNotifier {
  PersistedContentProvider({
    required String boxName,
    required String storageKey,
    Box<dynamic>? box,
  })  : _box = box ?? Hive.box<dynamic>(boxName),
        _storageKey = storageKey {
    _load();
  }

  final Box<dynamic> _box;
  final String _storageKey;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _publishedItems = const [];
  String _searchQuery = '';

  List<Map<String, dynamic>> get items => _publishedItems;
  String get searchQuery => _searchQuery;

  void updateItems(
    List<Map<String, dynamic>> newItems, {
    required bool merge,
  }) {
    var changed = false;
    if (merge) {
      final existingKeys = _items.map(_identityKey).toSet();
      for (final item in newItems) {
        if (existingKeys.add(_identityKey(item))) {
          _items.add(Map<String, dynamic>.from(item));
          changed = true;
        }
      }
    } else {
      _items = _deduplicate(newItems);
      changed = true;
    }
    if (changed) _commit();
  }

  void updateSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> filteredItems() {
    if (_searchQuery.isNotEmpty) {
      final normalizedQuery = _searchQuery.toLowerCase();
      return _publishedItems
          .where(
            (item) => _titleOf(item).toLowerCase().contains(normalizedQuery),
          )
          .toList(growable: false);
    }

    final result = _publishedItems
        .where((item) => item['created_at'] != null)
        .toList(growable: false);
    result.sort(
      (a, b) =>
          (b['created_at'] as DateTime).compareTo(a['created_at'] as DateTime),
    );
    return result;
  }

  List<Map<String, dynamic>> favoriteItems() => _publishedItems
      .where((item) => item['favorite'] == true)
      .toList(growable: false);

  List<Map<String, dynamic>> searchByTitle(String query) {
    final normalizedQuery = query.toLowerCase();
    return _publishedItems
        .where(
          (item) => _titleOf(item).toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  void addItem(Map<String, dynamic> item) {
    _items.add(Map<String, dynamic>.from(item));
    _commit();
  }

  void editItemByTitle(String title, Map<String, dynamic> updatedItem) {
    final index = _items.indexWhere((item) => _titleOf(item) == title);
    if (index == -1) return;
    _items[index] = Map<String, dynamic>.from(updatedItem);
    _commit();
  }

  void toggleFavoriteByTitle(String title) {
    final index = _items.indexWhere((item) => _titleOf(item) == title);
    if (index == -1) return;
    final item = Map<String, dynamic>.from(_items[index]);
    item['favorite'] = !(item['favorite'] == true);
    _items[index] = item;
    _commit();
  }

  void deleteItemByTitle(String title) {
    final index = _items.indexWhere((item) => _titleOf(item) == title);
    if (index == -1) return;
    _items.removeAt(index);
    _commit();
  }

  void reload() {
    _load();
    notifyListeners();
  }

  void _load() {
    final storedItems = _box.get(_storageKey, defaultValue: const []);
    if (storedItems is List) {
      _items = storedItems
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } else {
      _items = [];
    }
    _publish();
  }

  void _commit() {
    _publish();
    _box.put(_storageKey, _items);
    notifyListeners();
  }

  void _publish() {
    _publishedItems = List.unmodifiable(
      _items.map((item) => Map<String, dynamic>.unmodifiable(item)),
    );
  }

  List<Map<String, dynamic>> _deduplicate(
    List<Map<String, dynamic>> values,
  ) {
    final keys = <String>{};
    return [
      for (final item in values)
        if (keys.add(_identityKey(item))) Map<String, dynamic>.from(item),
    ];
  }

  String _identityKey(Map<String, dynamic> item) =>
      '${item['id']}-${_titleOf(item)}';

  String _titleOf(Map<String, dynamic> item) =>
      (item['title'] ?? '').toString();

  @override
  void dispose() {
    searchController.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
