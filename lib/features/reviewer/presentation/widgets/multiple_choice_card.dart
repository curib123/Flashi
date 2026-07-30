import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_motion.dart';
import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flutter/material.dart';

class MultipleChoiceCard extends StatefulWidget {
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

  @override
  State<MultipleChoiceCard> createState() => _MultipleChoiceCardState();
}

class _MultipleChoiceCardState extends State<MultipleChoiceCard> {
  String? selectedOption;
  bool hasAnswered = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppBreakpoints.readingMaxWidth,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Score',
                    value: '${widget.score}/${widget.totalScore}',
                    icon: Icons.stars_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Metric(
                    label: 'Time',
                    value: widget.timer,
                    icon: Icons.timer_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: widget.question,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Choose one answer',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            for (final option in [
              widget.optionA,
              widget.optionB,
              widget.optionC,
              widget.optionD,
            ]) ...[
              _OptionTile(
                option: option,
                answer: widget.answer,
                selectedOption: selectedOption,
                hasAnswered: hasAnswered,
                onTap: () => _select(option),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }

  void _select(String option) {
    if (hasAnswered) return;
    setState(() {
      selectedOption = option;
      hasAnswered = true;
    });
    widget.onAnswerSelected(option);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadii.medium,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.answer,
    required this.selectedOption,
    required this.hasAnswered,
    required this.onTap,
  });

  final String option;
  final String answer;
  final String? selectedOption;
  final bool hasAnswered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCorrect = answer == option;
    final isSelected = selectedOption == option;
    final showCorrect = hasAnswered && isCorrect;
    final showIncorrect = hasAnswered && isSelected && !isCorrect;
    final background = showCorrect
        ? colors.primaryContainer
        : showIncorrect
            ? colors.errorContainer
            : colors.surfaceContainerLow;
    final foreground = showCorrect
        ? colors.onPrimaryContainer
        : showIncorrect
            ? colors.onErrorContainer
            : colors.onSurface;

    return AnimatedContainer(
      duration: AppMotion.fast,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.medium,
        border: Border.all(
          color: showCorrect || showIncorrect
              ? foreground.withValues(alpha: .35)
              : colors.outlineVariant,
        ),
      ),
      child: ListTile(
        enabled: !hasAnswered,
        onTap: onTap,
        leading: Icon(
          showCorrect
              ? Icons.check_circle_rounded
              : showIncorrect
                  ? Icons.cancel_rounded
                  : Icons.radio_button_unchecked_rounded,
          color: foreground,
        ),
        title: Text(
          option,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
