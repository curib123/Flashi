import 'package:flashi/features/favorites/presentation/pages/favorites_page.dart';
import 'package:flutter/material.dart';

class ReusableFavoratePosition extends StatelessWidget {
  final ColorScheme colorScheme;
  const ReusableFavoratePosition({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 115,
      right: 5,
      child: GestureDetector(
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesPage()),
          )
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(50)),
          child: Icon(
            Icons.favorite_rounded,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
