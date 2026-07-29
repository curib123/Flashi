import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/util/helpers/classes/api/Trivia/fun_fact_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DailyQuestionProvider with ChangeNotifier {
  late final Box _chatBox;
  List<Map<String, String>> _funFacts = [];
  bool _isAlreadyShow = false;

  List<Map<String, String>> get funFacts => List.unmodifiable(_funFacts);
  bool get isAlreadyShow => _isAlreadyShow;

  DailyQuestionProvider() {
    _chatBox = Hive.box(
        'DailyQuestionProvider'); // Ensure the box is opened before using
    loadFunFacts(); // Load fun facts on initialization
  }

  // ✅ Show/hide fun facts
  void toggleFunFacts() {
    _isAlreadyShow = true;
    notifyListeners();
  }

  // ✅ Remove a specific fun fact by index
  void removeFunFactAt(int index) {
    if (index >= 0 && index < _funFacts.length) {
      _funFacts.removeAt(index);
      saveFunFacts(); // Update storage
      notifyListeners();
    }
  }

  // ✅ Generate and save fun facts to Hive
  Future<void> updateFunFacts(
      FetchDataFromJsonProvider fetchDataFromJsonProvider) async {
    List<Map<String, String>> facts = await TriviaGenerator.fetchTrivia();

    Future.delayed(const Duration(seconds: 5), () {
      if (facts.isNotEmpty) {
        _funFacts = List<Map<String, String>>.from(facts);
        saveFunFacts();
        notifyListeners();
      }
    });
  }

  // ✅ Save fun facts to Hive with proper type conversion
  void saveFunFacts() {
    _chatBox.put('DailyQuestionProvider',
        _funFacts.map((e) => e.cast<String, dynamic>()).toList());
  }

  // ✅ Load fun facts from Hive safely
  void loadFunFacts() {
    final storedData = _chatBox.get('DailyQuestionProvider', defaultValue: []);

    if (storedData is List) {
      _funFacts = storedData
          .whereType<Map<dynamic, dynamic>>() // Ensure only maps are processed
          .map((e) => Map<String, String>.from(e)) // Convert to correct type
          .toList();
    } else {
      _funFacts = [];
    }
    notifyListeners();
  }

  // ✅ Properly dispose of Hive box when provider is destroyed
}
