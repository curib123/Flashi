import 'package:flutter/material.dart';

Widget highlightKeywords({
  required BuildContext context,
  required String text,
  required String keyword,
  required double fontSize,
  required double fontSizeKeyword,
  required Color fontColor,
  required bool isCenter,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final defaultTextStyle = DefaultTextStyle.of(context).style;

  if (keyword.isEmpty) {
    return Align(
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        style: defaultTextStyle.copyWith(
          fontSize: fontSize,
          color: fontColor,
          fontWeight: FontWeight.normal,
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
        style: defaultTextStyle.copyWith(
          fontSize: fontSize,
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
      ));
      break;
    }

    if (index > start) {
      spans.add(TextSpan(
        text: text.substring(start, index),
        style: defaultTextStyle.copyWith(
          fontSize: fontSize,
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
      ));
    }

    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text.substring(index, index + keyword.length),
            style: defaultTextStyle.copyWith(
              fontSize: fontSizeKeyword,
              fontWeight: FontWeight.bold,
              color: colorScheme.tertiaryContainer,
            ),
          ),
        ),
      ),
    );

    start = index + keyword.length;
  }

  return Align(
    alignment: isCenter ? Alignment.center : Alignment.centerLeft,
    child: DefaultTextStyle.merge(
      style: defaultTextStyle, // Ensures font family stays consistent
      child: RichText(
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        text: TextSpan(children: spans),
      ),
    ),
  );
}
