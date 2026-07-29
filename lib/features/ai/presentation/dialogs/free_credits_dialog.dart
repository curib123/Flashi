import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void showFreeCreditsDialog({
  required BuildContext context,
  required String rewardText,
  required Function() onClaim,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showGeneralDialog(
    context: context,
    barrierDismissible: false, // Prevent closing when tapping outside
    barrierLabel: "",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return PopScope(
        canPop: false,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            elevation: 10,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Reward Icon 🎉
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                    ),
                    child: const Icon(Icons.emoji_events,
                            size: 60, color: Colors.white)
                        .animate()
                        .scale(
                            duration: 500.ms,
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1.2, 1.2))
                        .then(delay: 100.ms)
                        .scale(
                            duration: 300.ms,
                            begin: const Offset(1.2, 1.2),
                            end: const Offset(1.0, 1.0)),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    "Congratulations!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Reward Message
                  Text(
                    rewardText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Claim Button 🎯
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      onClaim();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Claim Reward",
                      style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
