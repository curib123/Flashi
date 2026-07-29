import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SortProvider extends ChangeNotifier {
  SortProvider({Box<dynamic>? box}) : _box = box ?? Hive.box<dynamic>('sort') {
    _setSort = _readString('selectedSortSet', 'Newest');
    _cardSort = _readString('selectedSortCard', 'Newest');
    _noteLayout = _readString('selectedSortNote', 'Blocks');
    _taskLayout = _readString('dropdownValueTask', 'Tiles');
    _pdfLayout = _readString(
      'selectedSortPdf',
      _readString('dropdownValuePdf', 'Blocks'),
    );
  }

  static const List<String> setSortOptions = [
    'Newest',
    'Oldest',
    'Alphabetical',
    'Reverse Alphabetical',
    'Number of Quizzes',
  ];
  static const List<String> cardSortOptions = [
    'Newest',
    'Oldest',
    'Alphabetical',
    'Reverse Alphabetical',
  ];
  static const List<String> layoutOptions = ['Tiles', 'Blocks'];

  final Box<dynamic> _box;
  late String _setSort;
  late String _cardSort;
  late String _noteLayout;
  late String _taskLayout;
  late String _pdfLayout;

  String get dropdownValueSet => _setSort;
  String get dropdownValueCard => _cardSort;
  String get dropdownValueNote => _noteLayout;
  String get dropdownValueTask => _taskLayout;
  String get dropdownValuePdf => _pdfLayout;

  List<String> get sortOptionsSet => setSortOptions;
  List<String> get sortOptionsCard => cardSortOptions;
  List<String> get sortOptionsNote => layoutOptions;
  List<String> get sortOptionsTask => layoutOptions;
  List<String> get sortOptionsPdf => layoutOptions;

  void updateSortValueSet(String value) {
    if (_setSort == value) return;
    _setSort = value;
    _persist('selectedSortSet', value);
  }

  void updateSortValueCard(String value) {
    if (_cardSort == value) return;
    _cardSort = value;
    _persist('selectedSortCard', value);
  }

  void updateSortValueNote(String value) {
    if (_noteLayout == value) return;
    _noteLayout = value;
    _persist('selectedSortNote', value);
  }

  void updateSortValueTask(String value) {
    if (_taskLayout == value) return;
    _taskLayout = value;
    _persist('dropdownValueTask', value);
  }

  void updateSortValuePdf(String value) {
    if (_pdfLayout == value) return;
    _pdfLayout = value;
    _persist('selectedSortPdf', value);
  }

  String _readString(String key, String fallback) =>
      _box.get(key, defaultValue: fallback) as String;

  void _persist(String key, String value) {
    _box.put(key, value);
    notifyListeners();
  }
}
