import 'package:flutter/material.dart';

class MultipleChoiceReview extends StatelessWidget {
  final String reviewer;
  const MultipleChoiceReview({super.key, required this.reviewer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(reviewer), // Placeholder for content
    );
  }
}
