import 'dart:async';
import 'dart:collection';

import 'package:flashi/util/helpers/classes/api/Trivia/fun_fact_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DailyQuestionProvider extends ChangeNotifier {
  DailyQuestionProvider() : _box = Hive.box<dynamic>('DailyQuestionProvider') {
    _load();
  }

  final Box<dynamic> _box;
  List<Map<String, String>> _funFacts = [];
  bool _isAlreadyShown = false;
  bool _isDisposed = false;
  Timer? _updateTimer;

  List<Map<String, String>> get funFacts => UnmodifiableListView(
        _funFacts.map(UnmodifiableMapView.new),
      );
  bool get isAlreadyShow => _isAlreadyShown;

  void toggleFunFacts() {
    if (_isAlreadyShown) return;
    _isAlreadyShown = true;
    notifyListeners();
  }

  void removeFunFactAt(int index) {
    if (index < 0 || index >= _funFacts.length) return;
    _funFacts.removeAt(index);
    _save();
    notifyListeners();
  }

  Future<void> updateFunFacts() async {
    final facts = await TriviaGenerator.fetchTrivia();
    if (_isDisposed || facts.isEmpty) return;

    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(seconds: 5), () {
      if (_isDisposed) return;
      _funFacts = facts.map(Map<String, String>.from).toList();
      _save();
      notifyListeners();
    });
  }

  void _save() {
    _box.put(
      'DailyQuestionProvider',
      _funFacts.map((item) => item.cast<String, dynamic>()).toList(),
    );
  }

  void _load() {
    final storedData = _box.get(
      'DailyQuestionProvider',
      defaultValue: const [],
    );
    if (storedData is! List) return;
    _funFacts = storedData
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => Map<String, String>.from(item))
        .toList();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _updateTimer?.cancel();
    super.dispose();
  }
}
