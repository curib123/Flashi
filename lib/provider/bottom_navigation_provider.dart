
import 'package:flashlearn/presentation/screen/main/note_screen.dart';
import 'package:flashlearn/presentation/screen/main/home_screen.dart';
import 'package:flashlearn/presentation/screen/main/pdf_extraction_screen.dart';
import 'package:flashlearn/presentation/screen/main/task_screen.dart';
import 'package:flashlearn/presentation/screen/main/text_reader_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier{

  final List<Widget> _screen = [

    TaskScreen(),
    TextReaderScreen(),
    HomeScreen(),
    PdfExtractionScreen(),
    NoteScreen(),
  ];

  int _currentIndex = 2;

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