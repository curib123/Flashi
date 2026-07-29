import 'package:flashi/features/chat/presentation/pages/chat_page.dart';
import 'package:flashi/features/notes/presentation/pages/notes_page.dart';
import 'package:flashi/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';

class AppNavigationProvider extends ChangeNotifier {
  static const List<Widget> _screens = [
    ChatPage(),
    DashboardPage(),
    NotesPage(),
  ];

  int _currentIndex = 1;

  int get currentIndex => _currentIndex;

  Widget get currentScreen => _screens[_currentIndex];

  void selectDestination(int index) {
    if (index == _currentIndex || index < 0 || index >= _screens.length) return;
    _currentIndex = index;
    notifyListeners();
  }

  @Deprecated('Use selectDestination instead.')
  void toogleNavigation(int index) => selectDestination(index);

  Widget getScreen() {
    return currentScreen;
  }
}
