import 'package:flashi/features/quiz/data/services/quiz_import_export_service.dart';
import 'package:flutter/material.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:provider/provider.dart';

class ReusableImportPosition extends StatelessWidget {
  final ColorScheme colorScheme;
  const ReusableImportPosition({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final QuizImportExportService helper = QuizImportExportService();
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    return Positioned(
      bottom: 160,
      right: 5, // Adjusted for balance (optional)
      child: GestureDetector(
        onTap: () {
          helper.importList(context, quizProvider);
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.import_export_rounded,
            size: 23,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
