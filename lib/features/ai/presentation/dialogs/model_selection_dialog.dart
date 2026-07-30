import 'package:flashi/features/ai/presentation/widgets/credit_summary.dart';
import 'package:flashi/shared/widgets/app_text_field.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/features/ai/application/generation_config_provider.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/core/ads/ad_unit_id.dart';
import 'package:flashi/shared/dialogs/message_dialog.dart';
import 'package:flashi/core/ads/widgets/watch_ad_dialog.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';

class ModelSelectionDialog {
  static Future<void> show(BuildContext context, bool isCustomPrompt,
      {VoidCallback? onTap}) async {
    return await showAppDialog<void>(
      context: context,
      builder: (context) {
        AdManager adManager = AdManager();
        adManager.loadRewardedAd(AdUnitId.rewardedAdUnitId);
        ColorScheme colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          title: const Text("Quiz generation settings"),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Consumer2<GenerationConfigProvider, QuizProvider>(
                builder: (context, fetchDataProvider, quizProvider, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Choose the output before selecting your source.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown<int>(
                        context,
                        label: "Quiz length",
                        value: fetchDataProvider.maxLength,
                        items: fetchDataProvider.listOfMaxLength,
                        onChanged: (newValue) {
                          if (newValue == null) return;
                          fetchDataProvider.updateListOfMaxLength(newValue);
                        },
                        getCredits:
                            GenerationConfigProvider.energyCostForLength,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown<String>(
                        context,
                        label: "AI model",
                        value: fetchDataProvider.model,
                        items: fetchDataProvider.listOfModels,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            fetchDataProvider.updateModel(newValue);
                          }
                        },
                        getCredits: null,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown<String>(
                        context,
                        label: "Question style",
                        value: fetchDataProvider.quizQuestionType,
                        items: fetchDataProvider.listOfQuizQuestionTypes,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            fetchDataProvider.updateQuizQuestionType(newValue);
                          }
                        },
                        getCredits: null,
                      ),
                      AppTextField(
                        isHideName: true,
                        name: "Quiz Set Name",
                        controller: quizProvider.nameController,
                      ),
                      const SizedBox(height: 10),
                      Consumer<AiCreditProvider>(
                        builder: (context, aiCreditProvider, _) {
                          return Column(
                            children: [
                              CreditSummary(
                                  credits: aiCreditProvider.credits,
                                  colorScheme: colorScheme),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                        foregroundColor: colorScheme.secondary),
                                    child: const Text("Cancel",
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (isCustomPrompt) {
                                        onTap?.call();
                                      } else if (aiCreditProvider.credits >=
                                          fetchDataProvider.creditsPerLength) {
                                        onTap?.call();
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
                                                adManager.showRewardedOrNotify(
                                                    context, 'energy');
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
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCustomPrompt
                                              ? Icons.arrow_forward
                                              : aiCreditProvider.credits >=
                                                      fetchDataProvider
                                                          .creditsPerLength
                                                  ? Icons.upload_file_rounded
                                                  : Icons.play_circle_fill,
                                          color: colorScheme.onPrimary,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          isCustomPrompt
                                              ? "Continue"
                                              : aiCreditProvider.credits >=
                                                      fetchDataProvider
                                                          .creditsPerLength
                                                  ? "Choose file"
                                                  : "Earn energy",
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

  static Widget _buildDropdown<T>(
    BuildContext context, {
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required int Function(T item)?
        getCredits, // Make it nullable to avoid errors for non-int types
  }) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<T>(
      decoration: _inputDecoration(colorScheme, label),
      initialValue: value,
      dropdownColor: colorScheme.surfaceContainerHigh,
      style: TextStyle(color: colorScheme.onSurface),
      items: items.map((item) {
        String itemText = item.toString();

        // Check if item is an integer and get credits dynamically
        if (item is int && getCredits != null) {
          int credits = getCredits(item);
          itemText = '$item cards · $credits energy';
        }

        return DropdownMenuItem(
            value: item,
            child: Text(
              itemText,
              style: const TextStyle(fontSize: 13),
            ));
      }).toList(),
      onChanged: onChanged,
    );
  }

  static InputDecoration _inputDecoration(
      ColorScheme colorScheme, String label) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    );
  }
}
