import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/domain/study.dart';
import 'package:flashi/domain/study_package.dart';
import 'package:flashi/features/app_state.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/generation_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FlashiApp extends StatelessWidget {
  final AppState state;
  final AuthProvider? auth;
  final GenerationProvider? generation;
  final AiCreditProvider? credits;

  const FlashiApp({
    super.key,
    required this.state,
    this.auth,
    this.generation,
    this.credits,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashi AI',
      theme: FlashiDesign.light(),
      darkTheme: FlashiDesign.dark(),
      themeMode: ThemeMode.system,
      home: _LibraryPage(
        state: state,
        auth: auth,
        generation: generation,
        credits: credits,
      ),
    );
  }
}

class _LibraryPage extends StatelessWidget {
  final AppState state;
  final AuthProvider? auth;
  final GenerationProvider? generation;
  final AiCreditProvider? credits;

  const _LibraryPage({
    required this.state,
    this.auth,
    this.generation,
    this.credits,
  });

  @override
  Widget build(BuildContext context) {
    final listenables = <Listenable>[state];
    if (auth != null) listenables.add(auth!);
    if (generation != null) listenables.add(generation!);
    if (credits != null) listenables.add(credits!);

    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Flashi AI'),
            actions: [
              PopupMenuButton<String>(
                tooltip: 'Library actions',
                onSelected: (value) {
                  if (value == 'import') {
                    _importPackage(context);
                  } else if (value == 'backup') {
                    _shareBackup(context);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'import',
                    child: ListTile(
                      leading: Icon(Icons.file_open_outlined),
                      title: Text('Import .flashi'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'backup',
                    child: ListTile(
                      leading: Icon(Icons.ios_share_rounded),
                      title: Text('Backup & share'),
                    ),
                  ),
                ],
              ),
              if (credits != null && auth?.signedIn == true)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Center(
                    child: Chip(
                      avatar: const Icon(Icons.bolt_rounded, size: 16),
                      label: Text('${credits!.credits}'),
                    ),
                  ),
                ),
              if (auth != null)
                IconButton(
                  tooltip: auth!.signedIn ? 'Account' : 'Sign in',
                  onPressed: () => _showAccount(context),
                  icon: Icon(
                    auth!.signedIn
                        ? Icons.account_circle_rounded
                        : Icons.login_rounded,
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreate(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create'),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await state.reload();
                if (auth?.signedIn == true) await credits?.refresh();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                children: [
                  Text(
                    'Turn Notes Into Knowledge.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create manually offline, or generate editable practice from your notes with GPT-5.6 Luna.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _SummaryRow(
                    sets: state.sets.length,
                    questions: state.sets.fold<int>(
                      0,
                      (total, set) => total + set.questions.length,
                    ),
                    attempts: state.attempts.length,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Study library',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      if (state.loading)
                        const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (state.sets.isEmpty)
                    _EmptyLibrary(onCreate: () => _showCreate(context))
                  else
                    ...state.sets.map(
                      (set) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              child: Icon(
                                set.kind == SetKind.deck
                                    ? Icons.style_rounded
                                    : set.kind == SetKind.exam
                                        ? Icons.assignment_rounded
                                        : Icons.quiz_rounded,
                              ),
                            ),
                            title: Text(
                              set.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            subtitle: Text(
                              '${set.questions.length} questions · ${set.kind.name}',
                            ),
                            trailing:
                                const Icon(Icons.chevron_right_rounded),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    _SetPage(state: state, set: set),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (state.attempts.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    Text(
                      'Recent results',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    ...state.attempts.take(5).map(
                          (attempt) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              child: Text('${attempt.score}'),
                            ),
                            title: Text(attempt.title),
                            subtitle: Text(
                              '${attempt.score}% · ${attempt.mistakes.length} mistakes',
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareBackup(BuildContext context) async {
    try {
      final package = await state.repository.backup(
        creator: auth?.user?.name ?? '',
      );
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/flashi-backup-$timestamp.flashi');
      await file.writeAsString(package.encode(), flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        text: 'Flashi study backup',
      );
    } catch (error) {
      if (context.mounted) _message(context, 'Backup failed: $error');
    }
  }

  Future<void> _importPackage(BuildContext context) async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['flashi'],
        allowMultiple: false,
      );
      final path = picked?.files.single.path;
      if (path == null) return;

      final raw = await File(path).readAsString();
      final package = StudyPackage.decode(raw);
      if (!context.mounted) return;

      final action = await showDialog<ImportBehavior>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Import Flashi package?'),
          content: Text(
            '${package.sets.length} sets · ${package.questionCount} questions'
            '${package.attempts.isEmpty ? '' : ' · ${package.attempts.length} attempts'}'
            '\n\nCreator: ${package.creator.isEmpty ? 'Unknown' : package.creator}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                ImportBehavior.cancel,
              ),
              child: const Text('Cancel'),
            ),
            if (package.packageType == 'backup')
              TextButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  ImportBehavior.replace,
                ),
                child: const Text('Replace library'),
              ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                ImportBehavior.duplicate,
              ),
              child: const Text('Import copy'),
            ),
          ],
        ),
      );

      if (action == null || action == ImportBehavior.cancel) return;
      await state.repository.importPackage(
        package,
        action,
        replaceLibrary: action == ImportBehavior.replace,
      );
      await state.reload();
      if (context.mounted) _message(context, 'Flashi package imported.');
    } on FormatException catch (error) {
      if (context.mounted) _message(context, 'Invalid Flashi package: ${error.message}');
    } catch (error) {
      if (context.mounted) _message(context, 'Import failed: $error');
    }
  }

  Future<void> _showCreate(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note_rounded),
              title: const Text('Create manually'),
              subtitle: const Text('Works fully offline.'),
              onTap: () {
                Navigator.pop(sheetContext);
                _createManual(context);
              },
            ),
            if (generation != null) ...[
              ListTile(
                leading: const Icon(Icons.auto_awesome_rounded),
                title: const Text('Generate from topic'),
                subtitle: const Text('Use GPT-5.6 Luna on the Flashi backend.'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _createWithAi(context, _AiSource.topic);
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Generate from PDF or document'),
                subtitle: const Text('PDF, DOC, DOCX, TXT, RTF, ODT, Markdown.'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _createWithAi(context, _AiSource.document);
                },
              ),
              ListTile(
                leading: const Icon(Icons.document_scanner_outlined),
                title: const Text('Generate from notes image'),
                subtitle: const Text('Photo, screenshot, handwritten or printed notes.'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _createWithAi(context, _AiSource.image);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _createManual(BuildContext context) async {
    final title = TextEditingController();
    final question = TextEditingController();
    final answer = TextEditingController();
    final created = await showDialog<StudySet>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create study set'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Set title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: question,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: answer,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isEmpty ||
                  question.text.trim().isEmpty ||
                  answer.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(
                dialogContext,
                StudySet(
                  title: title.text.trim(),
                  kind: SetKind.quiz,
                  questions: [
                    StudyQuestion(
                      type: QuestionType.identification,
                      question: question.text.trim(),
                      answer: answer.text.trim(),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    title.dispose();
    question.dispose();
    answer.dispose();
    if (created != null) await state.saveSet(created);
  }

  Future<void> _createWithAi(
    BuildContext context,
    _AiSource source,
  ) async {
    if (auth?.signedIn != true) {
      final signedIn = await auth?.signInWithGoogle() ?? false;
      if (!signedIn) {
        if (context.mounted) {
          _message(context, auth?.error ?? 'Sign in with Google to use AI.');
        }
        return;
      }
      await credits?.refresh();
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => _AiGenerationDialog(
        generation: generation!,
        source: source,
      ),
    );
    if (result == null) return;

    try {
      final set = _studySetFromGeneration(result);
      await state.saveSet(set);
      credits?.applyGenerationBalance(result);
      if (context.mounted) {
        _message(context, 'Study set generated and saved offline.');
      }
    } catch (error) {
      if (context.mounted) _message(context, error.toString());
    }
  }

  Future<void> _showAccount(BuildContext context) async {
    final currentAuth = auth!;
    if (!currentAuth.signedIn) {
      final ok = await currentAuth.signInWithGoogle();
      if (ok) await credits?.refresh();
      if (!ok && context.mounted) {
        _message(context, currentAuth.error ?? 'Sign-in cancelled.');
      }
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle_rounded),
              title: Text(currentAuth.user?.name ?? 'Flashi learner'),
              subtitle: Text(currentAuth.user?.email ?? 'Signed in'),
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Sign out'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await currentAuth.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  StudySet _studySetFromGeneration(Map<String, dynamic> response) {
    final rawResult = response['result'];
    if (rawResult is! Map) throw const FormatException('Invalid generation.');
    final result = Map<String, dynamic>.from(rawResult);
    final rawQuestions = result['questions'];
    if (rawQuestions is! List || rawQuestions.isEmpty) {
      throw const FormatException('The generated study set is empty.');
    }

    final questions = rawQuestions.map((item) {
      if (item is! Map) throw const FormatException('Invalid generated item.');
      final map = Map<String, dynamic>.from(item);
      final rawPairs = map['pairs'];
      return StudyQuestion(
        id: map['id']?.toString(),
        type: _questionType(map['type']?.toString() ?? ''),
        question: map['question']?.toString() ?? '',
        answer: map['answer']?.toString() ?? '',
        options: (map['options'] as List? ?? const [])
            .map((value) => value.toString())
            .toList(),
        explanation: map['explanation']?.toString() ?? '',
        topic: map['topic']?.toString() ?? '',
        pairs: (rawPairs as List? ?? const [])
            .whereType<Map>()
            .map(
              (pair) => MatchPair(
                pair['left']?.toString() ?? '',
                pair['right']?.toString() ?? '',
              ),
            )
            .toList(),
      );
    }).toList();

    return StudySet(
      id: result['id']?.toString(),
      title: result['title']?.toString() ?? 'Generated study set',
      subject: result['subject']?.toString() ?? '',
      creator: result['creator']?.toString() ?? '',
      kind: _setKind(result['kind']?.toString()),
      difficulty: _difficulty(result['difficulty']?.toString()),
      questions: questions,
      updatedAt: DateTime.tryParse(result['updatedAt']?.toString() ?? ''),
    );
  }

  QuestionType _questionType(String value) {
    switch (value) {
      case 'flashcard':
        return QuestionType.flashcard;
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'identification':
        return QuestionType.identification;
      case 'true_false':
        return QuestionType.trueFalse;
      case 'definition':
        return QuestionType.definition;
      case 'fill_blank':
        return QuestionType.fillBlank;
      case 'matching':
        return QuestionType.matching;
      case 'question_answer':
        return QuestionType.questionAnswer;
      case 'enumeration':
        return QuestionType.enumeration;
      default:
        throw const FormatException('Unsupported generated question type.');
    }
  }

  SetKind _setKind(String? value) {
    return SetKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => SetKind.quiz,
    );
  }

  Difficulty _difficulty(String? value) {
    return Difficulty.values.firstWhere(
      (difficulty) => difficulty.name == value,
      orElse: () => Difficulty.medium,
    );
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

enum _AiSource { topic, document, image }

class _AiGenerationDialog extends StatefulWidget {
  final GenerationProvider generation;
  final _AiSource source;

  const _AiGenerationDialog({
    required this.generation,
    required this.source,
  });

  @override
  State<_AiGenerationDialog> createState() => _AiGenerationDialogState();
}

class _AiGenerationDialogState extends State<_AiGenerationDialog> {
  final topic = TextEditingController();
  final scope = TextEditingController();
  String type = 'identification';
  int count = 10;
  File? file;
  String? error;

  static const types = <String, String>{
    'multiple_choice': 'Multiple choice',
    'identification': 'Identification',
    'true_false': 'True or false',
    'definition': 'Definition',
    'fill_blank': 'Fill in the blank',
    'enumeration': 'Enumeration',
  };

  @override
  void dispose() {
    topic.dispose();
    scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.generation,
      builder: (context, _) => AlertDialog(
        title: Text(
          widget.source == _AiSource.topic
              ? 'Generate from topic'
              : widget.source == _AiSource.document
                  ? 'Generate from document'
                  : 'Generate from notes image',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.source == _AiSource.topic) ...[
                TextField(
                  controller: topic,
                  decoration: const InputDecoration(
                    labelText: 'Topic',
                    hintText: 'Database normalization',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: scope,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Study scope or notes',
                  ),
                ),
              ] else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.attach_file_rounded),
                  title: Text(
                    file == null
                        ? 'Choose source'
                        : file!.uri.pathSegments.last,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: widget.generation.busy ? null : _pickSource,
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Question type'),
                items: types.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: widget.generation.busy
                    ? null
                    : (value) => setState(() => type = value ?? type),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: count,
                decoration: const InputDecoration(labelText: 'Questions'),
                items: const [10, 20, 30, 40, 50]
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text('$value questions'),
                      ),
                    )
                    .toList(),
                onChanged: widget.generation.busy
                    ? null
                    : (value) => setState(() => count = value ?? count),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                widget.generation.busy ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: widget.generation.busy ? null : _generate,
            icon: widget.generation.busy
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(widget.generation.busy ? 'Generating…' : 'Generate'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickSource() async {
    if (widget.source == _AiSource.image) {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) setState(() => file = File(picked.path));
      return;
    }

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt', 'md'],
    );
    final path = picked?.files.single.path;
    if (path != null && mounted) setState(() => file = File(path));
  }

  Future<void> _generate() async {
    if (widget.source == _AiSource.topic &&
        (topic.text.trim().isEmpty || scope.text.trim().length < 10)) {
      setState(() => error = 'Add a topic and at least 10 characters of notes.');
      return;
    }
    if (widget.source != _AiSource.topic && file == null) {
      setState(() => error = 'Choose a study source first.');
      return;
    }

    try {
      final response = widget.source == _AiSource.topic
          ? await widget.generation.generateTopic(
              topic: topic.text.trim(),
              description: scope.text.trim(),
              quizType: type,
              count: count,
            )
          : await widget.generation.generateFromFile(
              file: file!,
              quizType: type,
              count: count,
              image: widget.source == _AiSource.image,
            );
      if (mounted) Navigator.pop(context, response);
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final int sets;
  final int questions;
  final int attempts;

  const _SummaryRow({
    required this.sets,
    required this.questions,
    required this.attempts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Metric(value: '$sets', label: 'Sets')),
        const SizedBox(width: 10),
        Expanded(child: _Metric(value: '$questions', label: 'Questions')),
        const SizedBox(width: 10),
        Expanded(child: _Metric(value: '$attempts', label: 'Attempts')),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;

  const _Metric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyLibrary({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.layers_outlined, size: 42),
            const SizedBox(height: 12),
            const Text(
              'No study sets yet',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create one manually or generate one from your notes.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onCreate,
              child: const Text('Create first set'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetPage extends StatelessWidget {
  final AppState state;
  final StudySet set;

  const _SetPage({required this.state, required this.set});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(set.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            set.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text('${set.questions.length} questions'),
          if (set.subject.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(set.subject),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: set.questions.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _QuizPage(state: state, set: set),
                      ),
                    ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Quiz'),
          ),
        ],
      ),
    );
  }
}

class _QuizPage extends StatefulWidget {
  final AppState state;
  final StudySet set;

  const _QuizPage({required this.state, required this.set});

  @override
  State<_QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<_QuizPage> {
  int index = 0;
  String response = '';
  bool checked = false;
  final records = <AnswerRecord>[];

  StudyQuestion get question => widget.set.questions[index];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.set.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Question ${index + 1} of ${widget.set.questions.length}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 20),
          ..._answerControls(),
          if (checked) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  question.explanation.isEmpty
                      ? (question.matches(response)
                          ? 'Correct.'
                          : 'Correct answer: ${question.answer}')
                      : question.explanation,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: response.isEmpty
                ? null
                : checked
                    ? _advance
                    : _check,
            child: Text(
              checked
                  ? (index == widget.set.questions.length - 1
                      ? 'Finish'
                      : 'Next')
                  : 'Check Answer',
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _answerControls() {
    if (question.type == QuestionType.multipleChoice ||
        question.type == QuestionType.trueFalse) {
      return question.options
          .map(
            (option) => RadioListTile<String>(
              value: option,
              groupValue: response.isEmpty ? null : response,
              onChanged: checked
                  ? null
                  : (value) => setState(() => response = value ?? ''),
              title: Text(option),
            ),
          )
          .toList();
    }

    if (question.type == QuestionType.matching) {
      return [
        Text(
          'Matching review: compare each pair, then type any response to self-check.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        ...question.pairs.map(
          (pair) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(pair.left),
            trailing: Text(pair.right),
          ),
        ),
        TextFormField(
          enabled: !checked,
          onChanged: (value) => setState(() => response = value),
          decoration: const InputDecoration(labelText: 'Self-check note'),
        ),
      ];
    }

    return [
      TextFormField(
        enabled: !checked,
        onChanged: (value) => setState(() => response = value),
        decoration: const InputDecoration(
          labelText: 'Your answer',
          border: OutlineInputBorder(),
        ),
      ),
    ];
  }

  void _check() {
    setState(() {
      checked = true;
      final correct = question.type == QuestionType.matching
          ? true
          : question.matches(response);
      records.add(
        AnswerRecord(
          question: question,
          response: response,
          correct: correct,
        ),
      );
    });
  }

  Future<void> _advance() async {
    if (index < widget.set.questions.length - 1) {
      setState(() {
        index++;
        response = '';
        checked = false;
      });
      return;
    }

    final attempt = StudyAttempt(
      setId: widget.set.id,
      title: widget.set.title,
      mode: 'quiz',
      answers: records,
    );
    await widget.state.saveAttempt(attempt);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _ResultPage(attempt: attempt),
      ),
    );
  }
}

class _ResultPage extends StatelessWidget {
  final StudyAttempt attempt;

  const _ResultPage({required this.attempt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${attempt.score}%',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text('${attempt.mistakes.length} mistakes'),
          const SizedBox(height: 24),
          if (attempt.mistakes.isNotEmpty)
            FilledButton.tonal(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (context) => ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Review Mistakes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...attempt.mistakes.map(
                      (record) => Card(
                        child: ListTile(
                          title: Text(record.question.question),
                          subtitle: Text(
                            'Your answer: ${record.response}\nCorrect: ${record.question.answer}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              child: const Text('Review Mistakes'),
            ),
        ],
      ),
    );
  }
}
