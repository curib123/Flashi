import 'dart:convert';
import 'dart:math';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/provider/history_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/api/ai/core/ai_question_generator.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/model_dialog.dart';
import 'package:flashi/util/helpers/classes/other/file_text_extractor.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_topic_dialog.dart';
import 'package:flashi/util/helpers/widget/modals/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class AiModelLogicProvider extends ChangeNotifier {
  String extractedText = "";
  String topic = "";
  String description = "";
  bool isUnderMaintenance = false;
  String reasonMaintenance = '';
  bool isFetchData = false;
  bool isTimeOut = false;


  void updateTopicAndDescription(String newTopic, String newDescription) {
    topic = newTopic;
    description = newDescription;
    notifyListeners();
  }

  Future<void> fetchLatestVersion() async {
    final response = await http.get(
        Uri.parse('https://curib123.github.io/flashi_/flashi.json'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Extract the AI models data

      isUnderMaintenance = data['under_maintenance'];
      reasonMaintenance = data['reason_maintenance_ai'];
      isFetchData = true;
      notifyListeners();
    } else {
      print("Failed to load data");
    }
  }


  Future<void> pickFileAndGenerate(BuildContext context,
      QuizProvider quizProvider,
      FetchDataFromJsonProvider fetchDataFromJsonProvider,
      AiCreditProvider aiCreditProvider,
      Future<String> pickAndExtractText(),) async {
    showLoadingDialog(context, text: "Please wait...");
    extractedText = await pickAndExtractText();

    if (handleExtractedTextError(context, extractedText)) {
      final questions = await AIQuestionGenerator.generateQuestionsFromFile(
        extractedText,
        fetchDataFromJsonProvider.model,
        fetchDataFromJsonProvider.quiz_question_type,
        fetchDataFromJsonProvider.ListOfMaxLength,
      );

      var random = Random();
      int randomNumber = 30 +
          random.nextInt(31); // Generates a number between 30 and 60

      Future.delayed(Duration(seconds: randomNumber), () {
        isTimeOut = true;
        notifyListeners();
      });

      Future.delayed(Duration(seconds: 10), () {
        if (questions.isNotEmpty && !isTimeOut ) {

          final quizSetName = quizProvider.nameController.text.isEmpty ? "Newly Created ${quizProvider.quizSets.length}" : quizProvider.nameController.text;


          quizProvider.addQuizSet({
            'name': quizSetName,
            'timestamp': DateTime.now(),
            'description': 'Generated Quiz content From File',
            'cards': [],
            'numberOfQuiz': 0,
            'limitNumberOfQuiz': fetchDataFromJsonProvider.ListOfMaxLength,
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

          String formatQuestions(questions) {
            return questions.map((q) => 'Q: ${q['question']}\nA: ${q['answer']}').join('\n\n');
          }

          String formattedText = formatQuestions(questions);

          Provider.of<HistoryProvider>(context,listen: false).addHistory(
            {
              'title': quizSetName,
              'content': formattedText,
              'created_at': DateTime.now(),
              'favorite': false,
            }

          );
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);

          for (int i = 0; i <
              fetchDataFromJsonProvider.listOfMaxLength.length; i++) {
            if (fetchDataFromJsonProvider.listOfMaxLength[i] ==
                fetchDataFromJsonProvider
                    .ListOfMaxLength) // Check if value matches maxLength
                {
              int creditAmount = i + 1; // Use index +1 as credit amount
              aiCreditProvider.useCredit(creditAmount);
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Successfully Created Generated Quiz "),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 10),
              content: Text(
                  "It seems there’s no internet connection. Please try again or choose another model."),
              backgroundColor: Colors.red,
            ),
          );
          showAuthDialog(context, "Error",
              "Weak internet connection or choose another model");
        }
      });
    }


    isTimeOut = false;
    notifyListeners();
  }

  Future<void> GenerateFlashCardFromCustomTopic(BuildContext context,
      QuizProvider quizProvider,
      FetchDataFromJsonProvider fetchDataFromJsonProvider,
      AiCreditProvider aiCreditProvider) async {
    if (topic.isEmpty) {
      notifyListeners();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Required Topic"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final questions = await AIQuestionGenerator.generateQuestionsFromCustom(
      topic,
      description,
      fetchDataFromJsonProvider.model,
      fetchDataFromJsonProvider.quiz_question_type,
      fetchDataFromJsonProvider.ListOfMaxLength,
    );

    print(questions);
    var random = Random();
    int randomNumber = 30 +
        random.nextInt(15); // Generates a number between 30 and 60

    Future.delayed(Duration(seconds: randomNumber), () {
      isTimeOut = true;
      notifyListeners();
    });


    Future.delayed(Duration(seconds: 10), () {
      if (questions.isNotEmpty && !isTimeOut) {


        final quizSetName = quizProvider.nameController.text.isEmpty ? "Newly Created ${quizProvider.quizSets.length}" : quizProvider.nameController.text;


        quizProvider.addQuizSet({
          'name': quizSetName,
          'timestamp': DateTime.now(),
          'description': 'Generated Quiz content From Ai',
          'cards': [],
          'numberOfQuiz': 0,
          'limitNumberOfQuiz': fetchDataFromJsonProvider.ListOfMaxLength,
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

        String formatQuestions(questions) {
          return questions.map((q) => 'Q: ${q['question']}\nA: ${q['answer']}').join('\n\n');
        }

        String formattedText = formatQuestions(questions);

        Provider.of<HistoryProvider>(context,listen: false).addHistory(
            {
              'title': quizSetName,
              'content': formattedText,
              'created_at': DateTime.now(),
              'favorite': false,
            }

        );

        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

        for (int i = 0; i <
            fetchDataFromJsonProvider.listOfMaxLength.length; i++) {
          if (fetchDataFromJsonProvider.listOfMaxLength[i] ==
              fetchDataFromJsonProvider
                  .ListOfMaxLength) // Check if value matches maxLength
              {
            int creditAmount = i + 1; // Use index +1 as credit amount
            aiCreditProvider.useCredit(creditAmount);
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Successfully Created AI Generated Quiz "),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 10),
            content: Text(
                "Error in getting response , Try again with another topic/prompt"),
            backgroundColor: Colors.red,
          ),
        );
        showAuthDialog(context,type: "error", "Error",
            "It seems there’s no internet connection. Please try again or choose another model.");
      }
    });

    isTimeOut = false;
    notifyListeners();
  }

  Future<void> showFlashcardDialog(
    BuildContext context,
    QuizProvider quizProvider,
    ColorScheme colorScheme,
    FetchDataFromJsonProvider fetchDataFromJsonProvider,
    AiCreditProvider aiCreditProvider,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a quiz',
                style: Theme.of(sheetContext)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose where your study material comes from.',
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(sheetContext)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 18),
              _generationOption(
                context: sheetContext,
                icon: Icons.edit_note_rounded,
                title: 'Create manually',
                subtitle: 'Build a quiz set and add your own Q&A cards.',
                onTap: () {
                  Navigator.pop(sheetContext);
                  CreateSetBottomModal(
                    context: context,
                    buttonName: 'Create set',
                    isCreate: true,
                    setName: '',
                  );
                },
              ),
              _generationOption(
                context: sheetContext,
                icon: Icons.auto_awesome_rounded,
                title: 'Generate from a topic',
                subtitle: 'Tell Flashi what you want to study and let AI draft the set.',
                onTap: () async {
                  if (!await _prepareGeneration(
                    context,
                    fetchDataFromJsonProvider,
                  )) {
                    return;
                  }
                  if (!sheetContext.mounted) return;
                  Navigator.pop(sheetContext);
                  ModelSelectionDialog.show(
                    context,
                    true,
                    onTap: () => showTopicDialog(
                      context,
                      onTap: () => GenerateFlashCardFromCustomTopic(
                        context,
                        quizProvider,
                        fetchDataFromJsonProvider,
                        aiCreditProvider,
                      ),
                    ),
                  );
                },
              ),
              _generationOption(
                context: sheetContext,
                icon: Icons.description_outlined,
                title: 'Import PDF or DOCX',
                subtitle: 'Extract text from a study file and generate questions automatically.',
                onTap: () async {
                  if (!await _prepareGeneration(
                    context,
                    fetchDataFromJsonProvider,
                  )) {
                    return;
                  }
                  if (!sheetContext.mounted) return;
                  Navigator.pop(sheetContext);
                  ModelSelectionDialog.show(
                    context,
                    false,
                    onTap: () async {
                      await pickFileAndGenerate(
                        context,
                        quizProvider,
                        fetchDataFromJsonProvider,
                        aiCreditProvider,
                        () => FileTextExtractor.pickAndExtractText(),
                      );
                    },
                  );
                },
              ),
              _generationOption(
                context: sheetContext,
                icon: Icons.document_scanner_outlined,
                title: 'Scan a photo',
                subtitle: 'Capture or choose a page and turn the visible text into a quiz.',
                onTap: () async {
                  if (!await _prepareGeneration(
                    context,
                    fetchDataFromJsonProvider,
                  )) {
                    return;
                  }
                  if (!sheetContext.mounted) return;
                  Navigator.pop(sheetContext);
                  ModelSelectionDialog.show(
                    context,
                    false,
                    onTap: () async {
                      await pickFileAndGenerate(
                        context,
                        quizProvider,
                        fetchDataFromJsonProvider,
                        aiCreditProvider,
                        () async => AIQuestionGenerator.analyzeImage(
                          FileTextExtractor.pickOrCaptureImage(context),
                          'Get the text in image',
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _prepareGeneration(
    BuildContext context,
    FetchDataFromJsonProvider fetchDataFromJsonProvider,
  ) async {
    final connected = await InternetConnection().hasInternetAccess;
    if (!connected) {
      if (context.mounted) {
        showAuthDialog(
          context,
          type: 'error',
          'No connection',
          'Connect to the internet to generate a quiz with AI.',
        );
      }
      return false;
    }

    try {
      await Future.wait([
        fetchLatestVersion(),
        fetchDataFromJsonProvider.fetchLatestVersion(),
      ]);
    } catch (_) {
      if (context.mounted) {
        showAuthDialog(
          context,
          type: 'error',
          'Service unavailable',
          'Flashi could not refresh the AI configuration. Please try again.',
        );
      }
      return false;
    }

    if (isUnderMaintenance) {
      if (context.mounted) {
        showAuthDialog(
          context,
          type: 'warning',
          'AI is under maintenance',
          reasonMaintenance.isEmpty
              ? 'AI generation is temporarily unavailable.'
              : reasonMaintenance,
        );
      }
      return false;
    }

    return true;
  }

  Widget _generationOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withOpacity(0.14)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurface.withOpacity(0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool handleExtractedTextError(BuildContext context, String extractedText) {
  final Map<String, Map<String, String>> errorMessages = {
    "Invalid file": {
      "title": "Invalid File",
      "message": "Only PDF and DOCX files are allowed. Please try again.",
      "snackbar": "Please select a valid file first"
    },
    "Error reading file": {
      "title": "Error reading file",
      "message": "Only PDF and DOCX files are allowed. Please try again.",
      "snackbar": "Error reading file"
    },
    "Unsupported file format": {
      "title": "Unsupported file format",
      "message": "Unsupported file format. Only PDF and DOCX files are allowed. Please try again.",
      "snackbar": "Unsupported file format"
    },
    "No file selected": {
      "title": "No file",
      "message": "No file selected. Select DOCX or PDF file only.",
      "snackbar": "No file selected"
    },
    "Permission denied. Please allow access to continue.": {
      "title": "Permission",
      "message": "Permission denied. Please allow access to continue.",
      "snackbar": "Permission denied. Please allow access to continue."
    },
    "Error: No image selected.": {
      "title": "No Image",
      "message": "Please select an image first.",
      "snackbar": "Please select an image first.",
    },
  };

  if (errorMessages.containsKey(extractedText)) {
    Navigator.pop(context);
    showAuthDialog(type: "warning",context, "warning", errorMessages[extractedText]!["snackbar"]!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessages[extractedText]!["snackbar"]!),
        backgroundColor: Colors.red,
      ),
    );
    return false; // Return false if an error is found
  }

  return true; // Return true if no error
}
