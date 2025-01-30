import 'package:flutter/material.dart';

class TextToSpeechCardCore extends StatelessWidget {
  // Declaring final variables to hold question and answer text
  final Widget question;
  final String answer;

  // Constructor with required named parameters
  const TextToSpeechCardCore({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen size and theme color scheme
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      // Apply consistent margin and responsive size
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      width: size.width,
      // Add a gradient background, shadow, and rounded corners
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.5),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           question,
            const SizedBox(height: 20),
            // Display the answer with styled appearance and automatic wrapping
            Text(
              answer,
              textAlign: TextAlign.center, // Keep alignment consistent
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
