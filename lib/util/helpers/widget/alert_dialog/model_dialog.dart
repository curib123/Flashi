import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_credits_info_core.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_maintenace_alert_box.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_watch_ads_dialog.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class ModelSelectionDialog {
  static Future<void> show(BuildContext context, bool isCustomPrompt, {VoidCallback? onTap}) async {
    return await showDialog<void>(
      context: context,
      builder: (context) {
        AdManager adManager = AdManager();
        adManager.loadRewardedAd(AdUnitId.rewardedAdUnitId);
        ColorScheme colorScheme = Theme.of(context).colorScheme;

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
              child: Consumer<FetchDataFromJsonProvider>(
                builder: (context, fetchDataProvider, _) {
                  String selectedModel = fetchDataProvider.model;
                  int selectedMaxLength = fetchDataProvider.ListOfMaxLength;
                  String selectedQuizType = fetchDataProvider.quiz_question_type;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select best model, max length, and quiz type for your flashcard.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildDropdown<String>(
                        context,
                        label: "Select AI Model",
                        value: selectedModel,
                        items: fetchDataProvider.listOfModels,
                        onChanged: (newValue) {
                          if (newValue != null) selectedModel = newValue;
                        },
                        getCredits: null,

                      ),
                      const SizedBox(height: 20),

                      _buildDropdown<int>(
                        context,
                        label: "Select Q&A Max Length",
                        value: selectedMaxLength,
                        items: fetchDataProvider.listOfMaxLength,
                        onChanged: (newValue) {
                          if (newValue != null) selectedMaxLength = newValue;

                          fetchDataProvider.updateListOfMaxLength(newValue!);

                          for (int i = 0; i < fetchDataProvider.listOfMaxLength.length; i++)
                          {
                            if (fetchDataProvider.listOfMaxLength[i] == fetchDataProvider.ListOfMaxLength) // Check if value matches maxLength
                                {
                              int creditAmount = i + 1; // Use index +1 as credit amount
                              fetchDataProvider.updateCreditsPerLength(creditAmount);
                            }
                          }
                        },
                        getCredits: (item) => item ~/ 10,
                      ),
                      const SizedBox(height: 20),

                      _buildDropdown<String>(
                        context,
                        label: "Select Quiz Type",
                        value: selectedQuizType,
                        items: fetchDataProvider.listOfQuizQuestionTypes,
                        onChanged: (newValue) {
                          if (newValue != null) selectedQuizType = newValue;

                        },
                        getCredits: null,
                      ),
                      const SizedBox(height: 10),

                      Consumer<AiCreditProvider>(
                        builder: (context, aiCreditProvider, _) {
                          return Column(
                            children: [
                                ReusableCreditsInfoCore(credits: aiCreditProvider.credits, colorScheme: colorScheme),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(foregroundColor: colorScheme.secondary),
                                    child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      fetchDataProvider.updateModel(selectedModel);
                                      fetchDataProvider.updateQuizQuestionType(selectedQuizType);
                                      if (isCustomPrompt) {
                                        onTap?.call();
                                      } else if (aiCreditProvider.credits  >= fetchDataProvider.creditsPerLength) {
                                        onTap?.call();
                                      } else {
                                        adManager.loadRewardedAd(AdUnitId.rewardedAdUnitId);
                                        bool isConnected =
                                            await InternetConnection().hasInternetAccess;

                                        if(isConnected){
                                          if(aiCreditProvider.watchAd()){
                                            showWatchAdDialog(
                                              context: context,
                                              title: "Earn Free Credits!",
                                              message: "Watch a short ad and instantly earn 5 free credits!",
                                              cancelText: "Maybe Later",
                                              confirmText: "Watch Ad",
                                              onWatchAd: () {
                                                showLoadingDialog(context, text: "Loading ads... Please wait.\nIf it doesn’t appear, try again.");
                                                Future.delayed(const Duration(seconds: 10), () {
                                                  Navigator.of(context).pop();
                                                  adManager.showRewarded(context, 'credits');
                                                });
                                              },
                                            );
                                          }else{
                                            showMaintenanceDialog(context, "No More Ads for Today!", "That’s it for today! You’ve reached your daily limit of ${aiCreditProvider.maxAdsPerDay} ads. See you again tomorrow!");
                                          }
                                        }else{
                                          showMaintenanceDialog(context, "No Internet", "Please connect to internet");
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCustomPrompt ? Icons.arrow_forward :aiCreditProvider.credits  >= fetchDataProvider.creditsPerLength ? Icons.upload_file_rounded : Icons.play_circle_fill,
                                          color: colorScheme.onPrimary,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          isCustomPrompt
                                              ? "Next"
                                              :aiCreditProvider.credits  >= fetchDataProvider.creditsPerLength
                                              ? "Upload File"
                                              : "Watch Ads",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildDropdown<T>(BuildContext context, {
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required int Function(T item)? getCredits, // Make it nullable to avoid errors for non-int types
  }) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<T>(
      decoration: _inputDecoration(colorScheme, label),
      value: value,
      dropdownColor: colorScheme.onPrimary,
      style: TextStyle(color: colorScheme.primary),
      items: items.map((item) {
        String itemText = item.toString();

        // Check if item is an integer and get credits dynamically
        if (item is int && getCredits != null) {
          int credits = getCredits(item);
          itemText = "$item - $credits credits to use";
        }

        return DropdownMenuItem(value: item, child: Text(itemText));
      }).toList(),
      onChanged: onChanged,
    );
  }

  static InputDecoration _inputDecoration(ColorScheme colorScheme, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.primary),
      filled: true,
      fillColor: colorScheme.primary.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    );
  }
}
