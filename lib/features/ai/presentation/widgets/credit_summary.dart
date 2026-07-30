import 'package:flutter/material.dart';

class CreditSummary extends StatelessWidget {
  final int credits;
  final ColorScheme colorScheme;

  const CreditSummary({
    super.key,
    required this.credits,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            "Use energy to create AI-generated flashcards.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w400,
              color: colorScheme.tertiary,
            ),
          ),
          Text(
            "Need more? Watch a rewarded ad to earn 5 energy.",
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 10), // Spacing for balance
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                  children: [
                    TextSpan(text: "$credits "),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.token_rounded,
                        size: 15, // Adjust size for balance
                        color: colorScheme.secondary,
                      ),
                    ),
                    const TextSpan(text: " energy available"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
