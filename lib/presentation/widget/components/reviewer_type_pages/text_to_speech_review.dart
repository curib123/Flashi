import 'package:flutter/material.dart';

class TextToSpeechReview extends StatelessWidget {
  final String reviewer;
  const TextToSpeechReview ({super.key, required this.reviewer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(reviewer), // Placeholder for content
    );
  }
}
