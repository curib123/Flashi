import 'package:flashi/provider/ai_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModelSelectionDialog {
  static Future<void> show(BuildContext context, {VoidCallback? onTap}) async {
    return await showDialog<void>(
      context: context,
      builder: (context) {
        String selectedModel = Provider.of<AiModelProvider>(context, listen: false).model;
        int selectedMaxLength = Provider.of<AiModelProvider>(context, listen: false).maxLength;
        String selectedQuizType = Provider.of<AiModelProvider>(context, listen: false).quiz_question_type;

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
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration(colorScheme, "Select AI Model"),
                    value: selectedModel,
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(color: colorScheme.onSurface),
                    items: Provider.of<AiModelProvider>(context, listen: false)
                        .listOfModels
                        .map((model) => DropdownMenuItem(value: model, child: Text(model)))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) setState(() => selectedModel = newValue);
                    },
                  ),
                  const SizedBox(height: 16), // Spacing

                  // Max Length Selection Dropdown
                  DropdownButtonFormField<int>(
                    decoration: _inputDecoration(colorScheme, "Select Max Length"),
                    value: selectedMaxLength,
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(color: colorScheme.onSurface),
                    items: Provider.of<AiModelProvider>(context, listen: false)
                        .ListOfMaxLength
                        .map((length) => DropdownMenuItem(value: length, child: Text(length.toString())))
                        .toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) setState(() => selectedMaxLength = newValue);
                    },
                  ),
                  const SizedBox(height: 16), // Spacing

                  // Quiz Question Type Dropdown
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration(colorScheme, "Select Quiz Type"),
                    value: selectedQuizType,
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(color: colorScheme.onSurface),
                    items: Provider.of<AiModelProvider>(context, listen: false)
                        .listOfQuizQuestionTypes
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (String? newValue) {
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
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Input Decoration Helper
  static InputDecoration _inputDecoration(ColorScheme colorScheme, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.primary),
      filled: true,
      fillColor: colorScheme.surface,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 3),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.secondary, width: 3),
      ),
    );
  }
}
