import 'package:flutter/material.dart';

class MultipleChoiceCard extends StatefulWidget {
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

  const MultipleChoiceCard({
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
  State<MultipleChoiceCard> createState() => _MultipleChoiceCardState();
}

class _MultipleChoiceCardState extends State<MultipleChoiceCard> {
  String? selectedOption;
  bool hasAnswered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.surface.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoCard("Score", "${widget.score}/${widget.totalScore}",
                  Icons.star, colorScheme.primary),
              _buildInfoCard(
                  "Timer", widget.timer, Icons.timer, colorScheme.secondary),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.8),
                  colorScheme.primary.withValues(alpha: 0.4)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: widget.question,
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
    );
  }

  Widget _buildInfoCard(
      String label, String value, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: bgColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    color: bgColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  )),
              Text(value,
                  style: TextStyle(
                    fontSize: 16,
                    color: bgColor,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          )
        ],
      ),
    );
  }

  Widget buildOptionTile(String option, ColorScheme colorScheme) {
    final isCorrect = widget.answer == option;
    final isSelected = selectedOption == option;

    Icon leadingIcon;
    if (isSelected) {
      leadingIcon = Icon(
        isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
        color: colorScheme.onPrimary,
      );
    } else if (hasAnswered && isCorrect) {
      leadingIcon = Icon(
        Icons.check_circle_outline,
        color: colorScheme.onPrimary,
      );
    } else {
      leadingIcon = Icon(
        Icons.circle_outlined,
        color: colorScheme.onPrimary,
      );
    }

    Color tileColor;
    if (isSelected) {
      tileColor = isCorrect ? Colors.green : Colors.red;
    } else if (hasAnswered && isCorrect) {
      tileColor = Colors.green.withValues(alpha: 0.8);
    } else {
      tileColor = colorScheme.primary.withValues(alpha: 0.5);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: tileColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
        ],
      ),
      child: ListTile(
        onTap: hasAnswered
            ? null
            : () {
                setState(() {
                  selectedOption = option;
                  hasAnswered = true;
                });
                widget.onAnswerSelected(option);
              },
        leading: leadingIcon,
        title: Text(
          option,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
