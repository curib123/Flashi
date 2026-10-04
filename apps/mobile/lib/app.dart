import 'package:flashi/domain/study.dart';
import 'package:flashi/features/app_state.dart';
import 'package:flutter/material.dart';

class FlashiApp extends StatelessWidget {
  final AppState state;

  const FlashiApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashi AI',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
      ),
      home: _LibraryPage(state: state),
    );
  }
}

class _LibraryPage extends StatelessWidget {
  final AppState state;

  const _LibraryPage({required this.state});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Flashi AI')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _createSet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              children: [
                Text(
                  'Turn Notes Into Knowledge.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create, practice, and review your study sets offline.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (state.sets.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No study sets yet. Create one manually or generate one from your notes.',
                      ),
                    ),
                  )
                else
                  ...state.sets.map(
                    (set) => Card(
                      child: ListTile(
                        title: Text(set.title),
                        subtitle: Text(
                          '${set.questions.length} questions · ${set.kind.name}',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _SetPage(state: state, set: set),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createSet(BuildContext context) async {
    final title = TextEditingController();
    final question = TextEditingController();
    final answer = TextEditingController();
    final created = await showDialog<StudySet>(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
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
                context,
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
      records.add(
        AnswerRecord(
          question: question,
          response: response,
          correct: question.matches(response),
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
    Navigator.of(context).pushReplacement(
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
              onPressed: () {},
              child: const Text('Review Mistakes'),
            ),
        ],
      ),
    );
  }
}
