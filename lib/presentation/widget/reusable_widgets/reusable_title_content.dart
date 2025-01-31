import 'package:flutter/material.dart';

class ReusableTitleContent extends StatelessWidget {

  final ColorScheme colorScheme;
  final String title;
  final VoidCallback onUpgradePro;
  final VoidCallback onSettings;

  const ReusableTitleContent({super.key, required this.colorScheme, required this.title, required this.onUpgradePro, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: title.length >= 12 ?   18: 24,
            overflow: TextOverflow.ellipsis
          ),
        ),
        Row(
          children: [
            // IconButton(
            //     onPressed: onUpgradePro,
            //     icon: Icon(
            //       Icons.diamond_rounded,
            //       color: colorScheme.onPrimary,
            //       size: 30,
            //     )),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onSettings,
              child: CircleAvatar(
                backgroundColor: colorScheme.onPrimary,
                child: Icon(
                  Icons.settings_rounded,
                  size: 25,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
