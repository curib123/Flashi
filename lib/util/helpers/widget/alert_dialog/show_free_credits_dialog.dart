import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void showFreeCreditsDialog({
  required BuildContext context,
  required String rewardText,
  required VoidCallback onClaim,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Free energy reward',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return PopScope(
        canPop: false,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 38,
                      color: colorScheme.primary,
                    ),
                  )
                      .animate()
                      .scale(
                        duration: 420.ms,
                        begin: const Offset(.82, .82),
                        end: const Offset(1, 1),
                      ),
                  const SizedBox(height: 18),
                  Text(
                    'Free energy ready',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rewardText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        onClaim();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.redeem_rounded),
                      label: const Text('Claim reward'),
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
