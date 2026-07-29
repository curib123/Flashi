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
  List<Map<String, dynamic>> _chronologicalItems = const [];
  List<Map<String, dynamic>> _favoriteItems = const [];
  List<Map<String, dynamic>>? _filteredItems;
  String? _filteredQuery;
  final Map<String, int> _titleIndex = {};
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
    _filteredItems = null;
    _filteredQuery = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> filteredItems() {
    if (_searchQuery.isNotEmpty) {
      if (_filteredQuery == _searchQuery && _filteredItems != null) {
        return _filteredItems!;
      }
      final normalizedQuery = _searchQuery.toLowerCase();
      _filteredQuery = _searchQuery;
      _filteredItems = List.unmodifiable(
        _publishedItems
            .where(
              (item) => _titleOf(item).toLowerCase().contains(normalizedQuery),
            )
            .toList(growable: false),
      );
      return _filteredItems!;
    }

    return _chronologicalItems;
  }

  List<Map<String, dynamic>> favoriteItems() => _favoriteItems;

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
    final index = _titleIndex[title];
    if (index == null) return;
    _items[index] = Map<String, dynamic>.from(updatedItem);
    _commit();
  }

  void toggleFavoriteByTitle(String title) {
    final index = _titleIndex[title];
    if (index == null) return;
    final item = Map<String, dynamic>.from(_items[index]);
    item['favorite'] = !(item['favorite'] == true);
    _items[index] = item;
    _commit();
  }

  void deleteItemByTitle(String title) {
    final index = _titleIndex[title];
    if (index == null) return;
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
    _titleIndex.clear();
    for (var index = 0; index < _items.length; index++) {
      _titleIndex.putIfAbsent(_titleOf(_items[index]), () => index);
    }

    final chronologicalItems = _publishedItems
        .where((item) => item['created_at'] is DateTime)
        .toList(growable: false)
      ..sort(
        (a, b) => (b['created_at'] as DateTime)
            .compareTo(a['created_at'] as DateTime),
      );
    _chronologicalItems = List.unmodifiable(chronologicalItems);
    _favoriteItems = List.unmodifiable(
      _publishedItems.where((item) => item['favorite'] == true),
    );
    _filteredItems = null;
    _filteredQuery = null;
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
