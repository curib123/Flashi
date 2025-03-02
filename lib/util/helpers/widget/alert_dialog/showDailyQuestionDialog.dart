import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

void showDailyQuestionDialog(BuildContext context, {required List<Map<String, String>> questions}) {
  final theme = Theme.of(context);
  final FlutterTts flutterTts = FlutterTts();

  if (questions.isEmpty) {
    questions = [
      {
        "question": "No daily question available.",
        "correct_answer": "",
        "fake_choice_1": "",
        "fake_choice_2": "",
        "fake_choice_3": ""
      }
    ];
  }

  questions.shuffle(Random()); // Shuffle questions
  int currentIndex = 0;
  bool isAnswered = false;
  String? selectedAnswer;

  void speakText(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  speakText(questions[currentIndex]["question"] ?? "");

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final questionData = questions[currentIndex];
          List<String> choices = [
            questionData["correct_answer"] ?? "",
            questionData["fake_choice_1"] ?? "",
            questionData["fake_choice_2"] ?? "",
            questionData["fake_choice_3"] ?? ""
          ];
          choices.shuffle(Random());

          void selectAnswer(String choice) {
            if (isAnswered) return;

            setState(() {
              isAnswered = true;
              selectedAnswer = choice;
            });

            if (choice == questionData["correct_answer"]) {
              speakText("Correct!");
            } else {
              speakText("Wrong answer.");
              Future.delayed(Duration(seconds: 2), () {
                speakText("The correct answer is ${questionData["correct_answer"]}");
              });
            }

            Future.delayed(Duration(seconds: 5), () {
              setState(() {
                if (currentIndex < questions.length - 1) {
                  currentIndex++;
                  isAnswered = false;
                  selectedAnswer = null;
                  speakText(questions[currentIndex]["question"] ?? "");
                } else {
                  Navigator.pop(context);
                  flutterTts.stop();
                }
              });
            });
          }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Daily Quiz",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ).animate().fadeIn(duration: 300.ms),
                  SizedBox(height: 16),

                  AnimatedSwitcher(
                    duration: 400.ms,
                    transitionBuilder: (widget, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(animation),
                        child: widget,
                      ),
                    ),
                    child: Text(
                      questionData["question"] ?? "No question available.",
                      key: ValueKey(currentIndex),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
                    ),
                  ),
                  SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: choices.map((choice) {
                      Color buttonColor = theme.colorScheme.primary;
                      if (isAnswered) {
                        if (choice == questionData["correct_answer"]) {
                          buttonColor = Colors.green;
                        } else if (choice == selectedAnswer) {
                          buttonColor = Colors.red;
                        }
                      }

                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                              if (isAnswered) {
                                return buttonColor; // Keep color when disabled
                              }
                              return theme.colorScheme.primary;
                            }),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 14)),
                          ),
                          onPressed: isAnswered ? null : () => selectAnswer(choice),
                          child: Text(
                            choice,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: choice.length > 20 ? 12 : (choice.length > 10 ? 14 : 16),
                            ),
                            textAlign: TextAlign.center,
                          ),

                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 20),

                  TextButton.icon(
                    onPressed: () {
                      flutterTts.stop();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, color: theme.colorScheme.primary),
                    label: Text("Close", style: TextStyle(color: theme.colorScheme.primary)),
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
