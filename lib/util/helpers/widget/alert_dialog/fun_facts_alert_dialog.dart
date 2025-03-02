import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:flashi/provider/fun_facts_provider.dart';

void showFunFactDialog(BuildContext context, {required List<String> facts}) {
  final theme = Theme.of(context);
  final FlutterTts flutterTts = FlutterTts();
  final funFactsProvider = Provider.of<FunFactsProvider>(context, listen: false);

  List<String> remainingFacts = List.from(facts.isNotEmpty ? facts : ["No fun facts available."]);
  int currentIndex = 0;

  void speakFact(String fact) async {
    await flutterTts.stop();
    await flutterTts.speak(fact);
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Speak the first fact after the dialog is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            speakFact(remainingFacts[currentIndex]);
          });

          void showNextFact() {
            if (remainingFacts.isNotEmpty && currentIndex < remainingFacts.length) {
              funFactsProvider.removeFunFactAt(currentIndex); // Remove from storage
              setState(() {
                remainingFacts.removeAt(currentIndex); // Remove from UI
                if (currentIndex >= remainingFacts.length) {
                  currentIndex = 0; // Reset if last item was removed
                }
              });
              if (remainingFacts.isNotEmpty) {
                speakFact(remainingFacts[currentIndex]);
              } else {
                flutterTts.stop();
                Navigator.pop(context); // Close dialog if no facts remain
              }
            }
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
                    "Daily Fun Facts",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  SizedBox(height: 16),
                  Icon(
                    Icons.lightbulb_outline,
                    size: 80,
                    color: theme.colorScheme.secondary,
                  ).animate().scale(duration: 400.ms).fadeIn(duration: 300.ms),
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
                      remainingFacts.isNotEmpty ? remainingFacts[currentIndex] : "No fun facts available.",
                      key: ValueKey(currentIndex),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: remainingFacts.isNotEmpty && remainingFacts[currentIndex].length < 80 ? 20 : 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          flutterTts.stop();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close, color: theme.colorScheme.primary),
                        label: Text("Close", style: TextStyle(color: theme.colorScheme.primary)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: remainingFacts.length > 1
                              ? theme.colorScheme.primary
                              : Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: remainingFacts.length > 1 ? showNextFact : null,
                        icon: Icon(Icons.arrow_forward, color: theme.colorScheme.onPrimary),
                        label: Text("Next", style: TextStyle(color: theme.colorScheme.onPrimary)),
                      ),
                    ],
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
