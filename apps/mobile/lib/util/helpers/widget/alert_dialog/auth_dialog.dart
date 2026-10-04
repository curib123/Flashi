import 'package:flutter/material.dart';

void showAuthDialog(BuildContext context, String title, String message, {String type = "info"}) {
  final colorScheme = Theme.of(context).colorScheme;
  final Map<String, dynamic> dialogTypes = {
    "success": {"icon": Icons.check_circle, "color": colorScheme.primary},
    "error": {"icon": Icons.error, "color": colorScheme.error},
    "warning": {"icon": Icons.warning, "color": colorScheme.secondary},
    "info": {"icon": Icons.info, "color": colorScheme.tertiary},
  };

  final iconData = dialogTypes[type]?["icon"] ?? Icons.info;
  final iconColor = dialogTypes[type]?["color"] ?? colorScheme.secondary;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, _, __) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(iconData, color: iconColor, size: 50),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: iconColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("OK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, _, child) {
      return FadeTransition(
        opacity: anim1,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        ),
      );
    },
  );
}