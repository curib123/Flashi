import 'dart:convert';

import 'package:flashi/provider/ai_model_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/alert_box/model_dialog.dart';
import 'package:flashi/util/helpers/alert_box/show_maintenace_alert_box.dart';
import 'package:flashi/util/helpers/file_text_extractor.dart';
import 'package:flashi/util/helpers/modal/create_set_bottom_modal.dart';
import 'package:flashi/util/helpers/widget/ai_model/ai_question_generator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiModelLogicProvider extends ChangeNotifier {
  String extractedText = "";
  bool isLoading = false;
  bool isUnderMaintenance = false;
  String reasonMaintenance = '';

  Future<void> _fetchLatestVersion() async {
    final response = await http.get(Uri.parse('https://curib123.github.io/flashi_/flashi.json'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Extract the AI models data

      isUnderMaintenance = data['under_maintenance'];
      reasonMaintenance = data['reason_maintenance_ai'];
      print(isUnderMaintenance);
      print(reasonMaintenance);
      notifyListeners();


    } else {
      print("Failed to load data");
    }
  }

  Future<void> pickFileAndGenerate(BuildContext context, QuizProvider quizProvider, AiModelProvider aiModelProvider) async {
    isLoading = true;
    notifyListeners();

    extractedText = await FileTextExtractor.pickAndExtractText();

    if (extractedText.isEmpty || extractedText == "No file selected") {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a valid file first"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final questions = await AIQuestionGenerator.generateQuestions(
      extractedText,
      aiModelProvider.model,
      aiModelProvider.quiz_question_type,
      aiModelProvider.maxLength,
      aiModelProvider.questionTypes
    );

    if (questions.isNotEmpty) {
      final quizSetName = 'AI Generated ${quizProvider.quizSets.length + 1}';
      quizProvider.addQuizSet({
        'name': quizSetName,
        'timestamp': DateTime.now(),
        'description': 'AI Generated Flashcard content using PDF/docs file',
        'cards': [],
        'numberOfQuiz': 0,
        'limitNumberOfQuiz': aiModelProvider.maxLength,
      });

      for (var questionData in questions) {
        quizProvider.addCardToQuizSet(
          quizSetName: quizSetName,
          card: {
            'isUpdating': false,
            'question': questionData['question'] ?? '',
            'answer': questionData['answer'] ?? '',
            'isIgnore': false,
            'keyword': '',
            'timestamp': DateTime.now(),
          },
        );
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully Created AI Generated Flashcard using pdf/docs"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 10),
          content: Text("It seems there’s no internet connection. Please try again or choose another model."),
          backgroundColor: Colors.red,
        ),
      );
      showMaintenanceDialog(context, 'Try Again', "It seems there’s no internet connection. Please try again or choose another model.");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> showFlashcardDialog(BuildContext context, QuizProvider quizProvider, ColorScheme colorScheme, AiModelProvider aiModelProvider) async {

    await _fetchLatestVersion();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Center(
                child: Text(
                  "Choose Flashcard Type",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLoading
                        ? "Please wait while generating questions..."
                        : "Would you like to create a custom flashcard or generate one from a pdf/docs file using AI?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                        strokeWidth: 3,
                      ),
                    ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            CreateSetBottomModal(
                              context: context,
                              buttonName: 'Save',
                              isCreate: true,
                              setName: '',
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Custom Flashcard",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {

                            if(!isUnderMaintenance){
                              ModelSelectionDialog.show(
                                context,
                                onTap: () async {
                                  setDialogState(() => isLoading = true);
                                  await pickFileAndGenerate(context, quizProvider, aiModelProvider);
                                  setDialogState(() => isLoading = false);

                                },
                              );
                            }else{
                              showMaintenanceDialog(context, 'Under Maintenance', reasonMaintenance);
                            }

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "AI Generated",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
