import 'package:flutter/material.dart';

class MatchingTypeReview extends StatelessWidget {
  final String reviewer;
  const MatchingTypeReview({super.key, required this.reviewer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(reviewer), // Placeholder for content
    );
  }
}
