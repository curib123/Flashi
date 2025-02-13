import 'package:flutter/material.dart';

class MultipleChoiceCore extends StatefulWidget {
  final Widget question;
  final String answer;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String timer;
  final String score;
  final String totalScore;
  final ValueChanged<String> onAnswerSelected;

  const MultipleChoiceCore({
    super.key,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.answer,
    required this.timer,
    required this.onAnswerSelected,
    required this.score,
    required this.totalScore,
  });

  @override
  State<MultipleChoiceCore> createState() => _MultipleChoiceCoreState();
}

class _MultipleChoiceCoreState extends State<MultipleChoiceCore> {
  String? selectedOption;
  bool hasAnswered = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Score: ${widget.score} / ${widget.totalScore}",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Timer: ${widget.timer}",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: size.width,
              height: size.height * 0.4,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [colorScheme.tertiary.withOpacity(0.6), colorScheme.secondary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: widget.question
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                buildOptionTile(widget.optionA, colorScheme),
                const SizedBox(height: 15),
                buildOptionTile(widget.optionB, colorScheme),
                const SizedBox(height: 15),
                buildOptionTile(widget.optionC, colorScheme),
                const SizedBox(height: 15),
                buildOptionTile(widget.optionD, colorScheme),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildOptionTile(String option, ColorScheme colorScheme) {
    final isCorrect = widget.answer == option;
    final isSelected = selectedOption == option;

    Icon leadingIcon;
    if (isSelected) {
      if (isCorrect) {
        leadingIcon = Icon(Icons.check, color: colorScheme.onPrimary);
      } else {
        leadingIcon = Icon(Icons.close, color: colorScheme.onPrimary);
      }
    } else {
      if (isCorrect && !isSelected && hasAnswered) {
        leadingIcon = Icon(Icons.check, color: colorScheme.onPrimary);
      } else {
        leadingIcon = Icon(Icons.radio_button_unchecked, color: colorScheme.onPrimary);
      }
    }

    Color tileColor;
    if (isSelected) {
      if (isCorrect) {
        tileColor = colorScheme.primary;
      } else {
        tileColor = colorScheme.error;
      }
    } else {
      if (isCorrect && !isSelected && hasAnswered) {
        tileColor = colorScheme.primary;
      } else {
        tileColor = colorScheme.secondary;
      }
    }

    return ListTile(
      onTap: hasAnswered
          ? null
          : () {
        setState(() {
          selectedOption = option;
          hasAnswered = true;
        });
        widget.onAnswerSelected(option); // Notify parent widget
      },
      leading: leadingIcon,
      tileColor: tileColor,
      title: Text(
        option,
        style: TextStyle(
          color: isSelected || isCorrect
              ? colorScheme.onPrimary
              : colorScheme.onPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 18,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
