import 'package:flutter/material.dart';

class FlashcardReview extends StatelessWidget {
  final String reviewer;
  const FlashcardReview({super.key, required this.reviewer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(reviewer), // Placeholder for content
    );
  }
}
