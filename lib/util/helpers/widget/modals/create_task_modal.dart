
import 'package:flashi/presentation/widget/components/create_set_buttons.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_textfield_core.dart';
import 'package:flashi/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
void CreateTaskModal({
  required BuildContext context,
  required String buttonName,
  required bool isCreate,
  required String taskName,
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

      return Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (isCreate) taskProvider.clearController();

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            height: 350 + keyboardHeight, // Fixed height, adjusting for the keyboard
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight), // Padding adjusts with keyboard height
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ensures the modal doesn't stretch more than necessary
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      isCreate ? "Add Task Today " : 'Edit The Task: $taskName',
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
                    name: "Task Name",
                    controller: taskProvider.taskNameController,
                  ),

                  const SizedBox(height: 30),
                  // Button to Create Set
                  CreateSetButtons(
                    createBtn: () {
                      // Get the input data from the text controllers
                      final String taskNameInput = taskProvider.taskNameController.text;

                      // Add the new set to the provider
                      if (taskNameInput.isNotEmpty) {
                        if (isCreate) {
                         taskProvider.addTask({
                           'isChecked': false,
                           'taskName': taskNameInput,
                           'dateTime': DateTime.now(),
                           'isUpdated': false,
                         });
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text("New Task Successfully Added"),
                             backgroundColor: Colors.green,
                           ),
                         );
                        } else {
                         taskProvider.updateTask(taskName, taskNameInput);
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text("Task Successfully Edited"),
                             backgroundColor: Colors.green,
                           ),
                         );
                        }

                        // Close the modal
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("required inputs"),
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
