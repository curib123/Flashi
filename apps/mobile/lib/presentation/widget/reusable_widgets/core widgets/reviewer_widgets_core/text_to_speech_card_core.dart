import 'package:flutter/material.dart';

class TextToSpeechCardCore extends StatelessWidget {
  final Widget question;
  final String answer;

  const TextToSpeechCardCore({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: size.width * 0.9,
        margin: const EdgeInsets.symmetric(vertical: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.9),
              colorScheme.secondary.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            question,
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Text(
                answer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
