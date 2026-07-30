import 'package:flutter/material.dart';
import 'package:flashi/core/design_system/app_semantic_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math';

class DailyQuestionDialog extends StatefulWidget {
  final List<Map<String, String>> questions;

  const DailyQuestionDialog({super.key, required this.questions});

  @override
  State<DailyQuestionDialog> createState() => _DailyQuestionDialogState();
}

class _DailyQuestionDialogState extends State<DailyQuestionDialog> {
  final FlutterTts flutterTts = FlutterTts();
  late List<Map<String, String>> questions;
  int currentIndex = 0;
  bool isAnswered = false;
  String? selectedAnswer;
  Timer? _timer;
  Timer? _feedbackTimer;
  Timer? _nextQuestionTimer;
  int timeLeft = 20;
  List<String> choices = [];

  @override
  void initState() {
    super.initState();
    questions = widget.questions.isNotEmpty
        ? widget.questions
        : [
            {
              "question": "No daily question available.",
              "correct_answer": "",
              "fake_choice_1": "",
              "fake_choice_2": "",
              "fake_choice_3": ""
            }
          ];
    questions.shuffle(Random());
    _loadQuestion();
  }

  void _loadQuestion() {
    _feedbackTimer?.cancel();
    _nextQuestionTimer?.cancel();
    setState(() {
      isAnswered = false;
      selectedAnswer = null;
      timeLeft = 20;
      _shuffleChoices();
    });
    _startTimer();
    _speakText(questions[currentIndex]["question"] ?? "");
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        _nextQuestion();
      }
    });
  }

  void _speakText(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  void _selectAnswer(String choice) {
    if (isAnswered) return;

    setState(() {
      isAnswered = true;
      selectedAnswer = choice;
    });

    if (choice == questions[currentIndex]["correct_answer"]) {
      _speakText("Correct!");
    } else {
      _speakText("Wrong answer.");
      _feedbackTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        _speakText(
            "The correct answer is ${questions[currentIndex]["correct_answer"]}");
      });
    }

    _nextQuestionTimer?.cancel();
    _nextQuestionTimer = Timer(const Duration(seconds: 5), _nextQuestion);
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
      _loadQuestion();
    } else {
      Navigator.pop(context);
      flutterTts.stop();
    }
  }

  void _shuffleChoices() {
    choices = [
      questions[currentIndex]["correct_answer"] ?? "",
      questions[currentIndex]["fake_choice_1"] ?? "",
      questions[currentIndex]["fake_choice_2"] ?? "",
      questions[currentIndex]["fake_choice_3"] ?? ""
    ];
    choices.shuffle(Random());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackTimer?.cancel();
    _nextQuestionTimer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;
    final questionData = questions[currentIndex];

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
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: 400.ms,
              transitionBuilder: (widget, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 0.5), end: Offset.zero)
                      .animate(animation),
                  child: widget,
                ),
              ),
              child: Text(
                questionData["question"] ?? "No question available.",
                key: ValueKey(currentIndex),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: timeLeft <= 5
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '$timeLeft seconds remaining',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: timeLeft <= 5 ? FontWeight.w700 : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: choices.map((choice) {
                Color buttonColor = theme.colorScheme.primary;
                Color contentColor = theme.colorScheme.onPrimary;
                IconData? feedbackIcon;
                String? feedbackLabel;
                if (isAnswered) {
                  if (choice == questionData["correct_answer"]) {
                    buttonColor = semantic.successContainer;
                    contentColor = semantic.onSuccessContainer;
                    feedbackIcon = Icons.check_circle_rounded;
                    feedbackLabel = 'Correct';
                  } else if (choice == selectedAnswer) {
                    buttonColor = theme.colorScheme.errorContainer;
                    contentColor = theme.colorScheme.onErrorContainer;
                    feedbackIcon = Icons.cancel_rounded;
                    feedbackLabel = 'Incorrect';
                  }
                }

                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        if (isAnswered) {
                          return buttonColor;
                        }
                        return theme.colorScheme.primary;
                      }),
                      foregroundColor:
                          WidgetStatePropertyAll<Color>(contentColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 14)),
                    ),
                    onPressed: isAnswered ? null : () => _selectAnswer(choice),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          choice,
                          style: TextStyle(
                            color: contentColor,
                            fontSize: choice.length > 20
                                ? 12
                                : (choice.length > 10 ? 14 : 16),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (feedbackIcon != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(feedbackIcon, size: 16, color: contentColor),
                              const SizedBox(width: 4),
                              Text(
                                feedbackLabel!,
                                style: TextStyle(
                                  color: contentColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                flutterTts.stop();
                Navigator.pop(context);
              },
              icon: Icon(Icons.close, color: theme.colorScheme.primary),
              label: Text("Close",
                  style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
