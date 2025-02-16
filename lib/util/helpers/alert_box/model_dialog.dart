import 'package:flashi/provider/ai_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModelSelectionDialog {
  static Future<void> show(BuildContext context, {VoidCallback? onTap}) async {
    return await showDialog<void>(
      context: context,
      builder: (context) {
        String selectedModel = Provider.of<AiModelProvider>(context, listen: false).listOfModels.first;
        int selectedMaxLength = Provider.of<AiModelProvider>(context, listen: false).ListOfMaxLength.first;
        String selectedQuizType = Provider.of<AiModelProvider>(context, listen: false).listOfQuizQuestionTypes.first;

        ColorScheme colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.background,
          title: Text(
            "Select Preferences",
            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Model Selection Dropdown
                  _buildDropdown<String>(
                    context,
                    label: "Select AI Model",
                    value: selectedModel,
                    items: Provider.of<AiModelProvider>(context, listen: false)
                        .listOfModels,
                    onChanged: (newValue) {
                      if (newValue != null) setState(() => selectedModel = newValue);
                    },
                  ),
                  const SizedBox(height: 16), // Spacing

                  // Max Length Selection Dropdown
                  _buildDropdown<int>(
                    context,
                    label: "Select Max Length",
                    value: selectedMaxLength,
                    items: Provider.of<AiModelProvider>(context, listen: false).ListOfMaxLength,
                    onChanged: (newValue) {
                      if (newValue != null) setState(() => selectedMaxLength = newValue);
                    },
                  ),
                  const SizedBox(height: 16), // Spacing

                  // Quiz Question Type Dropdown
                  _buildDropdown<String>(
                    context,
                    label: "Select Quiz Type",
                    value: selectedQuizType,
                    items: Provider.of<AiModelProvider>(context, listen: false)
                        .listOfQuizQuestionTypes,
                    onChanged: (newValue) {
                      if (newValue != null) setState(() => selectedQuizType = newValue);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: colorScheme.secondary),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                var provider = Provider.of<AiModelProvider>(context, listen: false);
                provider.updateModel(selectedModel);
                provider.updateMaxLength(selectedMaxLength);
                provider.updateQuizQuestionType(selectedQuizType);
                onTap?.call();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Generate"),
            ),
          ],
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
      dropdownColor: colorScheme.surface,
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
      fillColor: colorScheme.onPrimary,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 1),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.secondary, width: 1),
      ),
    );
  }
}
