import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Function()? onTap;
  final String name;
  final Color color;
  final IconData icon;

  const AppButton({
    super.key,
    this.onTap,
    required this.name,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 8, horizontal: 15), // Consistent padding
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 25,
              color: colorScheme.onPrimary, // Icon color based on theme
            ),
            const SizedBox(width: 10),
            Text(
              name,
              style: TextStyle(
                color: colorScheme.onPrimary, // Text color based on theme
                fontSize: 16, // Moderate text size for clarity
                fontWeight:
                    FontWeight.w600, // Semi-bold text for better visibility
              ),
            ),
          ],
        ),
      ),
    );
  }
}
