import 'dart:async';
import 'dart:convert';

import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/fetch_data_from_json_provider.dart';
import 'package:flashi/provider/history_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/api/ai/core/ai_question_generator.dart';
import 'package:flashi/util/helpers/classes/other/file_text_extractor.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/model_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_topic_dialog.dart';
import 'package:flashi/util/helpers/widget/modals/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class AiModelLogicProvider extends ChangeNotifier {
  static const _configUrl =
      'https://curib123.github.io/flashi_/flashi.json';
  static const _requestTimeout = Duration(seconds: 75);

  String extractedText = '';
  String topic = '';
  String description = '';
  bool isUnderMaintenance = false;
  String reasonMaintenance = '';
  bool isFetchData = false;

  /// Retained for compatibility with older widgets. It now represents a real
  /// request timeout instead of a random timer race.
  bool isTimeOut = false;

  void updateTopicAndDescription(String newTopic, String newDescription) {
    topic = newTopic.trim();
    description = newDescription.trim();
    notifyListeners();
  }

  Future<void> fetchLatestVersion() async {
    final response = await http
        .get(Uri.parse(_configUrl))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw StateError(
        'Flashi configuration request failed (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid Flashi configuration payload.');
    }

    isUnderMaintenance = decoded['under_maintenance'] == true;
    reasonMaintenance =
        (decoded['reason_maintenance_ai'] ?? '').toString().trim();
    isFetchData = true;
    notifyListeners();
  }

  Future<void> pickFileAndGenerate(
    BuildContext context,
    QuizProvider quizProvider,
    FetchDataFromJsonProvider fetchDataFromJsonProvider,
    AiCreditProvider aiCreditProvider,
    Future<String> Function() pickAndExtractText,
  ) async {
    isTimeOut = false;

    try {
      extractedText = await pickAndExtractText().timeout(
        const Duration(seconds: 45),
      );
    } on TimeoutException {
      if (context.mounted) {
        showAuthDialog(
          context,
          'Reading took too long',
          'Try the file or image again. If it is large, use a smaller source.',
          type: 'error',
        );
      }
      return;
    } catch (_) {
      if (context.mounted) {
        showAuthDialog(
          context,
          'Could not read source',
          'Flashi could not extract study text from that source.',
          type: 'error',
        );
      }
      return;
    }

    if (!context.mounted ||
        !handleExtractedTextError(context, extractedText)) {
      return;
    }

    await _generateAndSave(
      context: context,
      quizProvider: quizProvider,
      config: fetchDataFromJsonProvider,
      credits: aiCreditProvider,
      description: 'Generated from imported study material',
      loadingText: 'Creating your quiz…',
      generate: () => AIQuestionGenerator.generateQuestionsFromFile(
        extractedText,
        fetchDataFromJsonProvider.model,
        fetchDataFromJsonProvider.quiz_question_type,
        fetchDataFromJsonProvider.ListOfMaxLength,
      ),
    );
  }

  Future<void> GenerateFlashCardFromCustomTopic(
    BuildContext context,
    QuizProvider quizProvider,
    FetchDataFromJsonProvider fetchDataFromJsonProvider,
    AiCreditProvider aiCreditProvider,
  ) async {
    if (topic.isEmpty || description.isEmpty) {
      if (context.mounted) {
        showAuthDialog(
          context,
          'Topic required',
          'Add both a topic and a short description before generating.',
          type: 'warning',
        );
      }
      return;
    }

    await _generateAndSave(
      context: context,
      quizProvider: quizProvider,
      config: fetchDataFromJsonProvider,
      credits: aiCreditProvider,
      description: 'AI-generated quiz from a topic',
      loadingText: 'Flashi is creating your quiz…',
      generate: () => AIQuestionGenerator.generateQuestionsFromCustom(
        topic,
        description,
        fetchDataFromJsonProvider.model,
        fetchDataFromJsonProvider.quiz_question_type,
        fetchDataFromJsonProvider.ListOfMaxLength,
      ),
    );
  }

  Future<void> _generateAndSave({
    required BuildContext context,
    required QuizProvider quizProvider,
    required FetchDataFromJsonProvider config,
    required AiCreditProvider credits,
    required String description,
    required String loadingText,
    required Future<List<Map<String, String>>> Function() generate,
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    final history = context.read<HistoryProvider>();

    isTimeOut = false;
    notifyListeners();
    showLoadingDialog(context, text: loadingText);

    try {
      final questions = await generate().timeout(_requestTimeout);

      if (navigator.mounted && navigator.canPop()) {
        navigator.pop();
      }

      if (questions.isEmpty) {
        if (context.mounted) {
          showAuthDialog(
            context,
            'No quiz generated',
            'The AI did not return usable questions. Try another model, source, or prompt.',
            type: 'error',
          );
        }
        return;
      }

      final setName = quizProvider.nameController.text.trim().isEmpty
          ? 'Study Set ${quizProvider.quizSets.length + 1}'
          : quizProvider.nameController.text.trim();

      quizProvider.addQuizSet({
        'name': setName,
        'timestamp': DateTime.now(),
        'description': description,
        'cards': <dynamic>[],
        'numberOfQuiz': 0,
        'limitNumberOfQuiz': config.ListOfMaxLength,
      });

      for (final question in questions) {
        quizProvider.addCardToQuizSet(
          quizSetName: setName,
          card: {
            'isUpdating': false,
            'question': question['question'] ?? '',
            'answer': question['answer'] ?? '',
            'isIgnore': false,
            'keyword': '',
            'timestamp': DateTime.now(),
          },
        );
      }

      history.addHistory({
        'title': setName,
        'content': _formatQuestions(questions),
        'created_at': DateTime.now(),
        'favorite': false,
      });

      await credits.useCredit(_creditCost(config));
      quizProvider.nameController.clear();

      if (messenger.mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Quiz created successfully'),
            ),
          );
      }
    } on TimeoutException {
      isTimeOut = true;
      if (navigator.mounted && navigator.canPop()) {
        navigator.pop();
      }
      if (context.mounted) {
        showAuthDialog(
          context,
          'Request timed out',
          'The AI took too long to respond. Check your connection or try another model.',
          type: 'error',
        );
      }
    } catch (_) {
      if (navigator.mounted && navigator.canPop()) {
        navigator.pop();
      }
      if (context.mounted) {
        showAuthDialog(
          context,
          'Generation failed',
          'Flashi could not create the quiz. Try again or choose another model.',
          type: 'error',
        );
      }
    } finally {
      notifyListeners();
    }
  }

  int _creditCost(FetchDataFromJsonProvider config) {
    if (config.creditsPerLength > 0) return config.creditsPerLength;

    final index = config.listOfMaxLength.indexOf(config.ListOfMaxLength);
    if (index >= 0) return index + 1;

    final fallback = config.ListOfMaxLength ~/ 10;
    return fallback < 1 ? 1 : fallback;
  }

  String _formatQuestions(List<Map<String, String>> questions) {
    return questions
        .map(
          (question) =>
              'Q: ${question['question'] ?? ''}\nA: ${question['answer'] ?? ''}',
        )
        .join('\n\n');
  }

  Future<void> showFlashcardDialog(
    BuildContext context,
    QuizProvider quizProvider,
    ColorScheme colorScheme,
    FetchDataFromJsonProvider fetchDataFromJsonProvider,
    AiCreditProvider aiCreditProvider,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: FlashiDesign.surfaceOf(context),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a quiz',
                style: Theme.of(sheetContext)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.4,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose where your study material comes from.',
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: FlashiDesign.mutedOf(sheetContext),
                    ),
              ),
              const SizedBox(height: 18),
              _generationOption(
                context: sheetContext,
                icon: Icons.edit_note_rounded,
                title: 'Create manually',
                subtitle: 'Build a set and add your own questions and answers.',
                onTap: () {
                  Navigator.pop(sheetContext);
                  CreateSetBottomModal(
                    context: context,
                    buttonName: 'Create set',
                    isCreate: true,
                    setName: '',
                  );
                },
              ),
              _generationOption(
                context: sheetContext,
                icon: Icons.auto_awesome_rounded,
                title: 'Generate from a topic',
                subtitle:
                    'Describe what you want to study and let Flashi draft it.',
                onTap: () async {
                  if (!await _prepareGeneration(
                    context,
                    fetchDataFromJsonProvider,
                  )) {
                    return;
                  }
                  if (!sheetContext.mounted) return;

                  Navigator.pop(sheetContext);
                  ModelSelectionDialog.show(
                    context,
                    true,
                    onTap: () => showTopicDialog(
                      context,
                      onTap: () => GenerateFlashCardFromCustomTopic(
                        context,
                        quizProvider,
                        fetchDataFromJsonProvider,
                        aiCreditProvider,
                      ),
                    ),
                  );
                },
              ),
              _generationOption(
                context: sheetContext,
                icon: Icons.description_outlined,
                title: 'Import PDF or DOCX',
                subtitle: 'Turn text from a study file into a focused quiz.',
                onTap: () async {
                  if (!await _prepareGeneration(
                    context,
                    fetchDataFromJsonProvider,
                  )) {
                    return;
                  }
                  if (!sheetContext.mounted) return;

                  Navigator.pop(sheetContext);
                  ModelSelectionDialog.show(
                    context,
                    false,
                    onTap: () => pickFileAndGenerate(
                      context,
                      quizProvider,
                      fetchDataFromJsonProvider,
                      aiCreditProvider,
                      FileTextExtractor.pickAndExtractText,
                    ),
                  );
                },
              ),
              _generationOption(
                context: sheetContext,
                icon: Icons.document_scanner_outlined,
                title: 'Scan a photo',
                subtitle:
                    'Capture or choose a page and turn visible text into a quiz.',
                onTap: () async {
                  if (!await _prepareGeneration(
                    context,
                    fetchDataFromJsonProvider,
                  )) {
                    return;
                  }
                  if (!sheetContext.mounted) return;

                  Navigator.pop(sheetContext);
                  ModelSelectionDialog.show(
                    context,
                    false,
                    onTap: () => pickFileAndGenerate(
                      context,
                      quizProvider,
                      fetchDataFromJsonProvider,
                      aiCreditProvider,
                      () => AIQuestionGenerator.analyzeImage(
                        FileTextExtractor.pickOrCaptureImage(context),
                        'Extract the study text from this image.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _prepareGeneration(
    BuildContext context,
    FetchDataFromJsonProvider fetchDataFromJsonProvider,
  ) async {
    final connected = await InternetConnection().hasInternetAccess;
    if (!connected) {
      if (context.mounted) {
        showAuthDialog(
          context,
          'No connection',
          'Connect to the internet to generate a quiz with AI.',
          type: 'error',
        );
      }
      return false;
    }

    try {
      await Future.wait([
        fetchLatestVersion(),
        fetchDataFromJsonProvider.fetchLatestVersion(),
      ]).timeout(const Duration(seconds: 20));
    } catch (_) {
      final hasCachedConfig =
          fetchDataFromJsonProvider.listOfModels.isNotEmpty &&
          fetchDataFromJsonProvider.listOfQuizQuestionTypes.isNotEmpty &&
          fetchDataFromJsonProvider.listOfMaxLength.isNotEmpty;

      if (!hasCachedConfig) {
        if (context.mounted) {
          showAuthDialog(
            context,
            'Service unavailable',
            'Flashi could not load the AI configuration. Please try again.',
            type: 'error',
          );
        }
        return false;
      }
    }

    if (isUnderMaintenance) {
      if (context.mounted) {
        showAuthDialog(
          context,
          'AI is under maintenance',
          reasonMaintenance.isEmpty
              ? 'AI generation is temporarily unavailable.'
              : reasonMaintenance,
          type: 'warning',
        );
      }
      return false;
    }

    return true;
  }

  Widget _generationOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: FlashiDesign.surfaceOf(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FlashiDesign.borderOf(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FlashiDesign.primarySoftOf(context),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: FlashiDesign.brand),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.35,
                            color: FlashiDesign.mutedOf(context),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: FlashiDesign.mutedOf(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool handleExtractedTextError(BuildContext context, String extractedText) {
  const knownErrors = <String, String>{
    'Invalid file': 'Please select a valid PDF or DOCX file.',
    'Error reading file': 'Flashi could not read that file.',
    'Unsupported file format': 'Only PDF and DOCX files are supported.',
    'No file selected': 'No file was selected.',
    'Permission denied. Please allow access to continue.':
        'Allow file or photo access to continue.',
    'Error: No image selected.': 'No image was selected.',
    'Error: API key is missing.': 'The AI service is not configured.',
  };

  final knownMessage = knownErrors[extractedText];
  final genericError =
      extractedText.startsWith('Error:') || extractedText.startsWith('Exception:');

  if (knownMessage == null && !genericError && extractedText.trim().isNotEmpty) {
    return true;
  }

  final message = knownMessage ??
      (extractedText.trim().isEmpty
          ? 'No readable text was found in that source.'
          : 'Flashi could not read that source. Please try another one.');

  showAuthDialog(
    context,
    'Could not use source',
    message,
    type: 'warning',
  );
  return false;
}
