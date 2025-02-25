import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
void showWatchAdDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelText,
  required String confirmText,
  required VoidCallback onWatchAd,
}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;

  showDialog(
    context: context,
    builder: (context) {
      return Consumer<AiCreditProvider>(
        builder: (context, aiCreditProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle_fill, color: colorScheme.primary, size: 50),
                SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                ),
                SizedBox(height: 12),
                Text(
                  "Ads Watched Today: ${aiCreditProvider.adsWatchedToday}/${aiCreditProvider.maxAdsPerDay}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                if (aiCreditProvider.adCooldown > 0) ...[
                  SizedBox(height: 10),
                  Text(
                    "Next ad available in: ${aiCreditProvider.adCooldown}s",
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(cancelText, style: TextStyle(color: colorScheme.secondary)),
                    ),
                    ElevatedButton(
                      onPressed: (aiCreditProvider.adsWatchedToday < aiCreditProvider.maxAdsPerDay &&
                          aiCreditProvider.adCooldown == 0)
                          ? () {
                        Navigator.pop(context);
                        onWatchAd();
                      }
                          : null, // Disable button if cooldown is active
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (aiCreditProvider.adsWatchedToday < aiCreditProvider.maxAdsPerDay &&
                            aiCreditProvider.adCooldown == 0)
                            ? colorScheme.primary
                            : colorScheme.error,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        aiCreditProvider.adCooldown > 0
                            ? "Wait ${aiCreditProvider.adCooldown}s"
                            : confirmText,
                        style: TextStyle(color:  aiCreditProvider.adCooldown > 0 ? colorScheme.onError : colorScheme.onPrimary,fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
