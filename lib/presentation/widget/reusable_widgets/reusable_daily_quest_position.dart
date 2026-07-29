import 'package:flashi/provider/DailyQuestionProvider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/showDailyQuestionDialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReusableDailyQuestPosition extends StatelessWidget {
  final ColorScheme colorScheme;
  const ReusableDailyQuestPosition({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final dailyQuestionProvider = Provider.of<DailyQuestionProvider>(context);

    return Positioned(
      bottom: 210,
      right: 5, // Adjusted for balance (optional)
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => DailyQuestionDialog(
                  questions: dailyQuestionProvider.funFacts));
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.lightbulb_outline,
            size: 24,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
