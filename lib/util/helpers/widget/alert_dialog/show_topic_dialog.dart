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
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: colorScheme.onPrimary),
                          SizedBox(width: 10,),
                          Text(  "Generate", style: const TextStyle(fontSize: 16))
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
