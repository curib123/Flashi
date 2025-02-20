
import 'package:flashi/provider/ai_model_logic_provider.dart';
import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModelSelectionDialog {
  static Future<void> show(BuildContext context, bool isCustomPrompt, {VoidCallback? onTap}) async {
    return await showDialog<void>(
      context: context,
      builder: (context) {
        String selectedModel = Provider.of<FetchDataFromJsonProvider>(context, listen: false).listOfModels.first;
        int selectedMaxLength = Provider.of<FetchDataFromJsonProvider>(context, listen: false).ListOfMaxLength.first;
        String selectedQuizType = Provider.of<FetchDataFromJsonProvider>(context, listen: false).listOfQuizQuestionTypes.first;
        AiModelLogicProvider aiModelLogicProvider = Provider.of<AiModelLogicProvider>(context, listen: false);

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
            child: SingleChildScrollView( // Wrap content with SingleChildScrollView to avoid overflow
              child: Column(
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
                  // Model Selection Dropdown
                  _buildDropdown<String>(
                    context,
                    label: "Select AI Model",
                    value: selectedModel,
                    items: Provider.of<FetchDataFromJsonProvider>(context, listen: false).listOfModels,
                    onChanged: (newValue) {
                      if (newValue != null) selectedModel = newValue;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Max Length Selection Dropdown
                  _buildDropdown<int>(
                    context,
                    label: "Select Max Length",
                    value: selectedMaxLength,
                    items: Provider.of<FetchDataFromJsonProvider>(context, listen: false).ListOfMaxLength,
                    onChanged: (newValue) {
                      if (newValue != null) selectedMaxLength = newValue;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Quiz Question Type Dropdown
                  _buildDropdown<String>(
                    context,
                    label: "Select Quiz Type",
                    value: selectedQuizType,
                    items: Provider.of<FetchDataFromJsonProvider>(context, listen: false).listOfQuizQuestionTypes,
                    onChanged: (newValue) {
                      if (newValue != null) selectedQuizType = newValue;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(foregroundColor: colorScheme.secondary),
                        child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          var provider = Provider.of<FetchDataFromJsonProvider>(context, listen: false);
                          provider.updateModel(selectedModel);
                          provider.updateMaxLength(selectedMaxLength);
                          provider.updateQuizQuestionType(selectedQuizType);
                          onTap?.call();

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
                           isCustomPrompt ?  Icon(Icons.arrow_forward, color: colorScheme.onPrimary) : Icon(Icons.upload_file_rounded,color: colorScheme.onPrimary,),
                            SizedBox(width: 10,),
                            Text(isCustomPrompt ? "Next" : "Upload File", style: const TextStyle(fontSize: 16))
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Dropdown Helper Method
  static Widget _buildDropdown<T>(BuildContext context, {required String label, required T value, required List<T> items, required ValueChanged<T?> onChanged}) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<T>(
      decoration: _inputDecoration(colorScheme, label),
      value: value,
      dropdownColor: colorScheme.onPrimary,
      style: TextStyle(color: colorScheme.primary),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.toString()))).toList(),
      onChanged: onChanged,
    );
  }

  // Input Decoration Helper
  static InputDecoration _inputDecoration(ColorScheme colorScheme, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.primary),
      filled: true,
      fillColor: colorScheme.primary.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // Add border radius
        borderSide: BorderSide.none, // No visible border
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
    );
  }
}
