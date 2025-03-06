import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showMergeFlashcardDialog(BuildContext context, {required VoidCallback onMerge, required VoidCallback onDiscard}) {
  final colorScheme = Theme.of(context).colorScheme;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Modern rounded corners
        backgroundColor: colorScheme.background,
        title: Column(
          children: [
            Icon(Icons.info, color: colorScheme.primary, size: 50),
            SizedBox(height: 8),
            Text(
              "Merge/Sync Flashcards?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            )
          ],
        ),
        content: Text(
          "Do you want to merge your locally created flashcards with your account? If not, they will be removed.",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: colorScheme.secondary,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: onDiscard,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error, // Use error color for discard
            ),
            child: Text(
              "Discard",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: onMerge,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Merge",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    },
  );
}
