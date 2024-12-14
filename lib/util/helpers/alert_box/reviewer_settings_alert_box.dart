import 'package:flashlearn/provider/reviewer_settings_provider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void reviewerSettingsAlertBox({
  required BuildContext context,
}) {
  // Options for dropdown
  const List<FlipDirection> flashCardFlippingDirection = [
    FlipDirection.HORIZONTAL,
    FlipDirection.VERTICAL,
  ];

  const List<int> timeDuration = [5,10,15,20,25,30];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      return AlertDialog(
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "Reviewer Settings",
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            fontSize: 20
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
                    color: colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
                // flipping card
                const SizedBox(height: 20),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     'Flashcard Flip Direction',
                     style: textTheme.bodySmall?.copyWith(
                       color: colorScheme.primary,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                   const SizedBox(height: 10),
                   DropdownButton<FlipDirection>(
                     isExpanded: true,
                     value: settingsProvider.flashCardFlippingDirection,
                     items: flashCardFlippingDirection.map((option) {
                       return DropdownMenuItem<FlipDirection>(
                         value: option,
                         child: Text(
                           option == FlipDirection.HORIZONTAL
                               ? "Horizontal"
                               : "Vertical",
                           style: textTheme.bodyMedium?.copyWith(
                             color: colorScheme.primary,
                           ),
                         ),
                       );
                     }).toList(),
                     onChanged: (newValue) {
                       if (newValue != null) {
                         settingsProvider.updateflashCardFlippingDirection(newValue);
                       }
                     },
                   ),
                 ],
               ),

                //Time Duration for multiple Choice

                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multiple Choice Time Duration',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: settingsProvider.timeDuration,
                      items: timeDuration.map((option) {
                        return DropdownMenuItem<int>(
                          value: option,
                          child: Text(
                          option.toString(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          settingsProvider.updateTimeDuration(newValue);
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        scrollable: true,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the alert
            },
            child: Text(
              "Cancel",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onError,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            onPressed: () {
              Provider.of<ReviewerSettingsProvider>(context, listen: false)
                  .flashCardFlippingDirection;

              Provider.of<ReviewerSettingsProvider>(context, listen: false)
                  .timeDuration;
              Navigator.of(context).pop(); // Close the alert
            },
            child: Text(
              "Save",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}
