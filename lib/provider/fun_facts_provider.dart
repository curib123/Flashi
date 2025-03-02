import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/util/helpers/classes/api/Trivia/fun_fact_generator.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FunFactsProvider with ChangeNotifier {
  late final Box _chatBox;
  List<String> _funFacts = [];
  bool _isAlreadyShow = false;

  List<String> get funFacts => _funFacts;
  bool get isAlreadyShow => _isAlreadyShow;

  FunFactsProvider() {
    _chatBox = Hive.box('funFacts'); // Ensure the box is opened before using
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
  // ✅ Update fun facts only if not empty
  Future<void> updateFunFacts(FetchDataFromJsonProvider fetchDataFromJsonProvider) async {
    List<String> facts = await TriviaGenerator.fetchTrivia();

 Future.delayed(Duration(seconds: 5),(){
   if (facts.isNotEmpty) {
     _funFacts = facts;
     saveFunFacts();
     notifyListeners();
   }
 });
  }

  // ✅ Save fun facts to Hive
  void saveFunFacts() {
    _chatBox.put('savedFunFacts', _funFacts);
  }

  // ✅ Load fun facts from Hive with proper type handling
  void loadFunFacts() {
    final storedData = _chatBox.get('savedFunFacts', defaultValue: []);
    _funFacts = storedData is List ? List<String>.from(storedData) : [];
    notifyListeners();
  }

  // ✅ Properly dispose of Hive box when provider is destroyed
  @override
  void dispose() {
    _chatBox.close(); // Close the Hive box to free resources
    super.dispose();
  }
}
