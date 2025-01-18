import 'package:flashlearn/util/helpers/list_default_sets.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

class QuizProvider with ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  final Box _settingsBox = Hive.box('quiz'); // Hive box for settings

  List<Map<String, dynamic>> _quizSets = []; // List of maps to store quiz sets
  String _searchQuery = ""; // Variable to store the search query
  String newValueCard = ""; // sort of cards
  String setValue = ""; // sort of cards
  int _defaultMaxCards = 20;
  String _currentQuizSetNameToSetLimit = '';


  int get defaultMaxCards => _defaultMaxCards;
  String get currentQuizSetNameToSetLimit => _currentQuizSetNameToSetLimit;

  QuizProvider({required String criterionSet,required String criterionCard }){
    loadQuizSets();
     sortQuizSets(criterionSet);
     toggleNewValueCard(criterionCard);

  }

  void loadQuizSets() {

    // Create an instance of ListDefaultSets and set the defaultMaxCards to 10
    var listDefaultSets = ListDefaultSets(defaultMaxCards);

    // Access the defaultValue and print it to see the result
    var defaultValue = listDefaultSets.defaultValue;

    var quizSetsFromStorage = _settingsBox.get('quizSets', defaultValue: defaultValue);

    if (quizSetsFromStorage is List) {
      _quizSets = List<Map<String, dynamic>>.from(
        quizSetsFromStorage.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else if (item is Map) {
            return Map<String, dynamic>.from(item);
          } else {
            return {};
          }
        }),
      );
    }
    notifyListeners();
  }



  void updateSetValue(String newValue){
     setValue = newValue;
    notifyListeners();
  }

  // Save quiz sets to Hive storage
  void saveQuizSets() {
    _settingsBox.put('quizSets', _quizSets);
    loadQuizSets();
  }

  // Getter for quiz sets and search query
  List<Map<String, dynamic>> get quizSets => _quizSets;
  String get searchQuery => _searchQuery;

  // Update the search query and notify listeners
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Get filtered quiz sets based on the search query
  List<Map<String, dynamic>> get filteredQuizSets {
    if (_searchQuery.isEmpty) {
      return _quizSets;
    } else {
      return _quizSets
          .where((set) => set['name']?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
          .toList();
    }
  }

  // Get filtered quiz sets that are marked as favorite
  List<Map<String, dynamic>> get filteredQuizSetsFavorite {
    return _quizSets
        .where((set) => set['favorite'] == true) // Ensure 'favorite' is true
        .toList();
  }



  // Sort quiz sets based on the criterion
  void sortQuizSets(String criterion) {
    if (criterion == 'Alphabetical') {
      _quizSets.sort((a, b) => (b['name'] ?? '').toLowerCase().compareTo((a['name'] ?? '').toLowerCase()));
    } else if (criterion == 'Number of Quizzes') {
      _quizSets.sort((a, b) => (a['numberOfQuiz'] ?? 0).compareTo(b['numberOfQuiz'] ?? 0));
    } else if (criterion == 'Reverse Alphabetical') {
      _quizSets.sort((a, b) => (a['name'] ?? '').toLowerCase().compareTo((b['name'] ?? '').toLowerCase()));
    } else if (criterion == 'Newest') {
      _quizSets.sort((a, b) => (a['timestamp'] ?? DateTime.now()).compareTo(b['timestamp'] ?? DateTime.now()));
    } else if (criterion == 'Oldest') {
      _quizSets.sort((a, b) => (b['timestamp'] ?? DateTime.now()).compareTo(a['timestamp'] ?? DateTime.now()));
    }

    notifyListeners();
  }

  // Sort quiz sets based on the criterion
  List<Map<String, dynamic>>  sortQuizCard({required final  List<Map<String, dynamic>> quizSet }) {
    String criterion = newValueCard;
    if (criterion == 'Alphabetical') {
      quizSet.sort((a, b) => (b['question'] ?? '').toLowerCase().compareTo((a['question'] ?? '').toLowerCase()));
    }  else if (criterion == 'Reverse Alphabetical') {
      quizSet.sort((a, b) => (a['question'] ?? '').toLowerCase().compareTo((b['question'] ?? '').toLowerCase()));
    } else if (criterion == 'Newest') {
      quizSet.sort((a, b) => (a['timestamp'] ?? DateTime.now()).compareTo(b['timestamp'] ?? DateTime.now()));
    } else if (criterion == 'Oldest') {
      quizSet.sort((a, b) => (b['timestamp'] ?? DateTime.now()).compareTo(a['timestamp'] ?? DateTime.now()));
    }

    return quizSet;

    notifyListeners();
  }

  //toggle sort card

  void toggleNewValueCard(String newValueCard){
    this.newValueCard = newValueCard;
    notifyListeners();
  }

  // Clear the input controllers
  void clearController() {
    nameController.clear();
    descriptionController.clear();
    questionController.clear();
    answerController.clear();
  }

  void addQuizSet(Map<String, dynamic> quizSet) {
    _quizSets.add(quizSet);
    saveQuizSets();
    clearController();
    notifyListeners();
  }

  // Toggle the favorite status of a quiz set
  void toggleFavorite(Map<String, dynamic> quizSet) {
    quizSet['favorite'] = !(quizSet['favorite'] ?? false);
    saveQuizSets();
    notifyListeners();
  }

  // Remove a quiz set and persist changes in Hive
  void removeQuizSet(Map<String, dynamic> quizSet) {
    _quizSets.removeWhere((set) => set['name'] == quizSet['name']);
    saveQuizSets();
    notifyListeners();
  }

  void updateCurrentQuizSetNameToSetLimit(String newCurrentQuizSetNameToSetLimit){
    _currentQuizSetNameToSetLimit = newCurrentQuizSetNameToSetLimit;
    notifyListeners();
  }

// Update the limitNumberOfQuiz by adding 1 to the previous value for a specific quiz set
  void updateQuizSetLimit() {
    // Fetch the quiz set using the provided quiz set name
    Map<String, dynamic>? quizSet = searchQuizSet(quizSetName: _currentQuizSetNameToSetLimit);

    // Check if the quiz set exists
    if (quizSet != null) {
      // Fetch the current limit and increment it by 1
      int currentLimit = quizSet['limitNumberOfQuiz'] ?? 0;  // Default to 0 if limitNumberOfQuiz doesn't exist
      quizSet['limitNumberOfQuiz'] = currentLimit + 5;

      // Save changes and notify listeners
      saveQuizSets();
      notifyListeners();
    }
  }



  // Get the number of cards in a specific quiz set
  int getNumberOfCardsInSet(String quizSetName) {
    Map<String, dynamic>? quizSet = searchQuizSet(quizSetName:quizSetName);
    return quizSet != null ? quizSet['cards']?.length ?? 0 : 0;
  }

  // Edit an existing quiz set and update it in Hive
  bool editQuizSet(String name, {String? newName, String? newDescription}) {
    for (Map<String, dynamic> quizSet in _quizSets) {
      if (quizSet['name'] == name) {
        if (newName != null) quizSet['name'] = newName;
        if (newDescription != null) quizSet['description'] = newDescription;
        quizSet['timestamp'] = DateTime.now();
        saveQuizSets();
        clearController();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Search for a quiz set by its name
  Map<String, dynamic>? searchQuizSet({required String quizSetName}) {
    try {
      return _quizSets.firstWhere((quizSet) => quizSet['name'] == quizSetName);
    } catch (e) {
      return null;
    }
  }

  bool addCardToQuizSet({
    required String quizSetName,
    required dynamic card, // Allow both types
  }) {
    // Ensure the card is of the type Map<String, Object> or Map<String, dynamic>
    if (card is Map<String, dynamic>) {
      // Handle when the card is of type Map<String, Object>
      return addCardToQuizSetNew(quizSetName: quizSetName, card: card);
    } else if (card is Map<String, Object>) {
      // Handle when the card is of type Map<String, dynamic>
      return addCardToQuizSetTemplate(quizSetName: quizSetName, card: card);
    } else {

      return false;
    }
  }

  // Add a card to a specific quiz set and update it in Hive
  bool addCardToQuizSetNew({required String quizSetName, required Map<String, dynamic> card}) {
    Map<String, dynamic>? quizSet = searchQuizSet(quizSetName: quizSetName);
    if (quizSet != null) {
      // Initialize the 'cards' list if it doesn't exist
      if (quizSet['cards'] == null) {
        quizSet['cards'] = [];
      }

      // Check if the number of cards exceeds the limit
      int limitNumberOfQuiz = quizSet['limitNumberOfQuiz'] ?? 0;
      int currentNumberOfCards = quizSet['cards']?.length ?? 0;

      if (limitNumberOfQuiz > 0 && currentNumberOfCards >= limitNumberOfQuiz) {

        return false; // Reject the addition if the limit is reached
      }

      // Add the card
      quizSet['cards']?.add(card);
      quizSet['numberOfQuiz'] = (quizSet['cards']?.length ?? 0);
      saveQuizSets();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool addCardToQuizSetTemplate({
    required String quizSetName,
    required Map<String, Object> card, // Ensure the card matches the expected type
  }) {
    // Retrieve the quiz set
    Map<String, dynamic>? quizSet = searchQuizSet(quizSetName: quizSetName);
    if (quizSet != null) {
      // Initialize the 'cards' list if it doesn't exist
      if (quizSet['cards'] == null) {
        quizSet['cards'] = <Map<String, Object>>[];
      }

      // Type-check the 'cards' list
      if (quizSet['cards'] is! List<Map<String, Object>>) {
        debugPrint('The cards field is not a list of maps. Aborting.');
        return false;
      }

      List<Map<String, Object>> cards = quizSet['cards'] as List<Map<String, Object>>;

      // Check if the number of cards exceeds the limit
      int limitNumberOfQuiz = quizSet['limitNumberOfQuiz'] ?? 0;
      int currentNumberOfCards = cards.length;

      if (limitNumberOfQuiz > 0 && currentNumberOfCards >= limitNumberOfQuiz) {
        debugPrint(
            'Cannot add more cards. Limit of $limitNumberOfQuiz cards reached for $quizSetName.');
        return false; // Reject the addition if the limit is reached
      }

      // Add the card
      cards.add(card);
      quizSet['cards'] = cards; // Reassign after modification to avoid implicit casting issues
      quizSet['numberOfQuiz'] = cards.length;

      saveQuizSets(); // Save changes
      notifyListeners();
      return true;
    }
    return false;
  }


  // Remove a card from a specific quiz set by its question
  bool removeCardFromQuizSet({required String quizSetName, required String question}) {
    Map<String, dynamic>? quizSet = searchQuizSet(quizSetName :quizSetName);
    if (quizSet != null) {
      int cardIndex = quizSet['cards']?.indexWhere((card) => card['question'] == question) ?? -1;
      if (cardIndex != -1) {
        quizSet['cards']?.removeAt(cardIndex);
        quizSet['numberOfQuiz'] = quizSet['cards']?.length ?? 0;
        saveQuizSets();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Toggle the 'isIgnore' status of a quiz set by its name
  bool toggleIgnore({required String quizSetName,required bool isIgnore,required String question}) {
    Map<String, dynamic>? quizSet = searchQuizSet(quizSetName:quizSetName);
    print(  quizSet?['cards']);
    if (quizSet != null) {
      int cardIndex = quizSet['cards']?.indexWhere((card) => card['question'] == question) ?? -1;
      quizSet['cards']?[cardIndex]['isIgnore'] = ! quizSet['cards']?[cardIndex]['isIgnore'];
      saveQuizSets();
      print(quizSet['isIgnore']);
      notifyListeners();
      return true;
    }
    return false;
  }


  // Update the values inside a card in a specific quiz set
  bool updateCardInQuizSet({required String quizSetName,required String oldQuestion,required String newQuestion,required String newAnswer}) {
    Map<String, dynamic>? quizSet = searchQuizSet(quizSetName:quizSetName);
    if (quizSet != null) {
      int cardIndex = quizSet['cards']?.indexWhere((card) => card['question'] == oldQuestion) ?? -1;
      if (cardIndex != -1) {
        quizSet['cards']?[cardIndex]['question'] = newQuestion;
        quizSet['cards']?[cardIndex]['isUpdating'] = true;
        quizSet['cards']?[cardIndex]['answer'] = newAnswer;
        quizSet['cards']?[cardIndex]['timestamp'] = DateTime.now();
        quizSet['numberOfQuiz'] = quizSet['cards']?.length ?? 0;
        saveQuizSets();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Show all quiz sets
  List<Map<String, dynamic>> showAllQuizSets() {
    return _quizSets;
  }

  // Show all cards in a specific quiz set
  List<Map<String, dynamic>>? showAllCardsInSet(String quizSetName) {
    Map<String, dynamic>? quizSet = searchQuizSet(quizSetName:quizSetName);
    return quizSet != null ? List<Map<String, dynamic>>.from(quizSet['cards'] ?? []) : null;
  }
}
