import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashlearn/provider/reviewer_settings_provider.dart';
import 'package:flip_card/flip_card.dart';

class ReviewerSettingsAlertContent extends StatelessWidget {
  const ReviewerSettingsAlertContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Static options for dropdowns
    const List<FlipDirection> flashCardFlippingDirection = [
      FlipDirection.HORIZONTAL,
      FlipDirection.VERTICAL,
    ];

    const List<int> timeDuration = [5, 10, 15, 20, 25, 30];

    return Consumer<ReviewerSettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informative Text
            Text(
              "Customize your reviewer settings below.",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Flashcard Flip Direction Dropdown
            _buildDropdownSection(
              context: context,
              label: "Flashcard Flip Direction",
              value: settingsProvider.flashCardFlippingDirection,
              items: flashCardFlippingDirection.map((option) {
                return DropdownMenuItem<FlipDirection>(
                  value: option,
                  child: Text(
                    option == FlipDirection.HORIZONTAL
                        ? "Horizontal"
                        : "Vertical",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (FlipDirection? newValue) {
                if (newValue != null) {
                  settingsProvider.updateflashCardFlippingDirection(newValue);
                }
              },
            ),
            const SizedBox(height: 20),

            // Time Duration Dropdown
            _buildDropdownSection(
              context: context,
              label: "Multiple Choice Time Duration",
              value: settingsProvider.timeDuration,
              items: timeDuration.map((option) {
                return DropdownMenuItem<int>(
                  value: option,
                  child: Text(
                    "$option seconds",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  settingsProvider.updateTimeDuration(newValue);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Helper Widget for Dropdown
  Widget _buildDropdownSection<T>({
    required BuildContext context,
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: colorScheme.surface,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          underline: Container(
            height: 2,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
