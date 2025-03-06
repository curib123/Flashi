import 'dart:convert';
import 'dart:math';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/api/ai/core/ai_question_generator.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/model_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_maintenace_alert_box.dart';
import 'package:flashi/util/helpers/classes/other/file_text_extractor.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_topic_dialog.dart';
import 'package:flashi/util/helpers/widget/modals/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

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
      Future<String> pickAndExtractText(),

      ) async {

    showLoadingDialog(context,text:   "AI is processing... Please wait...");
    extractedText = await pickAndExtractText();

    if ( handleExtractedTextError(context, extractedText)) {
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
        if (questions.isNotEmpty && !isTimeOut) {
          final quizSetName = 'AI Generated From File ${quizProvider.quizSets
              .length + 1}';
          quizProvider.addQuizSet({
            'name': quizSetName,
            'timestamp': DateTime.now(),
            'description': 'AI Generated Flashcard content using PDF/docs file',
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
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);

          for (int i = 0; i < fetchDataFromJsonProvider.listOfMaxLength.length; i++)
          {
            if (fetchDataFromJsonProvider.listOfMaxLength[i] == fetchDataFromJsonProvider.ListOfMaxLength) // Check if value matches maxLength
                {
              int creditAmount = i + 1; // Use index +1 as credit amount
              aiCreditProvider.useCredit(creditAmount);
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Successfully Created AI Generated Flashcard using pdf/docs"),
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
          showMaintenanceDialog(context, 'Try Again',
              "It seems there’s no internet connection. Please try again or choose another model.");
        }
      });
    }


      isTimeOut = false;
      notifyListeners();
    }

  Future<void> GenerateFlashCardFromCustomTopic(BuildContext context,
      QuizProvider quizProvider,
      FetchDataFromJsonProvider fetchDataFromJsonProvider,AiCreditProvider aiCreditProvider) async {
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
    int randomNumber = 60 +
        random.nextInt(31); // Generates a number between 30 and 60

    Future.delayed(Duration(seconds: randomNumber), () {
      isTimeOut = true;
      notifyListeners();
    });


    Future.delayed(Duration(seconds: 10), () {
      if (questions.isNotEmpty && !isTimeOut) {
        String title = "Ai Generated ${topic} ${quizProvider.quizSets.length +
            1}";

        quizProvider.addQuizSet({
          'name': title,
          'timestamp': DateTime.now(),
          'description': "Ai Generated Flashcard of ${topic}",
          'cards': [],
          'numberOfQuiz': 0,
          'limitNumberOfQuiz': fetchDataFromJsonProvider.ListOfMaxLength,
        });

        for (var questionData in questions) {
          quizProvider.addCardToQuizSet(
            quizSetName: title,
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
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

        for (int i = 0; i < fetchDataFromJsonProvider.listOfMaxLength.length; i++)
        {
          if (fetchDataFromJsonProvider.listOfMaxLength[i] == fetchDataFromJsonProvider.ListOfMaxLength) // Check if value matches maxLength
              {
            int creditAmount = i + 1; // Use index +1 as credit amount
            aiCreditProvider.useCredit(creditAmount);
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Successfully Created AI Generated Flashcard"),
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
        showMaintenanceDialog(context, 'Try Again',
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
      AiCreditProvider aiCreditProvider
      ) async {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {

        void _fetchDataFromJson(){
          fetchLatestVersion();
          fetchDataFromJsonProvider.fetchLatestVersion();
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                    "Choose Flashcard",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Create your own flashcard, let AI generate one for you, or extract from a PDF/Docs file!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogButton(
                      icon: Icons.style_rounded,
                      context,
                      label: "Create Own Flashcard",
                      gradientColors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.5)
                      ],
                      onPressed: () {
                        Navigator.pop(context);
                        CreateSetBottomModal(
                          context: context,
                          buttonName: 'Save',
                          isCreate: true,
                          setName: '',
                        );
                      },
                    ),
                    _buildDialogButton(
                      icon: Icons.auto_awesome,
                      context,
                      label: "Custom AI-Generated ",
                      gradientColors: [
                        colorScheme.secondary,
                        colorScheme.secondary.withOpacity(0.5)
                      ],
                      onPressed: () async {

                        bool isConnected =
                        await InternetConnection().hasInternetAccess;
                        if (!isConnected && !isFetchData) {
                          showMaintenanceDialog(
                            context,
                            'No Internet',
                            "Please connect to the internet to generate a flashcard.",
                          );
                          return;
                        }else{
                          _fetchDataFromJson();
                        }
                        if (!isUnderMaintenance) {
                          ModelSelectionDialog.show(
                            context,
                            true,
                            onTap: () => showTopicDialog(context, onTap: () {
                              GenerateFlashCardFromCustomTopic(
                                  context, quizProvider, fetchDataFromJsonProvider,aiCreditProvider);
                            }),
                          );
                        } else {
                          showMaintenanceDialog(context, 'Under Maintenance',
                              reasonMaintenance);
                        }
                      },
                    ),
                    _buildDialogButton(
                      icon: Icons.file_copy_rounded,
                      context,
                      label: "AI-Generated From Pdf/Docs",
                      gradientColors: [
                        colorScheme.tertiary,
                        colorScheme.tertiary.withOpacity(0.5)
                      ],
                      onPressed: () async {

                        bool isConnected =
                        await InternetConnection().hasInternetAccess;
                        if (!isConnected && !isFetchData) {
                          showMaintenanceDialog(
                            context,
                            'No Internet',
                            "Please connect to the internet to generate a flashcard.",
                          );
                          return;
                        }else{
                          _fetchDataFromJson();
                        }
                        if (!isUnderMaintenance) {
                          ModelSelectionDialog.show(
                            context,
                            false,
                            onTap: () async {
                              await pickFileAndGenerate(
                                context,
                                quizProvider,
                                fetchDataFromJsonProvider,
                                aiCreditProvider,
                                    () async {
                                  return await FileTextExtractor.pickAndExtractText();
                                },
                              );
                            },

                          );
                        } else {
                          showMaintenanceDialog(context, 'Under Maintenance',
                              reasonMaintenance);
                        }
                      },
                    ),

                    _buildDialogButton(
                      icon: Icons.picture_in_picture,
                      context,
                      label: "AI-Generated From Image",
                      gradientColors: [
                        colorScheme.tertiary,
                        colorScheme.tertiary.withOpacity(0.5)
                      ],
                      onPressed: () async {
                        bool isConnected =
                        await InternetConnection().hasInternetAccess;
                        if (!isConnected && !isFetchData) {
                          showMaintenanceDialog(
                            context,
                            'No Internet',
                            "Please connect to the internet to generate a flashcard.",
                          );
                          return;
                        }else{
                          _fetchDataFromJson();
                        }
                        if (!isUnderMaintenance) {
                          ModelSelectionDialog.show(
                            context,
                            false,
                            onTap: () async {
                              await pickFileAndGenerate(
                                context,
                                quizProvider,
                                fetchDataFromJsonProvider,
                                aiCreditProvider,
                                    () async {
                                  return await AIQuestionGenerator.analyzeImage( FileTextExtractor.pickOrCaptureImage(context), "Get the text in image");
                                },
                              );
                            },

                          );
                        } else {
                          showMaintenanceDialog(context, 'Under Maintenance',
                              reasonMaintenance);
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget _buildDialogButton(BuildContext context, {
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
    IconData? icon, // Optional icon parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 10), // Space between icon and text
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    showMaintenanceDialog(
      context,
      errorMessages[extractedText]!["title"]!,
      errorMessages[extractedText]!["message"]!,
    );
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
