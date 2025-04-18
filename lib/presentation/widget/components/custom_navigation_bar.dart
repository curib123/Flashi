import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  // Constructor with optional onTap parameter, defaulting to null
  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      child: CurvedNavigationBar(
        height: 60.0, // Height of the navigation bar
        backgroundColor: colorScheme.onPrimary, // Navbar background color
        color: colorScheme.primary.withOpacity(1), // Navbar color
        buttonBackgroundColor: colorScheme.primary, // Active button color
        index: currentIndex, // Current active index
        items: <Widget>[
          Icon(Icons.smart_toy_rounded, size: 30, color: colorScheme.onPrimary),
          Icon(Icons.layers_rounded, size: 40, color: colorScheme.onPrimary),
          Icon(Icons.text_snippet_rounded, size: 30, color: colorScheme.onPrimary),
        ],
        onTap: (index) {
          if (onTap != null) {
            onTap!(index); // Call the callback if it's not null
          }
        },
        letIndexChange: (index) {
          return true; // Allows index change; customize logic if needed  onTap!(index); // Call the callback if it's not null
        },
      )
    );
  }
}
