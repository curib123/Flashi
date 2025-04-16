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
        bottom: 10,
        left: 0,
        right: 0,

        child: GestureDetector(
          onTap:onTap,
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 25),
              margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              decoration: BoxDecoration(
                color:  colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),


              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,color: colorScheme.primary,size: 30,),
                  const SizedBox(width: 10,),
                  Text(
                    name,
                    style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              )
          ),
        )
    );
  }
}
