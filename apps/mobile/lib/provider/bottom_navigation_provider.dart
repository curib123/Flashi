import 'package:flashi/presentation/screen/main/history_screen.dart';
import 'package:flashi/presentation/screen/main/home_screen.dart';
import 'package:flashi/presentation/screen/main/library_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier {
  static const List<Widget> _screens = [
    HomeScreen(),
    LibraryScreen(),
    HistoryScreen(),
  ];

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (index < 0 || index >= _screens.length || index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }

  void toogleNavigation(int index) => setIndex(index);

  Widget getScreen() => _screens[_currentIndex];
}
