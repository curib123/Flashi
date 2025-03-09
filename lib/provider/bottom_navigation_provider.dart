
import 'package:flashi/presentation/screen/main/chat_bot_screen.dart';
import 'package:flashi/presentation/screen/main/note_screen.dart';
import 'package:flashi/presentation/screen/main/home_screen.dart';
import 'package:flashi/presentation/screen/main/redeem_screen.dart';
import 'package:flashi/presentation/screen/main/rewards_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier{

  final List<Widget> _screen = [
    ChatBotScreen(),
    NoteScreen(),
    HomeScreen(),
    RewardsScreen(),
    RedeemScreen(),

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