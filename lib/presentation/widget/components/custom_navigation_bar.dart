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
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50)
      ),
      child: CurvedNavigationBar(
        height: 55.0, // Height of the navigation bar
        backgroundColor: colorScheme.onPrimary,  // Background color for the navbar (transparent in this case)
        color: colorScheme.primary,  // Color for inactive icons
        buttonBackgroundColor: colorScheme.primary,  // Active color for the button (e.g. "Add" button)
        index: currentIndex,  // Set the active button based on the currentIndex
        items: <Widget>[
          Icon(Icons.search_rounded, size: 30, color: colorScheme.onPrimary),
          Icon(Icons.favorite_rounded, size: 30, color: colorScheme.onPrimary),
          Icon(Icons.home_rounded, size: 30, color: colorScheme.onPrimary),
          Icon(Icons.send_rounded, size: 30, color: colorScheme.onPrimary),
          Icon(Icons.settings_rounded, size: 30, color: colorScheme.onPrimary),
        ],
        onTap: onTap,  // Handle tap events using the provided callback
      ),
    );
  }
}
