import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String name;
  final bool isHideName;
  final String? hintText;
  final TextEditingController? controller;

  const AppTextField({
    super.key,
    required this.name,
    this.hintText,
    this.controller,
    required this.isHideName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHideName ? "" : name,
          style: TextStyle(
            color: colorScheme.secondary.withValues(alpha: .8),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
            height:
                isHideName ? 0 : 8), // Add spacing between label and text field
        Material(
          elevation: 10,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText ?? 'Enter $name',
              hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              filled: true,
              fillColor: colorScheme.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: colorScheme.outline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .primary, // Ensures the text value is black
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
