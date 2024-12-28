import 'package:flutter/material.dart';

class ReusableSearchBarCore extends StatelessWidget {
  final ColorScheme colorScheme;
  final Function(String)? onChanged;
  final String hintText;
  final TextEditingController controller;
  const ReusableSearchBarCore({
    super.key,
    required this.colorScheme,
    required this.hintText,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: colorScheme.onPrimary,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 30,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(color: colorScheme.primary),
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: colorScheme.primary),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
