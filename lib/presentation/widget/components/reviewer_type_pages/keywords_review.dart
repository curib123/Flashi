import 'package:flutter/material.dart';

class KeywordsReview extends StatelessWidget {
  final String reviewer;
  const KeywordsReview({super.key, required this.reviewer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(reviewer), // Placeholder for content
    );
  }
}
