import 'package:flashlearn/provider/reviewer_settings_provider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void reviewerSettingsAlertBox({
  required BuildContext context,
}) {
  const List<FlipDirection> flashCardFlippingDirection = [
    FlipDirection.HORIZONTAL,
    FlipDirection.VERTICAL,
  ];

  const List<int> timeDuration = [5, 10, 15, 20, 25, 30];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      return AlertDialog(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        elevation: 15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Text(
            "Reviewer Settings",
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Consumer<ReviewerSettingsProvider>(
          builder: (context, settingsProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Customize your reviewer settings below.",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
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
        ),
        scrollable: true,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
        actions: [
          _buildActionButton(
            context: context,
            label: "Cancel",
            color: colorScheme.error,
            textColor: colorScheme.onError,
            onPressed: () => Navigator.of(context).pop(),
          ),
          _buildActionButton(
            context: context,
            label: "Save",
            color: colorScheme.secondary,
            textColor: colorScheme.onPrimary,
            onPressed: () {
              Provider.of<ReviewerSettingsProvider>(context, listen: false)
                  .flashCardFlippingDirection;
              Provider.of<ReviewerSettingsProvider>(context, listen: false)
                  .timeDuration;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

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

Widget _buildActionButton({
  required BuildContext context,
  required String label,
  required Color color,
  required Color textColor,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    ),
    onPressed: onPressed,
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
