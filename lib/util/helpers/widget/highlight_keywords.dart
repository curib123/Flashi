import 'package:flutter/material.dart';

Widget highlightKeywords({
  required BuildContext context,
  required String text,
  required String keyword,
  required double fontSize,
  required double fontSizeKeyword,
  required Color fontColor,
  String fontFamily = 'Roboto', // Set default font family
}) {
  final colorScheme = Theme.of(context).colorScheme;

  if (keyword.isEmpty) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center, // Ensures text wraps centrally
        style: TextStyle(
          fontSize: fontSize,
          color: fontColor,
          fontWeight: FontWeight.normal,
          fontFamily: fontFamily, // Apply font family
        ),
      ),
    );
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
        style: TextStyle(
          fontSize: fontSize,
          color: fontColor,
          fontWeight: FontWeight.normal,
          fontFamily: fontFamily, // Ensure consistent font
        ),
      ));
      break;
    }

    // Add text before the highlighted word
    if (index > start) {
      spans.add(TextSpan(
        text: text.substring(start, index),
        style: TextStyle(
          fontSize: fontSize,
          color: fontColor,
          fontWeight: FontWeight.normal,
          fontFamily: fontFamily, // Apply font family
        ),
      ));
    }

    // Add highlighted keyword with rounded background
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: colorScheme.tertiary, // Highlight background
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text.substring(index, index + keyword.length),
            style: TextStyle(
              fontSize: fontSizeKeyword,
              fontWeight: FontWeight.bold,
              color: colorScheme.tertiaryContainer, // Contrast text color
              fontFamily: fontFamily, // Ensure consistent font
            ),
          ),
        ),
      ),
    );

    start = index + keyword.length;
  }

  return Align(
    alignment: Alignment.center,
    child: RichText(
      textAlign: TextAlign.center, // Ensures text wraps centrally
      text: TextSpan(children: spans),
    ),
  );
}
