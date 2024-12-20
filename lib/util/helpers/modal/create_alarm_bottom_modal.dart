import 'package:flashlearn/presentation/widget/components/create_set_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flashlearn/provider/alarm_provider.dart';
import 'package:flashlearn/provider/quiz_provider.dart';

void CreateAlarmBottomModal({
  required BuildContext context,
  required String buttonName,
  required bool isCreate,
  required String title,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    isScrollControlled: true,
    builder: (BuildContext context) {
      double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      return Consumer2<AlarmProvider, QuizProvider>(
        builder: (context, alarmProvider, quizProvider, child) {
          DateTime selectedDateTime = DateTime.now();
          List<String> dropdownOptions = quizProvider.getNamesFromQuizSets(); // Dropdown options
          String selectedDropdownValue = dropdownOptions.isNotEmpty ? dropdownOptions.first : 'Empty'; // Default value for dropdown

          // Ensure the selected value is one of the available options
          if (!dropdownOptions.contains(selectedDropdownValue)) {
            selectedDropdownValue = dropdownOptions.isNotEmpty ? dropdownOptions.first : 'Empty';
          }

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            height: 480 + keyboardHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

               Align(
                 alignment: Alignment.topLeft,
                 child:  // Dropdown
                 Text(
                   'Select SetName To Alarm',
                   style: TextStyle(
                     color: colorScheme.secondary.withOpacity(.8),
                     fontSize: 16,
                     fontWeight: FontWeight.w600,
                   ),
                 ),
               ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedDropdownValue,
                  items: dropdownOptions.map<DropdownMenuItem<String>>((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedDropdownValue = newValue;
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Date and Time Picker


                Align(
                  alignment: Alignment.topLeft,
                  child:  // Dropdown
                  Text(
                    'Select Study Time',
                    style: TextStyle(
                      color: colorScheme.secondary.withOpacity(.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.calendar_today, color: Colors.white),
                    ),
                    title: Text(
                      "Select Date & Time",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        );

                        if (pickedTime != null) {
                          selectedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selected Date & Time: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime)}',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                CreateSetButtons(createBtn: () {
                  // Ensure selectedDateTime is properly defined and passed
                  Duration remainingTime = selectedDateTime.difference(DateTime.now());

                  // Calculate the status based on remaining time
                  String status = '';
                  if (remainingTime.isNegative) {
                    status = "Completed";
                  } else if (remainingTime.inDays > 0) {
                    status = "Upcoming";
                  } else {
                    status = "Today";
                  }

                  // Check if this is a create action
                  if (isCreate) {
                    // Add the alarm with calculated status
                    alarmProvider.addAlarm({
                      'goalTime': selectedDateTime,  // Ensure selectedDateTime is correctly initialized
                      'setName': selectedDropdownValue,  // Ensure selectedDropdownValue is passed and initialized
                      'dateCreated': DateTime.now(),
                      'status': status,  // Use the calculated status here
                    });
                  } else {
                    // Handle update or other actions here if needed
                    // For example, updating an existing alarm
                    // alarmProvider.updateAlarm(existingAlarmId, updatedAlarm);
                  }

                  // Close the dialog or navigate back
                  Navigator.pop(context);
                }, buttonName: buttonName)


              ],
            ),
          );
        },
      );
    },
  );
}
