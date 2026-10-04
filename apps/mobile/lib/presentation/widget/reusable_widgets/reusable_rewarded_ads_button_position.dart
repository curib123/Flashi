import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReusableRewardedAdsButtonPosition extends StatelessWidget {
  final ColorScheme colorScheme;
  final String name;

  const ReusableRewardedAdsButtonPosition({
    super.key,
    required this.colorScheme,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final credits = context.watch<AiCreditProvider>();

    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      child: FilledButton.icon(
        onPressed: credits.loading
            ? null
            : () async {
                final ok = await credits.earnReward();
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        credits.error ?? 'Reward was not completed.',
                      ),
                    ),
                  );
                }
              },
        icon: const Icon(Icons.play_circle_outline_rounded),
        label: Text(credits.loading ? 'Loading reward…' : name),
      ),
    );
  }
}
