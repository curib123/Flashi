import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/util/helpers/widget/modals/create_set_bottom_modal.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/generation_provider.dart';
import 'package:flashi/provider/history_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

Future<void> showStudyGeneratorSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => _CreateModeSheet(hostContext: context),
  );
}

class _CreateModeSheet extends StatelessWidget {
  final BuildContext hostContext;

  const _CreateModeSheet({required this.hostContext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create study set',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Build it manually offline, or use Luna to generate from your study material.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: FlashiDesign.mutedOf(context),
                ),
          ),
          const SizedBox(height: 18),
          _ModeTile(
            icon: Icons.edit_note_rounded,
            title: 'Create manually',
            subtitle: 'Works fully offline. Add your own questions and answers.',
            onTap: () {
              Navigator.pop(context);
              CreateSetBottomModal(
                context: hostContext,
                buttonName: 'Create set',
                isCreate: true,
                setName: '',
              );
            },
          ),
          _ModeTile(
            icon: Icons.auto_awesome_rounded,
            title: 'Generate from a topic',
            subtitle: 'Describe a subject and generate a structured study set.',
            onTap: () => _openAi(context, 'topic'),
          ),
          _ModeTile(
            icon: Icons.description_outlined,
            title: 'Generate from PDF or document',
            subtitle: 'Upload PDF, DOC, DOCX, TXT, RTF, ODT, or Markdown.',
            onTap: () => _openAi(context, 'file'),
          ),
          _ModeTile(
            icon: Icons.document_scanner_outlined,
            title: 'Generate from notes image',
            subtitle: 'Use a photo or screenshot of handwritten or printed notes.',
            onTap: () => _openAi(context, 'image'),
          ),
        ],
      ),
    );
  }

  void _openAi(BuildContext context, String sourceType) {
    Navigator.pop(context);
    showModalBottomSheet<void>(
      context: hostContext,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _AiGeneratorSheet(sourceType: sourceType),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: FlashiDesign.borderOf(context)),
            borderRadius: BorderRadius.circular(16),
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
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: FlashiDesign.mutedOf(context),
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiGeneratorSheet extends StatefulWidget {
  final String sourceType;

  const _AiGeneratorSheet({required this.sourceType});

  @override
  State<_AiGeneratorSheet> createState() => _AiGeneratorSheetState();
}

class _AiGeneratorSheetState extends State<_AiGeneratorSheet> {
  static const quizTypes = <String, String>{
    'multiple_choice': 'Multiple choice',
    'identification': 'Identification',
    'true_false': 'True or false',
    'definition': 'Definition',
    'fill_blank': 'Fill in the blank',
    'enumeration': 'Enumeration',
  };

  final _topicController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _setNameController = TextEditingController();

  String _quizType = 'identification';
  int _count = 10;
  File? _sourceFile;

  @override
  void dispose() {
    _topicController.dispose();
    _descriptionController.dispose();
    _setNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final credits = context.watch<AiCreditProvider>();
    final generation = context.watch<GenerationProvider>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        2,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'AI generation uses GPT-5.6 Luna on the Flashi backend. Your API key is never stored in this app.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FlashiDesign.mutedOf(context),
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 16),
            if (!auth.signedIn) _SignInCard(auth: auth),
            if (auth.signedIn) ...[
              _EnergyCard(credits: credits),
              const SizedBox(height: 14),
              TextField(
                controller: _setNameController,
                decoration: const InputDecoration(
                  labelText: 'Set name (optional)',
                  hintText: 'Luna can name it automatically',
                ),
              ),
              const SizedBox(height: 14),
              if (widget.sourceType == 'topic') ...[
                TextField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    labelText: 'Topic',
                    hintText: 'e.g. Database normalization',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Study scope or notes',
                    alignLabelWithHint: true,
                    hintText: 'What should the generated questions cover?',
                  ),
                ),
              ] else
                _SourcePicker(
                  sourceType: widget.sourceType,
                  selectedFile: _sourceFile,
                  onChanged: (file) => setState(() => _sourceFile = file),
                ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _quizType,
                decoration: const InputDecoration(labelText: 'Quiz type'),
                items: quizTypes.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: generation.busy
                    ? null
                    : (value) => setState(() => _quizType = value ?? _quizType),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: _count,
                decoration: const InputDecoration(labelText: 'Questions'),
                items: const [10, 20, 30, 40, 50]
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value.toString() +
                              ' questions · ' +
                              (value ~/ 10).toString() +
                              ' energy',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: generation.busy
                    ? null
                    : (value) => setState(() => _count = value ?? _count),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: generation.busy ? null : _generate,
                  icon: generation.busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(generation.busy ? 'Generating…' : 'Generate study set'),
                ),
              ),
              if (generation.error != null) ...[
                const SizedBox(height: 10),
                Text(
                  generation.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String get _title {
    switch (widget.sourceType) {
      case 'file':
        return 'Generate from document';
      case 'image':
        return 'Generate from notes image';
      default:
        return 'Generate from topic';
    }
  }

  Future<void> _generate() async {
    final generation = context.read<GenerationProvider>();

    if (widget.sourceType == 'topic') {
      if (_topicController.text.trim().isEmpty ||
          _descriptionController.text.trim().isEmpty) {
        _show('Add a topic and study scope first.');
        return;
      }
    } else if (_sourceFile == null) {
      _show('Choose a study source first.');
      return;
    }

    try {
      final response = widget.sourceType == 'topic'
          ? await generation.generateTopic(
              topic: _topicController.text.trim(),
              description: _descriptionController.text.trim(),
              quizType: _quizType,
              count: _count,
            )
          : await generation.generateFromFile(
              file: _sourceFile!,
              quizType: _quizType,
              count: _count,
              image: widget.sourceType == 'image',
            );

      if (!mounted) return;
      _store(response);
      context.read<AiCreditProvider>().setBalance(
            (response['credits'] as num?)?.toInt() ?? 0,
          );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Study set generated and saved offline.')),
      );
    } catch (error) {
      if (mounted) _show(error.toString());
    }
  }

  void _store(Map<String, dynamic> response) {
    final result = Map<String, dynamic>.from(response['result'] as Map);
    final items = (result['items'] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    final generatedTitle = (result['title'] ?? 'Generated study set').toString();
    final setName = _setNameController.text.trim().isEmpty
        ? generatedTitle
        : _setNameController.text.trim();

    final quiz = context.read<QuizProvider>();
    final history = context.read<HistoryProvider>();

    quiz.addQuizSet({
      'name': setName,
      'timestamp': DateTime.now(),
      'description': 'AI generated · ' + (quizTypes[_quizType] ?? _quizType),
      'cards': <Map<String, dynamic>>[],
      'numberOfQuiz': 0,
      'limitNumberOfQuiz': _count,
      'favorite': false,
      'source': widget.sourceType,
      'quizType': _quizType,
    });

    for (final item in items) {
      quiz.addCardToQuizSet(
        quizSetName: setName,
        card: <String, dynamic>{
          'isUpdating': false,
          'question': (item['question'] ?? '').toString(),
          'answer': (item['answer'] ?? '').toString(),
          'options': List<String>.from(item['options'] as List? ?? const []),
          'explanation': (item['explanation'] ?? '').toString(),
          'quizType': _quizType,
          'isIgnore': false,
          'keyword': '',
          'timestamp': DateTime.now(),
        },
      );
    }

    history.addHistory({
      'title': setName,
      'content': items
          .map(
            (item) =>
                'Q: ' +
                (item['question'] ?? '').toString() +
                '\nA: ' +
                (item['answer'] ?? '').toString(),
          )
          .join('\n\n'),
      'created_at': DateTime.now(),
      'favorite': false,
    });
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SignInCard extends StatelessWidget {
  final AuthProvider auth;

  const _SignInCard({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlashiDesign.primaryFaintOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FlashiDesign.primarySoftOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Google sign-in required for AI',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            'Manual flashcards stay offline and do not require an account.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: FlashiDesign.mutedOf(context),
                ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: auth.busy
                ? null
                : () async {
                    final ok = await auth.signInWithGoogle();
                    if (ok && context.mounted) {
                      await context.read<AiCreditProvider>().refresh();
                    }
                  },
            icon: const Icon(Icons.login_rounded),
            label: Text(auth.busy ? 'Signing in…' : 'Continue with Google'),
          ),
          if (auth.error != null) ...[
            const SizedBox(height: 8),
            Text(
              auth.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _EnergyCard extends StatelessWidget {
  final AiCreditProvider credits;

  const _EnergyCard({required this.credits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlashiDesign.primaryFaintOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FlashiDesign.primarySoftOf(context)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: FlashiDesign.brand),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              credits.credits.toString() + ' energy',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          TextButton(
            onPressed: credits.loading
                ? null
                : () async {
                    final ok = await credits.earnReward();
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            credits.error ?? 'Reward was not completed.',
                          ),
                        ),
                      );
                    }
                  },
            child: const Text('Earn'),
          ),
        ],
      ),
    );
  }
}

class _SourcePicker extends StatelessWidget {
  final String sourceType;
  final File? selectedFile;
  final ValueChanged<File?> onChanged;

  const _SourcePicker({
    required this.sourceType,
    required this.selectedFile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => sourceType == 'image'
          ? _pickImage(context)
          : _pickDocument(),
      icon: Icon(
        sourceType == 'image'
            ? Icons.image_outlined
            : Icons.upload_file_rounded,
      ),
      label: Text(
        selectedFile == null
            ? (sourceType == 'image' ? 'Choose image' : 'Choose document')
            : selectedFile!.uri.pathSegments.last,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'txt', 'md', 'rtf', 'odt'],
    );
    final path = result?.files.single.path;
    if (path != null) onChanged(File(path));
  }

  Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 92,
    );
    if (image != null) onChanged(File(image.path));
  }
}
