import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReusableSetSummaryCore extends StatelessWidget {
  final String name;
  final String description;
  final int numberOfQuiz;
  final VoidCallback onTap;
  final VoidCallback? onAddCard; // Action for "Add Cards"
  final VoidCallback? onReview; // Action for "Review"
  final DateTime timestamp; // Added timestamp parameter

  const ReusableSetSummaryCore({
    super.key,
    required this.name,
    required this.description,
    required this.numberOfQuiz,
    required this.onTap,
    this.onAddCard,
    this.onReview,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm').format(timestamp);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiaryContainer.withOpacity(.8),
            colorScheme.primaryContainer.withOpacity(.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Subtle shadow
            blurRadius: 10.0,
            offset: const Offset(0, 7), // Shadow position
          ),
        ],
        color: Colors.white, // Background color
      ),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header without More Options icon
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Row(
                children: [
                  // Left-side icon or avatar
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        numberOfQuiz.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  // Text information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Last updated: $formattedTimestamp',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Displaying timestamp
            Divider(height: 1.0, color: colorScheme.primary),
            // Bottom Buttons if actions are provided
            if (onAddCard != null || onReview != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Add Cards Button
                    if (onAddCard != null)
                      TextButton.icon(
                        onPressed: onAddCard,
                        icon: Icon(Icons.add_circle, color: colorScheme.primary),
                        label: Text(
                          "Add Cards",
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    // Review Button
                    if (onReview != null)
                      TextButton.icon(
                        onPressed: onReview,
                        icon: Icon(Icons.rate_review, color: colorScheme.secondary),
                        label: Text(
                          "Review",
                          style: TextStyle(color: colorScheme.secondary),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
