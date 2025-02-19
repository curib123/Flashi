import 'package:flashi/provider/ai_model_logic_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showTopicDialog(BuildContext context, {required Function()? onTap}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  final TextEditingController topicController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  AiModelLogicProvider aiModelLogicProvider = Provider.of<AiModelLogicProvider>(context,listen: false);

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.onPrimary,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Customize Prompt",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      onPressed: () {
                        String topic = topicController.text.trim();
                        String description = descriptionController.text.trim();

                        if (topic.isNotEmpty && description.isNotEmpty) {
                          showLoadingDialog(context);
                          aiModelLogicProvider.updateTopicAndDescription(topic, description);
                          onTap?.call();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Both fields are required."),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      child: const Text("Generate"),
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
      hintStyle: TextStyle(color: colorScheme.primary.withOpacity(0.7), fontWeight: FontWeight.w500),
      filled: true,
      fillColor: colorScheme.primary.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // Add border radius
        borderSide: BorderSide.none, // No visible border
      ),
    ),
  );
}
