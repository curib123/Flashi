import 'package:flashi/util/helpers/classes/other/import_export_helper_class.dart';
import 'package:flutter/material.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:provider/provider.dart';

class ReusableImportPosition extends StatelessWidget {
  final ColorScheme colorScheme;
  const ReusableImportPosition({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final ImportExportHelperClass helper = ImportExportHelperClass();
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    return Positioned(
      bottom: 160,
      right: 15, // Adjusted for balance (optional)
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
            Icons.add_card_sharp,
            size: 20,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
