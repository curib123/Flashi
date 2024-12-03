import 'package:flutter/material.dart';

class QuestionAndAnswer extends StatelessWidget {
  final String reviewer;
  const QuestionAndAnswer ({super.key, required this.reviewer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(reviewer), // Placeholder for content
    );
  }
}
