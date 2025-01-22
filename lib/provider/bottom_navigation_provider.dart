
import 'package:flashlearn/presentation/screen/main/note_screen.dart';
import 'package:flashlearn/presentation/screen/main/home_screen.dart';
import 'package:flashlearn/presentation/screen/main/study_scheduler_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier{

  final List<Widget> _screen = [
    NoteScreen(),
    HomeScreen(),
    StudySchedulerScreen(),
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