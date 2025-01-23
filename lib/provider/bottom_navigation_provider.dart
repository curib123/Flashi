
import 'package:flashlearn/presentation/screen/main/note_screen.dart';
import 'package:flashlearn/presentation/screen/main/home_screen.dart';
import 'package:flashlearn/presentation/screen/main/task_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier{

  final List<Widget> _screen = [

    TaskScreen(),
    HomeScreen(),
    NoteScreen(),
  ];

  int _currentIndex = 1;

  get currentIndex => _currentIndex;
  get screen => _screen;

  void toogleNavigation(int index){
    _currentIndex = index;
    notifyListeners();
  }

  Widget getScreen(){
    return screen[currentIndex];
  }
}