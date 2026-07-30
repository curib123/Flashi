import 'dart:async';
import 'dart:convert';
import 'package:flashi/core/config/app_environment.dart';
import 'package:flashi/features/ai/application/ai_credit_provider.dart';
import 'package:flashi/features/ai/application/generation_config_provider.dart';
import 'package:flashi/features/history/application/history_provider.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/features/ai/data/services/ai_question_generator.dart';
import 'package:flashi/shared/dialogs/message_dialog.dart';
import 'package:flashi/shared/dialogs/loading_dialog.dart';
import 'package:flashi/features/ai/presentation/dialogs/model_selection_dialog.dart';
import 'package:flashi/features/ai/data/services/file_text_extractor.dart';
import 'package:flashi/features/ai/presentation/dialogs/topic_prompt_dialog.dart';
import 'package:flashi/features/quiz/presentation/dialogs/quiz_set_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class AiGenerationProvider extends ChangeNotifier {
  AiGenerationProvider({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client(),
        _ownsHttpClient = httpClient == null;

  final http.Client _httpClient;
  final bool _ownsHttpClient;
  int _generationRevision = 0;
  static const Duration _generationTimeout = Duration(seconds: 60);

  String extractedText = "";
  String topic = "";
  String description = "";
  bool isUnderMaintenance = false;
  String reasonMaintenance = '';
  bool isFetchData = false;
  bool isGenerating = false;
  String? errorMessage;

  void updateTopicAndDescription(String newTopic, String newDescription) {
    if (topic == newTopic && description == newDescription) return;
    topic = newTopic;
    description = newDescription;
    notifyListeners();
  }

  Future<void> fetchLatestVersion() async {
    try {
      final response =
          await _httpClient.get(Uri.parse(AppEnvironment.releaseConfigUrl));
      if (response.statusCode != 200) {
        throw http.ClientException(
          'Maintenance configuration returned ${response.statusCode}.',
        );
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      isUnderMaintenance = data['under_maintenance'] == true;
      reasonMaintenance = data['reason_maintenance_ai']?.toString() ?? '';
      isFetchData = true;
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> pickFileAndGenerate(
    BuildContext context,
    QuizProvider quizProvider,
    GenerationConfigProvider fetchDataFromJsonProvider,
    AiCreditProvider aiCreditProvider,
    HistoryProvider historyProvider,
    Future<String> Function() pickAndExtractText,
  ) async {
    final int revision = _beginGeneration();
    extractedText = await pickAndExtractText();
    if (revision != _generationRevision || !context.mounted) return;

    if (!handleExtractedTextError(context, extractedText)) {
      _finishGeneration(revision);
      return;
    }

    showLoadingDialog(context, text: 'Generating quiz from your file...');
    try {
      final questions = await AiQuestionGenerator.generateQuestionsFromFile(
        extractedText,
        fetchDataFromJsonProvider.model,
        fetchDataFromJsonProvider.quizQuestionType,
        fetchDataFromJsonProvider.maxLength,
      ).timeout(_generationTimeout);
      if (revision != _generationRevision || !context.mounted) return;
      if (questions.isEmpty) {
        throw const FormatException('No valid questions were generated.');
      }

      final quizSetName = _saveGeneratedQuiz(
        quizProvider: quizProvider,
        historyProvider: historyProvider,
        config: fetchDataFromJsonProvider,
        questions: questions,
        sourceDescription: 'Generated quiz from file',
      );
      aiCreditProvider.useCredit(fetchDataFromJsonProvider.creditsPerLength);
      _closeGenerationDialogs(context);
      _showSuccess(context, quizSetName);
    } on TimeoutException {
      if (context.mounted) {
        _showGenerationError(
          context,
          'Generation took too long. Check your connection and try again.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showGenerationError(
          context,
          'No valid questions were generated. Try clearer source material or another model.',
        );
      }
    } finally {
      _finishGeneration(revision);
    }
  }

  Future<void> generateFlashCardsFromCustomTopic(
      BuildContext context,
      QuizProvider quizProvider,
      GenerationConfigProvider fetchDataFromJsonProvider,
      AiCreditProvider aiCreditProvider,
      HistoryProvider historyProvider) async {
    final int revision = _beginGeneration();
    if (topic.isEmpty) {
      _finishGeneration(revision);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Required Topic"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final questions = await AiQuestionGenerator.generateQuestionsFromCustom(
        topic,
        description,
        fetchDataFromJsonProvider.model,
        fetchDataFromJsonProvider.quizQuestionType,
        fetchDataFromJsonProvider.maxLength,
      ).timeout(_generationTimeout);
      if (revision != _generationRevision || !context.mounted) return;
      if (questions.isEmpty) {
        throw const FormatException('No valid questions were generated.');
      }

      final quizSetName = _saveGeneratedQuiz(
        quizProvider: quizProvider,
        historyProvider: historyProvider,
        config: fetchDataFromJsonProvider,
        questions: questions,
        sourceDescription: 'AI-generated quiz',
      );
      aiCreditProvider.useCredit(fetchDataFromJsonProvider.creditsPerLength);
      _closeGenerationDialogs(context);
      _showSuccess(context, quizSetName);
    } on TimeoutException {
      if (context.mounted) {
        _showGenerationError(
          context,
          'Generation took too long. Check your connection and try again.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showGenerationError(
          context,
          'No valid questions were generated. Refine the topic or try another model.',
        );
      }
    } finally {
      _finishGeneration(revision);
    }
  }

  int _beginGeneration() {
    final int revision = ++_generationRevision;
    isGenerating = true;
    errorMessage = null;
    notifyListeners();
    return revision;
  }

  void _finishGeneration(int revision) {
    if (revision != _generationRevision) return;
    isGenerating = false;
    notifyListeners();
  }

  String _saveGeneratedQuiz({
    required QuizProvider quizProvider,
    required HistoryProvider historyProvider,
    required GenerationConfigProvider config,
    required List<Map<String, String>> questions,
    required String sourceDescription,
  }) {
    final quizSetName = _uniqueQuizSetName(quizProvider);
    final createdAt = DateTime.now();
    final cards = questions
        .map(
          (question) => <String, dynamic>{
            'isUpdating': false,
            'question': question['question']!,
            'answer': question['answer']!,
            'fake_choice_1': question['fake_choice_1'] ?? '',
            'fake_choice_2': question['fake_choice_2'] ?? '',
            'fake_choice_3': question['fake_choice_3'] ?? '',
            'isIgnore': false,
            'keyword': '',
            'timestamp': createdAt,
          },
        )
        .toList(growable: false);

    quizProvider.addQuizSet({
      'name': quizSetName,
      'timestamp': createdAt,
      'description': sourceDescription,
      'cards': cards,
      'numberOfQuiz': cards.length,
      'limitNumberOfQuiz': config.maxLength,
    });
    historyProvider.addHistory({
      'title': quizSetName,
      'content': questions
          .map((question) =>
              'Q: ${question['question']}\nA: ${question['answer']}')
          .join('\n\n'),
      'created_at': createdAt,
      'favorite': false,
    });
    quizProvider.clearController();
    return quizSetName;
  }

  String _uniqueQuizSetName(QuizProvider quizProvider) {
    final requestedName = quizProvider.nameController.text.trim();
    final baseName = requestedName.isEmpty ? 'Generated Quiz' : requestedName;
    final existingNames = quizProvider.quizSets
        .map((set) => set['name']?.toString().toLowerCase())
        .toSet();
    if (!existingNames.contains(baseName.toLowerCase())) return baseName;

    var suffix = 2;
    while (existingNames.contains('$baseName ($suffix)'.toLowerCase())) {
      suffix++;
    }
    return '$baseName ($suffix)';
  }

  void _closeGenerationDialogs(BuildContext context) {
    Navigator.of(context).popUntil((route) => route is! PopupRoute);
  }

  void _showSuccess(BuildContext context, String quizSetName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$quizSetName created successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showGenerationError(BuildContext context, String message) {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> showFlashcardDialog(
      BuildContext context,
      QuizProvider quizProvider,
      ColorScheme colorScheme,
      GenerationConfigProvider fetchDataFromJsonProvider,
      AiCreditProvider aiCreditProvider,
      HistoryProvider historyProvider) async {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        void fetchConfiguration() {
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
                    "Create a quiz",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                      "Start with the material you already have.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
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
                      label: "Create manually",
                      description: "Write your own questions and answers.",
                      onPressed: () {
                        Navigator.pop(context);
                        showQuizSetFormSheet(
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
                      label: "Generate from topic",
                      description:
                          "Describe a subject and let Flashi draft the quiz.",
                      onPressed: () async {
                        bool isConnected =
                            await InternetConnection().hasInternetAccess;
                        if (!context.mounted) return;
                        if (!isConnected && !isFetchData) {
                          showMessageDialog(
                              context,
                              type: "error",
                              "Error",
                              "Please connect to the internet to generate a Quiz.");

                          return;
                        } else {
                          fetchConfiguration();
                        }
                        if (!isUnderMaintenance) {
                          ModelSelectionDialog.show(
                            context,
                            true,
                            onTap: () => showTopicDialog(context, onTap: () {
                              generateFlashCardsFromCustomTopic(
                                  context,
                                  quizProvider,
                                  fetchDataFromJsonProvider,
                                  aiCreditProvider,
                                  historyProvider);
                            }),
                          );
                        } else {
                          showMessageDialog(
                              context,
                              type: "error",
                              "Error",
                              "Under maintenance\n$reasonMaintenance");
                        }
                      },
                    ),
                    _buildDialogButton(
                      icon: Icons.file_copy_rounded,
                      context,
                      label: "Import a document",
                      description: "Generate from a PDF or DOCX file.",
                      onPressed: () async {
                        bool isConnected =
                            await InternetConnection().hasInternetAccess;
                        if (!context.mounted) return;
                        if (!isConnected && !isFetchData) {
                          showMessageDialog(
                              context,
                              type: "error",
                              "Error",
                              "Please connect to the internet to generate a Quiz.");
                          return;
                        } else {
                          fetchConfiguration();
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
                                historyProvider,
                                () async {
                                  return await FileTextExtractor
                                      .pickAndExtractText();
                                },
                              );
                            },
                          );
                        } else {
                          showMessageDialog(
                              context,
                              type: "error",
                              "Error",
                              "Under maintenance\n$reasonMaintenance");
                        }
                      },
                    ),
                    _buildDialogButton(
                      icon: Icons.image_outlined,
                      context,
                      label: "Scan an image",
                      description:
                          "Use a photo, screenshot, or camera capture.",
                      onPressed: () async {
                        bool isConnected =
                            await InternetConnection().hasInternetAccess;
                        if (!context.mounted) return;
                        if (!isConnected && !isFetchData) {
                          showMessageDialog(
                              context,
                              type: "error",
                              "Error",
                              "Please connect to the internet to generate a Quiz.");

                          return;
                        } else {
                          fetchConfiguration();
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
                                historyProvider,
                                () async {
                                  return await AiQuestionGenerator.analyzeImage(
                                      FileTextExtractor.pickOrCaptureImage(
                                          context),
                                      "Get the text in image");
                                },
                              );
                            },
                          );
                        } else {
                          showMessageDialog(
                              context,
                              type: "error",
                              "Error",
                              "Under maintenance\n$reasonMaintenance");
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

  Widget _buildDialogButton(
    BuildContext context, {
    required String label,
    required String description,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 22),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(description,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _generationRevision++;
    if (_ownsHttpClient) _httpClient.close();
    super.dispose();
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
      "message":
          "Unsupported file format. Only PDF and DOCX files are allowed. Please try again.",
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

  Map<String, String>? error;
  for (final entry in errorMessages.entries) {
    if (extractedText.startsWith(entry.key)) {
      error = entry.value;
      break;
    }
  }
  if (extractedText.trim().isEmpty) {
    error = const {
      'snackbar': 'The selected file did not contain readable text.',
    };
  }

  if (error != null) {
    showMessageDialog(type: "warning", context, "warning", error["snackbar"]!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error["snackbar"]!),
        backgroundColor: Colors.red,
      ),
    );
    return false; // Return false if an error is found
  }

  return true; // Return true if no error
}
