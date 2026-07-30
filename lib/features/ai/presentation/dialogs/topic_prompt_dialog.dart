import 'package:flashi/features/ai/presentation/widgets/credit_summary.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/features/ai/application/ai_generation_provider.dart';
import 'package:flashi/features/ai/application/generation_config_provider.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/core/ads/ad_unit_id.dart';
import 'package:flashi/shared/dialogs/message_dialog.dart';
import 'package:flashi/shared/dialogs/loading_dialog.dart';
import 'package:flashi/core/ads/widgets/watch_ad_dialog.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';

void showTopicDialog(BuildContext context, {required Function()? onTap}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  final TextEditingController topicController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  AdManager adManager = AdManager();
  adManager.loadRewardedAd(AdUnitId.rewardedAdUnitId);

  showAppDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Generate from a topic"),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add a clear topic. Optional instructions can narrow the level, scope, or learning goal.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: topicController,
                  label: 'Topic',
                  hint: 'Example: Photosynthesis',
                  colorScheme: colorScheme,
                  maxLength: 80,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: descriptionController,
                  label: 'Focus or instructions (optional)',
                  hint: 'Example: Grade 8 concepts and key vocabulary',
                  colorScheme: colorScheme,
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 10),
                Consumer<AiCreditProvider>(
                  builder: (context, aiCreditProvider, _) {
                    return Column(
                      children: [
                        CreditSummary(
                            credits: aiCreditProvider.credits,
                            colorScheme: colorScheme),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                              child: const Text("Cancel"),
                            ),
                            Consumer2<AiGenerationProvider,
                                GenerationConfigProvider>(
                              builder: (context, aiModelLogicProvider,
                                  fetchDataFromJsonProvider, _) {
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                  ),
                                  onPressed: () async {
                                    if (aiCreditProvider.credits >=
                                        fetchDataFromJsonProvider
                                            .creditsPerLength) {
                                      String topic =
                                          topicController.text.trim();
                                      String description =
                                          descriptionController.text.trim();

                                      if (topic.isNotEmpty) {
                                        showLoadingDialog(context,
                                            text: "Generating your quiz...");
                                        aiModelLogicProvider
                                            .updateTopicAndDescription(
                                                topic, description);
                                        onTap?.call();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Enter a topic to continue."),
                                          ),
                                        );
                                      }
                                    } else {
                                      adManager.loadRewardedAd(
                                          AdUnitId.rewardedAdUnitId);
                                      bool isConnected =
                                          await InternetConnection()
                                              .hasInternetAccess;
                                      if (!context.mounted) return;

                                      if (isConnected) {
                                        if (aiCreditProvider.watchAd()) {
                                          showWatchAdDialog(
                                            context: context,
                                            title: "Earn Free energy!",
                                            message:
                                                "Watch a short ad and instantly earn 5 free energy!",
                                            cancelText: "Maybe Later",
                                            confirmText: "Watch Ad",
                                            onWatchAd: () {
                                              showLoadingDialog(context,
                                                  text:
                                                      "Loading ads... Please wait.\nIf it doesn’t appear, try again.");
                                              Future.delayed(
                                                  const Duration(seconds: 10),
                                                  () {
                                                if (!context.mounted) return;
                                                Navigator.of(context).pop();
                                                adManager.showRewarded(
                                                    context, 'energy');
                                              });
                                            },
                                          );
                                        } else {
                                          showMessageDialog(
                                              context,
                                              type: "error",
                                              "Error",
                                              "No More Ads for Today!");
                                        }
                                      } else {
                                        showMessageDialog(
                                            context,
                                            type: "error",
                                            "Error",
                                            "Please connect to internet");
                                      }
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        aiCreditProvider.credits >=
                                                fetchDataFromJsonProvider
                                                    .creditsPerLength
                                            ? Icons.auto_awesome
                                            : Icons.play_circle_fill,
                                        color: colorScheme.onPrimary,
                                        size: 25,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        aiCreditProvider.credits >=
                                                fetchDataFromJsonProvider
                                                    .creditsPerLength
                                            ? "Generate"
                                            : "Watch Ads",
                                        style: TextStyle(
                                            fontSize: aiCreditProvider
                                                        .credits >=
                                                    fetchDataFromJsonProvider
                                                        .creditsPerLength
                                                ? 18
                                                : 15),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required ColorScheme colorScheme,
  int maxLines = 1,
  int? maxLength,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    maxLength: maxLength,
    textCapitalization: TextCapitalization.sentences,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
          color: colorScheme.primary.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500),
      filled: true,
      fillColor: colorScheme.primary.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
