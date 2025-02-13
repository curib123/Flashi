import 'package:flutter/material.dart';

class ReusableCreateSetButtonPosition extends StatelessWidget {
  final ColorScheme colorScheme;
  final String name;
  final Function()? onTap;
  final IconData icon;
  const ReusableCreateSetButtonPosition({super.key, required this.colorScheme, required this.name,required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return   Positioned(
        bottom: 0,
        left: 0,
        right: 0,

        child: GestureDetector(
          onTap:onTap,
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 25),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.6)], // Adjust colors as needed
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(50),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,color: colorScheme.onPrimary,size: 30,),
                  const SizedBox(width: 10,),
                  Text(
                    name,
                    style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              )
          ),
        )
    );
  }
}
