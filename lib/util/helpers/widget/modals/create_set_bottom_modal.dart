import 'package:flashi/provider/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void CreateSetBottomModal({
  required BuildContext context,
  required String buttonName,
  required bool isCreate,
  required String setName,
}) {
  final provider = context.read<QuizProvider>();

  if (isCreate) {
    provider.nameController.clear();
    provider.descriptionController.clear();
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (sheetContext) {
      return Consumer<QuizProvider>(
        builder: (context, quiz, child) {
          final bottom = MediaQuery.of(context).viewInsets.bottom;
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.fromLTRB(20, 4, 20, bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isCreate ? 'Create quiz set' : 'Edit quiz set',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isCreate
                        ? 'Give the set a clear name so it is easy to find later.'
                        : 'Update the name or description without changing its cards.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: quiz.nameController,
                    autofocus: isCreate,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Quiz set name',
                      hintText: 'e.g. Biology Chapter 4',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quiz.descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Optional study context',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        final name = quiz.nameController.text.trim();
                        final description =
                            quiz.descriptionController.text.trim();

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Add a quiz set name first.'),
                            ),
                          );
                          return;
                        }

                        if (isCreate) {
                          quiz.addQuizSet({
                            'name': name,
                            'timestamp': DateTime.now(),
                            'description': description,
                            'cards': <Map<String, dynamic>>[],
                            'numberOfQuiz': 0,
                            'limitNumberOfQuiz': quiz.defaultMaxCards,
                            'favorite': false,
                          });
                        } else {
                          quiz.editQuizSet(
                            setName,
                            newName: name,
                            newDescription: description,
                          );
                        }

                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isCreate
                                  ? 'Quiz set created.'
                                  : 'Quiz set updated.',
                            ),
                          ),
                        );
                      },
                      icon: Icon(isCreate ? Icons.add_rounded : Icons.save_rounded),
                      label: Text(isCreate ? buttonName : 'Save changes'),
                    ),
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
