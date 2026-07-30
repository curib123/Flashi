import 'package:flashi/features/quiz/presentation/widgets/create_quiz_set_actions.dart';
import 'package:flashi/shared/widgets/app_text_field.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showQuizSetFormSheet({
  required BuildContext context,
  required String buttonName,
  required bool isCreate,
  required String setName,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true, // Allows controlling the modal's height
    builder: (BuildContext context) {
      // Determine the keyboard height to adjust the modal content
      double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      return Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom:
                          keyboardHeight), // Padding adjusts with keyboard height
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // Ensures the modal doesn't stretch more than necessary
                    children: [
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          isCreate ? "Create quiz set" : 'Edit quiz set',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            overflow:
                                TextOverflow.ellipsis, // Handles text overflow
                          ),
                          maxLines:
                              1, // Ensures the title doesn't wrap onto multiple lines
                        ),
                      ),
                      const SizedBox(height: 30),
                      // TextField for Set Name
                      AppTextField(
                        name: "Quiz Set Name",
                        controller: quizProvider.nameController,
                        isHideName: false,
                      ),
                      const SizedBox(height: 20),
                      // TextField for Description
                      AppTextField(
                        isHideName: false,
                        name: "Description - Optional",
                        controller: quizProvider.descriptionController,
                      ),
                      const SizedBox(height: 30),
                      // Button to Create Set
                      CreateQuizSetActions(
                        createBtn: () {
                          // Get the input data from the text controllers
                          final String name = quizProvider.nameController.text;
                          final String description =
                              quizProvider.descriptionController.text;

                          // Add the new set to the provider
                          if (name.isNotEmpty) {
                            if (isCreate) {
                              quizProvider.addQuizSet({
                                'name': name,
                                'timestamp': DateTime.now(),
                                'description': description,
                                'cards': [],
                                'numberOfQuiz': 0,
                                'limitNumberOfQuiz':
                                    quizProvider.defaultMaxCards,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$name created')),
                              );

                              quizProvider.clearController();
                            } else {
                              quizProvider.editQuizSet(setName,
                                  newName: name, newDescription: description);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$name updated')),
                              );

                              quizProvider.clearController();
                            }

                            // Close the modal
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enter a set name')),
                            );
                          }
                        },
                        buttonName: isCreate ? buttonName : 'Save Changes',
                      ),
                    ],
                  ),
                ),
              ));
        },
      );
    },
  );
}
