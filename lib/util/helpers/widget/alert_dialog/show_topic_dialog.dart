import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_credits_info_core.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/ai_model_logic_provider.dart';
import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_watch_ads_dialog.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

void showTopicDialog(BuildContext context, {required Function()? onTap}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  final TextEditingController topicController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  AdManager adManager = AdManager();
  adManager.loadRewardedAd(AdUnitId.rewardedAdUnitId);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(10),
        title: Container(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Center(
            child: Text(
              "Customize Prompt",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Make sure to input topics and provide an accurate description for the best results.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: topicController,
                  hint: "Enter topic title...",
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: descriptionController,
                  hint: "Provide a brief description...",
                  colorScheme: colorScheme,
                  maxLines: 4,
                ),
                const SizedBox(height: 10),
                Consumer<AiCreditProvider>(
                  builder: (context, aiCreditProvider, _) {
                    return Column(
                      children: [
                        ReusableCreditsInfoCore(
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
                            Consumer2<AiModelLogicProvider,
                                FetchDataFromJsonProvider>(
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

                                      if (topic.isNotEmpty &&
                                          description.isNotEmpty) {
                                        showLoadingDialog(context,
                                            text:
                                                "Please wait .. AI Processing..");
                                        aiModelLogicProvider
                                            .updateTopicAndDescription(
                                                topic, description);
                                        onTap?.call();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                "Both fields are required."),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    } else {
                                      adManager.loadRewardedAd(
                                          AdUnitId.rewardedAdUnitId);
                                      bool isConnected =
                                          await InternetConnection()
                                              .hasInternetAccess;

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
                                                Navigator.of(context).pop();
                                                adManager.showRewarded(
                                                    context, 'energy');
                                              });
                                            },
                                          );
                                        } else {
                                          showAuthDialog(
                                              context,
                                              type: "error",
                                              "Error",
                                              "No More Ads for Today!");
                                        }
                                      } else {
                                        showAuthDialog(
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
  required String hint,
  required ColorScheme colorScheme,
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: colorScheme.primary.withOpacity(0.7),
          fontWeight: FontWeight.w500),
      filled: true,
      fillColor: colorScheme.primary.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
