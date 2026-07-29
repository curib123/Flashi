import 'package:flashi/features/chat/presentation/pages/chat_page.dart';
import 'package:flashi/features/notes/presentation/pages/notes_page.dart';
import 'package:flashi/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier {
  final List<Widget> _screen = [
    const ChatPage(),
    const DashboardPage(),
    const NotesPage(),
  ];

  int _currentIndex = 1;

  get currentIndex => _currentIndex;
  get screen => _screen;

  void toogleNavigation(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Widget getScreen() {
    return screen[currentIndex];
  }
}
