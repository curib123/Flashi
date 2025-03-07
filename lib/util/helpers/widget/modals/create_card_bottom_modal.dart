
import 'package:flashi/presentation/widget/components/create_set_buttons.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_textfield_core.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
void CreateCardBottomModal({
  required BuildContext context,
  required String buttonName,
  required bool isCreate,
  required String cardName,
  required String name,
  required Map<String, dynamic> card
}) {
  final colorScheme = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    isScrollControlled: true, // Allows controlling the modal's height
    builder: (BuildContext context) {
      // Determine the keyboard height to adjust the modal content
      double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      return Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {


          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            height: 400 + keyboardHeight, // Fixed height, adjusting for the keyboard
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight), // Padding adjusts with keyboard height
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ensures the modal doesn't stretch more than necessary
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      isCreate ? "Create Card " : 'Edit Card',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis, // Handles text overflow
                      ),
                      maxLines: 1, // Ensures the title doesn't wrap onto multiple lines
                    ),
                  ),
                  const SizedBox(height: 30),
                  // TextField for Set Name
                  ReusableTextfieldCore(
                    name: "Question",
                    controller: quizProvider.questionController,
                  ),
                  const SizedBox(height: 20),
                  // TextField for Description
                  ReusableTextfieldCore(
                    name: "Answer",
                    controller: quizProvider.answerController,
                  ),
                  const SizedBox(height: 30),
                  // Button to Create Set
                  CreateSetButtons(
                    createBtn: () {
                      // Get the input data from the text controllers
                      final String question = quizProvider.questionController.text;
                      final String answer = quizProvider.answerController.text;

                      // Add the new set to the provider
                      if (question.isNotEmpty) {
                        if (isCreate) {
                            quizProvider.addCardToQuizSet(quizSetName: name,card:  {
                              'isUpdating' : false,
                              'question' : question,
                              'answer'   : answer,
                              'isIgnore'   : false,
                              'keyword'   : '',
                              'timestamp' : DateTime.now()
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Card Successfully Added"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            quizProvider.clearController();
                        } else {
                          quizProvider.updateCardInQuizSet( quizSetName: name, oldQuestion: card['question'], newQuestion: question, newAnswer: answer);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Succesfully Updated'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          quizProvider.clearController();
                        }

                        // Close the modal
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Required Question'),
                            backgroundColor: Colors.red,
                          ),
                        );

                      }
                    },
                    buttonName: isCreate ? buttonName : 'Save Changes',
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
