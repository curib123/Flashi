import 'package:flutter/foundation.dart';

class AppNavigationProvider extends ChangeNotifier {
  AppNavigationProvider({int initialIndex = 1})
      : assert(initialIndex >= 0 && initialIndex < destinationCount),
        _currentIndex = initialIndex;

  static const int destinationCount = 3;
  int _currentIndex;

  int get currentIndex => _currentIndex;

  void selectDestination(int index) {
    if (index == _currentIndex || index < 0 || index >= destinationCount) {
      return;
    }
    _currentIndex = index;
    notifyListeners();
  }
}
