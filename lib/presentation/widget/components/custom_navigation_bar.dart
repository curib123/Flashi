import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {

  final int currentIndex;
  final Function(int)? onTap;

  const CustomNavigationBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.primaryFixed,
      iconSize: 30,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const <BottomNavigationBarItem> [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home"
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: "Search"
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: "Favorate"
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: "Settings"
        ),
      ],
    );
  }
}
