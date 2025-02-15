import 'package:flashi/presentation/screen/main/favorate_screen.dart';
import 'package:flutter/material.dart';

class ReusableFavoratePosition extends StatelessWidget {
  final ColorScheme colorScheme;
  const ReusableFavoratePosition({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return  Positioned(
      bottom: 115 ,
      right: 15,
      child: GestureDetector(
        onTap: () => {
          Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoriteScreen()),
        )},
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(50)

          ),
          child: Icon(Icons.favorite_rounded,color: colorScheme.onPrimary,),
        ),
      ),
    );
  }
}
