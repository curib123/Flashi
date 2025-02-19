import 'dart:convert';
import 'dart:math';
import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/api/ai/core/ai_question_generator.dart';
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
  bool isLoading = false;
  bool isUnderMaintenance = false;
  String reasonMaintenance = '';
  bool isFetchData = false;
  bool isTimeOut = false;

  void updateIsLoading(){
    isLoading = !isLoading;
    notifyListeners();
  }

  void updateTopicAndDescription(String newTopic,String newDescription) {
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
      QuizProvider quizProvider,FetchDataFromJsonProvider fetchDataFromJsonProvider) async {

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

    final questions = await AIQuestionGenerator.generateQuestionsFromFile(
      extractedText,
      fetchDataFromJsonProvider.model,
      fetchDataFromJsonProvider.quiz_question_type,
      fetchDataFromJsonProvider.maxLength,
    );

    var random = Random();
    int randomNumber = 60 +
        random.nextInt(31); // Generates a number between 30 and 60

    Future.delayed(Duration(seconds: randomNumber), () {
      isTimeOut = true;
      notifyListeners();
    });

   Future.delayed(Duration(seconds: 10),(){

     if (questions.isNotEmpty && !isTimeOut) {
       final quizSetName = 'AI Generated From File ${quizProvider.quizSets.length + 1}';
       quizProvider.addQuizSet({
         'name': quizSetName,
         'timestamp': DateTime.now(),
         'description': 'AI Generated Flashcard content using PDF/docs file',
         'cards': [],
         'numberOfQuiz': 0,
         'limitNumberOfQuiz': fetchDataFromJsonProvider.maxLength,
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
       updateIsLoading();
       Navigator.pop(context);
       Navigator.pop(context);
       Navigator.pop(context);

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

    isTimeOut = false;
    notifyListeners();
  }

  Future<void> GenerateFlashCardFromCustomTopic(BuildContext context,
      QuizProvider quizProvider, FetchDataFromJsonProvider fetchDataFromJsonProvider) async {

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
      fetchDataFromJsonProvider.maxLength,
    );

    print(questions);
    var random = Random();
    int randomNumber = 60 +
        random.nextInt(31); // Generates a number between 30 and 60

    Future.delayed(Duration(seconds: randomNumber), () {
      isTimeOut = true;
      notifyListeners();
    });


    Future.delayed(Duration(seconds: 10),(){
      if (questions.isNotEmpty && !isTimeOut) {

        String title =  "Ai Generated ${topic} ${quizProvider.quizSets.length + 1}";

        quizProvider.addQuizSet({
          'name':title,
          'timestamp': DateTime.now(),
          'description': "Ai Generated Flashcard of ${topic}",
          'cards': [],
          'numberOfQuiz': 0,
          'limitNumberOfQuiz': fetchDataFromJsonProvider.maxLength,
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
        updateIsLoading();
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
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

  Future<void> showFlashcardDialog(BuildContext context,
      QuizProvider quizProvider,
      ColorScheme colorScheme,
      FetchDataFromJsonProvider fetchDataFromJsonProvider) async {
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
              titlePadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.all(20),
              title: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: Text(
                        "Choose Flashcard",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                     "Create a custom flashcard or generate one using AI or generate from a PDF/Docs file.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
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
                      context,
                      label: "Basic Flashcard",
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
                      context,
                      label: "AI-Generated Flashcard",
                      gradientColors: [
                        colorScheme.secondary,
                        colorScheme.secondary.withOpacity(0.5)
                      ],
                      onPressed: () async {
                        bool isConnected = await InternetConnection()
                            .hasInternetAccess;
                        if (!isConnected && !isFetchData) {
                          showMaintenanceDialog(
                            context,
                            'No Internet',
                            "Please connect to the internet to generate a flashcard.",
                          );
                          return;
                        }
                        if (!isUnderMaintenance) {
                          ModelSelectionDialog.show(
                            context,
                            true,
                            onTap: () => showTopicDialog(context, onTap: () {
                              GenerateFlashCardFromCustomTopic(context, quizProvider, fetchDataFromJsonProvider);
                            })
                            ,
                          );
                        } else {
                          showMaintenanceDialog(context, 'Under Maintenance', reasonMaintenance);
                        }

                      },
                    ),

                    _buildDialogButton(
                      context,
                      label: "AI Flashcard from PDF/Docs",
                      gradientColors: [colorScheme.tertiary, colorScheme.tertiary.withOpacity(0.5)],
                      // Fixed gradient
                      onPressed: () async {
                        bool isConnected = await InternetConnection()
                            .hasInternetAccess;
                        if (!isConnected && !isFetchData) {
                          showMaintenanceDialog(
                            context,
                            'No Internet',
                            "Please connect to the internet to generate a flashcard.",
                          );
                          return;
                        }
                        if (!isUnderMaintenance) {
                          ModelSelectionDialog.show(
                            context,
                            false,
                            onTap: () async {
                              await pickFileAndGenerate(
                                  context, quizProvider, fetchDataFromJsonProvider);
                            },
                          );
                        } else {
                          showMaintenanceDialog(context, 'Under Maintenance',
                              reasonMaintenance);
                        }
                      },
                    ),

                    _buildDialogButton(
                      context,
                      label: "Cancel",
                      gradientColors: [
                        colorScheme.error,
                        colorScheme.error.withOpacity(0.5)
                      ],
                      onPressed: () {
                        Navigator.pop(context);
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
    required List<Color> gradientColors, // List of colors for the gradient
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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