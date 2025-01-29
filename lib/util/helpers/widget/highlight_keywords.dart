import 'package:flutter/material.dart';

Widget highlightKeywords(String text, BuildContext context, String keyword) {
  final colorScheme = Theme.of(context).colorScheme;

  if (keyword.isEmpty) {
    return Text(text, style: TextStyle(fontSize: 16));
  }

  List<InlineSpan> spans = [];
  String lowerText = text.toLowerCase();
  String lowerKeyword = keyword.toLowerCase();
  int start = 0;

  while (true) {
    int index = lowerText.indexOf(lowerKeyword, start);
    if (index == -1) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ));
      break;
    }

    // Add text before the highlighted word
    if (index > start) {
      spans.add(TextSpan(
        text: text.substring(start, index),
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ));
    }

    // Add highlighted keyword with rounded background
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: colorScheme.tertiary, // Background highlight
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text.substring(index, index + keyword.length),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.onTertiary, // Text color contrast
            ),
          ),
        ),
      ),
    );

    start = index + keyword.length;
  }

  return RichText(text: TextSpan(children: spans));
}
