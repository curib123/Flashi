import 'package:flashi/presentation/screen/main/chat_bot_screen.dart';
import 'package:flashi/presentation/screen/main/home_screen.dart';
import 'package:flashi/presentation/screen/main/note_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier {
  static const List<Widget> _screens = [
    ChatBotScreen(),
    HomeScreen(),
    NoteScreen(),
  ];

  int _currentIndex = 1;

  int get currentIndex => _currentIndex;
  List<Widget> get screens => _screens;

  void setIndex(int index) {
    if (index < 0 || index >= _screens.length || index == _currentIndex) {
      return;
    }

    _currentIndex = index;
    notifyListeners();
  }

  // Kept for compatibility with existing call sites.
  void toogleNavigation(int index) => setIndex(index);

  Widget getScreen() => _screens[_currentIndex];
}
