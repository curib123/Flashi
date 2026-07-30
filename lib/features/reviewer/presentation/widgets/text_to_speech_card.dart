import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flutter/material.dart';

class TextToSpeechCard extends StatelessWidget {
  const TextToSpeechCard({
    super.key,
    required this.question,
    required this.answer,
  });

  final Widget question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppBreakpoints.readingMaxWidth,
          minHeight: 360,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: AppRadii.medium,
                  ),
                  child: const Icon(Icons.graphic_eq_rounded),
                ),
                const SizedBox(height: AppSpacing.lg),
                question,
                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: AppRadii.medium,
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Text(
                    answer,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
