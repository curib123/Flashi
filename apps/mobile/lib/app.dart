import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flashi/data/services/auth_service.dart';
import 'package:flashi/data/services/backup_service.dart';
import 'package:flashi/data/services/generation_service.dart';
import 'package:flashi/data/services/startio_service.dart';
import 'package:flashi/data/services/sync_service.dart';
import 'package:flashi/domain/study.dart';
import 'package:flashi/domain/study_package.dart';
import 'package:flashi/features/app_state.dart';
import 'package:flutter/material.dart';

class FlashiApp extends StatelessWidget {
  final AppState state;
  final GenerationService? generation;
  final AuthService? auth;
  final BackupService? backup;
  final SyncService? sync;
  final StartIoService? ads;
  final bool showLibraryBanner;

  const FlashiApp({
    super.key,
    required this.state,
    this.generation,
    this.auth,
    this.backup,
    this.sync,
    this.ads,
    this.showLibraryBanner = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF365CF5),
      brightness: Brightness.light,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashi AI',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 0,
        ),
      ),
      home: _HomeShell(
        state: state,
        generation: generation,
        auth: auth,
        backup: backup,
        sync: sync,
        ads: ads,
        showLibraryBanner: showLibraryBanner,
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  final AppState state;
  final GenerationService? generation;
  final AuthService? auth;
  final BackupService? backup;
  final SyncService? sync;
  final StartIoService? ads;
  final bool showLibraryBanner;

  const _HomeShell({
    required this.state,
    this.generation,
    this.auth,
    this.backup,
    this.sync,
    this.ads,
    this.showLibraryBanner = false,
  });

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final pages = [
          _LibraryPage(
            state: widget.state,
            backup: widget.backup,
            ads: widget.ads,
            showBanner: widget.showLibraryBanner,
          ),
          _CreatePage(
            state: widget.state,
            generation: widget.generation,
          ),
          _ProgressPage(state: widget.state),
          _SettingsPage(
            state: widget.state,
            auth: widget.auth,
            backup: widget.backup,
            sync: widget.sync,
          ),
        ];
        return Scaffold(
          body: SafeArea(child: pages[_index]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(Icons.library_books),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: 'Create',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Progress',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageHeader(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
}

class _LibraryPage extends StatelessWidget {
  final AppState state;
  final BackupService? backup;
  final StartIoService? ads;
  final bool showBanner;

  const _LibraryPage({
    required this.state,
    this.backup,
    this.ads,
    this.showBanner = false,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: state.reload,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const _PageHeader(
            'Flashi AI',
            'Turn Notes Into Knowledge.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload. Generate. Practice. Remember.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your saved study materials stay available offline.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Study library',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                Text('${state.sets.length} sets'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (state.loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.sets.isEmpty)
            const _EmptyCard(
              icon: Icons.auto_stories_outlined,
              title: 'No study sets yet',
              message:
                  'Create one manually or generate one from your notes, PDFs, or photos.',
            )
          else
            ...state.sets.map(
              (set) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: _StudySetTile(
                  set: set,
                  latest: state.latestAttemptFor(set.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _SetDetailPage(
                        state: state,
                        set: set,
                        backup: backup,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (showBanner && ads != null) ...[
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StartIoBannerSlot(service: ads!),
            ),
          ],
        ],
      ),
    );
  }
}

class _StudySetTile extends StatelessWidget {
  final StudySet set;
  final StudyAttempt? latest;
  final VoidCallback onTap;

  const _StudySetTile({
    required this.set,
    required this.latest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: CircleAvatar(
            child: Icon(
              set.kind == SetKind.deck
                  ? Icons.style_outlined
                  : set.kind == SetKind.exam
                      ? Icons.assignment_outlined
                      : Icons.quiz_outlined,
            ),
          ),
          title: Text(
            set.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            [
              if (set.subject.trim().isNotEmpty) set.subject,
              '${set.questions.length} items',
              if (latest != null) 'Last: ${latest!.score}%',
            ].join(' • '),
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Icon(icon, size: 42),
                const SizedBox(height: 12),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
}

class _CreatePage extends StatelessWidget {
  final AppState state;
  final GenerationService? generation;

  const _CreatePage({required this.state, this.generation});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const _PageHeader(
            'Create study material',
            'Start manually or turn your own notes into structured practice.',
          ),
          _ActionCard(
            icon: Icons.edit_note,
            title: 'Create manually',
            subtitle:
                'Build editable flashcards, quizzes, and mock exams without AI.',
            button: 'Create',
            onTap: () async {
              final saved = await Navigator.of(context).push<StudySet>(
                MaterialPageRoute(builder: (_) => const _SetEditorPage()),
              );
              if (saved != null) await state.saveSet(saved);
            },
          ),
          _ActionCard(
            icon: Icons.auto_awesome,
            title: 'Generate with AI',
            subtitle:
                'Use text, PDFs, supported documents, screenshots, or photos.',
            button: 'Generate',
            enabled: generation != null,
            onTap: generation == null
                ? null
                : () async {
                    final set = await Navigator.of(context).push<StudySet>(
                      MaterialPageRoute(
                        builder: (_) =>
                            _GeneratePage(generation: generation!),
                      ),
                    );
                    if (set == null || !context.mounted) return;
                    final edited = await Navigator.of(context).push<StudySet>(
                      MaterialPageRoute(
                        builder: (_) => _SetEditorPage(initial: set),
                      ),
                    );
                    if (edited != null) await state.saveSet(edited);
                  },
          ),
        ],
      );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String button;
  final bool enabled;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.button,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 24, child: Icon(icon)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(subtitle),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: enabled ? onTap : null,
                        child: Text(button),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ProgressPage extends StatelessWidget {
  final AppState state;
  const _ProgressPage({required this.state});

  @override
  Widget build(BuildContext context) {
    final attempts = state.attempts;
    final mistakes = attempts.fold<int>(
      0,
      (sum, attempt) => sum + attempt.mistakes.length,
    );
    final scores = attempts.map((e) => e.score).toList();
    final average =
        scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) ~/ scores.length;
    final weak = <String, int>{};
    for (final attempt in attempts) {
      for (final entry in attempt.weakTopics.entries) {
        weak[entry.key] = (weak[entry.key] ?? 0) + entry.value;
      }
    }
    final weakEntries = weak.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const _PageHeader(
          'Progress',
          'Review performance and focus on weak topics.',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _MetricCard('Attempts', '${attempts.length}')),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard('Average', '$average%')),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard('Mistakes', '$mistakes')),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Weak topics',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (weakEntries.isEmpty)
          const _EmptyCard(
            icon: Icons.insights,
            title: 'Nothing to review yet',
            message: 'Complete a quiz or exam to identify weak topics.',
          )
        else
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weakEntries
                  .take(12)
                  .map((e) => Chip(label: Text('${e.key} • ${e.value}')))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard(this.label, this.value);

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
}

class _SettingsPage extends StatefulWidget {
  final AppState state;
  final AuthService? auth;
  final BackupService? backup;
  final SyncService? sync;

  const _SettingsPage({
    required this.state,
    this.auth,
    this.backup,
    this.sync,
  });

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() work) async {
    setState(() => _busy = true);
    try {
      await work();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const _PageHeader(
            'Settings',
            'Guest mode works offline. Sign in only for AI and cloud features.',
          ),
          if (_busy) const LinearProgressIndicator(),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(widget.auth?.signedIn == true
                ? 'Google account connected'
                : 'Continue as guest'),
            subtitle: const Text(
              'Manual creation, studying, backups, and imports work without an account.',
            ),
            trailing: widget.auth == null
                ? null
                : FilledButton.tonal(
                    onPressed: _busy
                        ? null
                        : () => _run(() async {
                              if (widget.auth!.signedIn) {
                                await widget.auth!.signOut();
                              } else {
                                await widget.auth!.signInWithGoogle();
                                await widget.sync?.sync();
                              }
                              setState(() {});
                            }),
                    child: Text(
                        widget.auth!.signedIn ? 'Sign out' : 'Sign in'),
                  ),
          ),
          const Divider(),
          ListTile(
            enabled: widget.backup != null,
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Full backup'),
            subtitle: const Text('Export your local Flashi learning library.'),
            onTap: widget.backup == null || _busy
                ? null
                : () => _run(() async {
                      final package = await widget.state.backup();
                      await widget.backup!.share(package, name: 'Flashi Backup');
                    }),
          ),
          ListTile(
            enabled: widget.backup != null,
            leading: const Icon(Icons.restore),
            title: const Text('Restore or import'),
            subtitle:
                const Text('Preview a Flashi backup or study pack before import.'),
            onTap: widget.backup == null || _busy
                ? null
                : () => _run(() async {
                      final package = await widget.backup!.pickPackage();
                      if (package == null || !mounted) return;
                      await _showImportPreview(context, widget.state, package);
                    }),
          ),
          ListTile(
            enabled: widget.sync != null && widget.auth?.signedIn == true,
            leading: const Icon(Icons.sync),
            title: const Text('Sync now'),
            subtitle: const Text('Push local changes and pull account data.'),
            onTap: widget.sync == null || _busy
                ? null
                : () => _run(() async {
                      await widget.sync!.sync();
                      await widget.state.reload();
                    }),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Privacy and security'),
            subtitle: Text(
              'AI keys and server secrets are never stored in the Flutter app.',
            ),
          ),
        ],
      );
}

Future<void> _showImportPreview(
  BuildContext context,
  AppState state,
  StudyPackage package,
) async {
  final behavior = await showDialog<ImportBehavior>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(package.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Creator: ${package.creator.isEmpty ? 'Unknown' : package.creator}'),
            Text('Subject: ${package.subject.isEmpty ? 'Mixed' : package.subject}'),
            Text('Flashcards: ${package.flashcardCount}'),
            Text('Quiz/questions: ${package.questionCount}'),
            Text('Content type: ${package.contentType}'),
            Text('Package version: ${package.version}'),
            const SizedBox(height: 12),
            const Text(
              'Imported content becomes an independent local copy when duplicated.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ImportBehavior.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ImportBehavior.replace),
          child: const Text('Replace matching'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, ImportBehavior.duplicate),
          child: const Text('Import copy'),
        ),
      ],
    ),
  );
  if (behavior != null && behavior != ImportBehavior.cancel) {
    await state.import(package, behavior);
  }
}

class _SetDetailPage extends StatelessWidget {
  final AppState state;
  final StudySet set;
  final BackupService? backup;

  const _SetDetailPage({
    required this.state,
    required this.set,
    this.backup,
  });

  @override
  Widget build(BuildContext context) {
    final latest = state.latestAttemptFor(set.id);
    final button = set.kind == SetKind.deck
        ? 'Study Flashcards'
        : set.kind == SetKind.exam
            ? 'Start Exam'
            : 'Start Quiz';
    return Scaffold(
      appBar: AppBar(title: Text(set.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            set.subject.isEmpty ? 'General' : set.subject,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            '${set.questions.length} items • ${set.difficulty}',
          ),
          if (latest != null) ...[
            const SizedBox(height: 8),
            Text('Last score: ${latest.score}%'),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: set.questions.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _StudyPage(
                          state: state,
                          set: set,
                          questions: set.questions,
                          mode: set.kind.name,
                        ),
                      ),
                    ),
            icon: const Icon(Icons.play_arrow),
            label: Text(button),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final edited = await Navigator.of(context).push<StudySet>(
                MaterialPageRoute(
                  builder: (_) => _SetEditorPage(initial: set),
                ),
              );
              if (edited != null) {
                await state.saveSet(edited);
                if (context.mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit'),
          ),
          if (backup != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => backup!.share(
                backup!.packFor(set, creator: set.creator),
                name: set.title,
              ),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share study pack'),
            ),
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete study set?'),
                  content: const Text(
                    'This removes the local set. Your backup files are not affected.',
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true) {
                await state.deleteSet(set);
                if (context.mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
          const SizedBox(height: 24),
          Text('Questions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...set.questions.asMap().entries.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(entry.value.question),
                    subtitle: Text(questionTypeWire(entry.value.type)),
                    leading: CircleAvatar(child: Text('${entry.key + 1}')),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _SetEditorPage extends StatefulWidget {
  final StudySet? initial;
  const _SetEditorPage({this.initial});

  @override
  State<_SetEditorPage> createState() => _SetEditorPageState();
}

class _SetEditorPageState extends State<_SetEditorPage> {
  late final TextEditingController _title;
  late final TextEditingController _subject;
  late SetKind _kind;
  late String _difficulty;
  late List<StudyQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _subject = TextEditingController(text: widget.initial?.subject ?? '');
    _kind = widget.initial?.kind ?? SetKind.quiz;
    _difficulty = widget.initial?.difficulty ?? 'medium';
    _questions = [...?widget.initial?.questions];
  }

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    super.dispose();
  }

  Future<void> _addOrEdit({int? index}) async {
    final question = await Navigator.of(context).push<StudyQuestion>(
      MaterialPageRoute(
        builder: (_) => _QuestionEditorPage(
          initial: index == null ? null : _questions[index],
          deckOnly: _kind == SetKind.deck,
        ),
      ),
    );
    if (question == null) return;
    setState(() {
      if (index == null) {
        _questions.add(question);
      } else {
        _questions[index] = question;
      }
    });
  }

  void _save() {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add a title first.')));
      return;
    }
    final set = StudySet(
      id: widget.initial?.id,
      title: _title.text.trim(),
      subject: _subject.text.trim(),
      creator: widget.initial?.creator ?? '',
      kind: _kind,
      difficulty: _difficulty,
      questions: _questions,
    );
    Navigator.pop(context, set);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.initial == null ? 'New study set' : 'Edit study set'),
          actions: [
            TextButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addOrEdit,
          icon: const Icon(Icons.add),
          label: const Text('Question'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subject,
              decoration:
                  const InputDecoration(labelText: 'Subject / category'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SetKind>(
              initialValue: _kind,
              decoration: const InputDecoration(labelText: 'Content type'),
              items: SetKind.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _kind = value;
                  if (_kind == SetKind.deck) {
                    _questions = _questions
                        .where((q) => q.type == QuestionType.flashcard)
                        .toList();
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _difficulty,
              decoration: const InputDecoration(labelText: 'Difficulty'),
              items: const [
                DropdownMenuItem(value: 'easy', child: Text('Easy')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'hard', child: Text('Hard')),
              ],
              onChanged: (value) =>
                  setState(() => _difficulty = value ?? 'medium'),
            ),
            const SizedBox(height: 22),
            Text(
              'Questions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (_questions.isEmpty)
              const Text('No questions yet. Add one with the button below.')
            else
              ..._questions.asMap().entries.map(
                    (entry) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _addOrEdit(index: entry.key),
                        title: Text(entry.value.question),
                        subtitle: Text(questionTypeWire(entry.value.type)),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'duplicate') {
                              setState(() => _questions.insert(
                                    entry.key + 1,
                                    entry.value.copyWith(id: null),
                                  ));
                            } else if (value == 'delete') {
                              setState(() => _questions.removeAt(entry.key));
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'duplicate', child: Text('Duplicate')),
                            PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      );
}

class _QuestionEditorPage extends StatefulWidget {
  final StudyQuestion? initial;
  final bool deckOnly;
  const _QuestionEditorPage({this.initial, required this.deckOnly});

  @override
  State<_QuestionEditorPage> createState() => _QuestionEditorPageState();
}

class _QuestionEditorPageState extends State<_QuestionEditorPage> {
  late QuestionType _type;
  late final TextEditingController _question;
  late final TextEditingController _answer;
  late final TextEditingController _options;
  late final TextEditingController _explanation;
  late final TextEditingController _topic;
  late final TextEditingController _pairs;

  @override
  void initState() {
    super.initState();
    _type = widget.deckOnly
        ? QuestionType.flashcard
        : widget.initial?.type ?? QuestionType.multipleChoice;
    final q = widget.initial;
    _question = TextEditingController(text: q?.question ?? '');
    _answer = TextEditingController(text: q?.answer ?? '');
    _options = TextEditingController(text: q?.options.join('\n') ?? '');
    _explanation = TextEditingController(text: q?.explanation ?? '');
    _topic = TextEditingController(text: q?.topic ?? '');
    _pairs = TextEditingController(
      text: q?.pairs.map((e) => '${e.left} = ${e.right}').join('\n') ?? '',
    );
  }

  @override
  void dispose() {
    for (final c in [
      _question,
      _answer,
      _options,
      _explanation,
      _topic,
      _pairs,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    try {
      var options = _options.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      var pairs = <MatchPair>[];
      var answer = _answer.text.trim();

      if (_type == QuestionType.trueFalse) {
        answer = answer.toLowerCase() == 'false' ? 'False' : 'True';
        options = ['True', 'False'];
      } else if (_type == QuestionType.matching) {
        answer = '';
        options = [];
        pairs = _pairs.text
            .split('\n')
            .where((e) => e.contains('='))
            .map((e) {
          final i = e.indexOf('=');
          return MatchPair(e.substring(0, i).trim(), e.substring(i + 1).trim());
        }).where((e) => e.left.isNotEmpty && e.right.isNotEmpty).toList();
      } else if (_type != QuestionType.multipleChoice) {
        options = [];
      }

      final result = StudyQuestion(
        id: widget.initial?.id,
        type: _type,
        question: _question.text.trim(),
        answer: answer,
        options: options,
        explanation: _explanation.text.trim(),
        topic: _topic.text.trim(),
        pairs: pairs,
      );
      result.validate();
      Navigator.pop(context, result);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = widget.deckOnly
        ? const [QuestionType.flashcard]
        : QuestionType.values.where((e) => e != QuestionType.flashcard).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<QuestionType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Question type'),
            items: types
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(questionTypeWire(e).replaceAll('_', ' ')),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _type = value ?? _type),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _question,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: _type == QuestionType.fillBlank
                  ? 'Question (include ____)'
                  : 'Question / prompt',
            ),
          ),
          if (_type != QuestionType.matching) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _answer,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: _type == QuestionType.trueFalse
                    ? 'Answer (True or False)'
                    : 'Answer',
              ),
            ),
          ],
          if (_type == QuestionType.multipleChoice) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _options,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Options',
                helperText: 'Exactly four choices, one per line.',
              ),
            ),
          ],
          if (_type == QuestionType.matching) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _pairs,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Matching pairs',
                helperText: 'One pair per line: Term = Match',
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _explanation,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Explanation'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _topic,
            decoration: const InputDecoration(labelText: 'Topic'),
          ),
        ],
      ),
    );
  }
}

class _GeneratePage extends StatefulWidget {
  final GenerationService generation;
  const _GeneratePage({required this.generation});

  @override
  State<_GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<_GeneratePage> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _topics = TextEditingController();
  SetKind _kind = SetKind.quiz;
  String _difficulty = 'medium';
  int _count = 10;
  bool _busy = false;
  File? _file;
  bool _image = false;
  final Set<QuestionType> _types = {QuestionType.multipleChoice};

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _topics.dispose();
    super.dispose();
  }

  Future<void> _pick(bool image) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: image
          ? ['png', 'jpg', 'jpeg', 'webp']
          : ['pdf', 'doc', 'docx', 'txt', 'md', 'rtf', 'odt'],
    );
    final path = result?.files.single.path;
    if (path != null) {
      setState(() {
        _file = File(path);
        _image = image;
      });
    }
  }

  Future<void> _generate() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add a title first.')));
      return;
    }
    if (_file == null && _notes.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paste notes or choose a source file.')));
      return;
    }
    final types =
        _kind == SetKind.deck ? [QuestionType.flashcard] : _types.toList();
    if (types.isEmpty || types.length > _count) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Choose question types that fit the question count.')));
      return;
    }
    setState(() => _busy = true);
    try {
      final topics = _topics.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .take(10)
          .toList();
      final set = _file == null
          ? await widget.generation.generateText(
              text: _notes.text.trim(),
              title: _title.text.trim(),
              kind: _kind,
              count: _count,
              difficulty: _difficulty,
              questionTypes: types,
              topics: topics,
            )
          : await widget.generation.generateFile(
              file: _file!,
              image: _image,
              title: _title.text.trim(),
              kind: _kind,
              count: _count,
              difficulty: _difficulty,
              questionTypes: types,
              topics: topics,
            );
      if (mounted) Navigator.pop(context, set);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = QuestionType.values
        .where((e) => e != QuestionType.flashcard)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Generate with AI')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_busy) const LinearProgressIndicator(),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<SetKind>(
            initialValue: _kind,
            decoration: const InputDecoration(labelText: 'Create'),
            items: SetKind.values
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e.name.toUpperCase())))
                .toList(),
            onChanged: _busy
                ? null
                : (value) => setState(() => _kind = value ?? _kind),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _difficulty,
            decoration: const InputDecoration(labelText: 'Difficulty'),
            items: const [
              DropdownMenuItem(value: 'easy', child: Text('Easy')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'hard', child: Text('Hard')),
            ],
            onChanged: _busy
                ? null
                : (value) =>
                    setState(() => _difficulty = value ?? _difficulty),
          ),
          const SizedBox(height: 16),
          Text('Question count: $_count'),
          Slider(
            value: _count.toDouble(),
            min: 1,
            max: 50,
            divisions: 49,
            label: '$_count',
            onChanged:
                _busy ? null : (value) => setState(() => _count = value.round()),
          ),
          if (_kind != SetKind.deck) ...[
            const SizedBox(height: 8),
            Text('Question types',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: available
                  .map(
                    (type) => FilterChip(
                      selected: _types.contains(type),
                      label: Text(questionTypeWire(type).replaceAll('_', ' ')),
                      onSelected: _busy
                          ? null
                          : (selected) => setState(() {
                                if (selected) {
                                  _types.add(type);
                                } else {
                                  _types.remove(type);
                                }
                              }),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _topics,
            decoration: const InputDecoration(
              labelText: 'Topics (optional)',
              hintText: 'Photosynthesis, Cell division',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notes,
            minLines: 5,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Paste notes',
              hintText: 'Paste your lesson or reviewer here...',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(false),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Document'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(true),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Photo'),
                ),
              ),
            ],
          ),
          if (_file != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Selected: ${_file!.uri.pathSegments.last}'),
            ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _busy ? null : _generate,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate study material'),
          ),
          const SizedBox(height: 8),
          Text(
            'AI generation requires sign-in, internet, and server-managed credits. Failed generations are not charged.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _StudyPage extends StatefulWidget {
  final AppState state;
  final StudySet set;
  final List<StudyQuestion> questions;
  final String mode;

  const _StudyPage({
    required this.state,
    required this.set,
    required this.questions,
    required this.mode,
  });

  @override
  State<_StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<_StudyPage> {
  int _index = 0;
  final _response = TextEditingController();
  final List<AnswerRecord> _answers = [];
  String? _selected;
  bool _checked = false;
  bool _manualCorrect = false;
  late final DateTime _started;

  StudyQuestion get _question => widget.questions[_index];

  @override
  void initState() {
    super.initState();
    _started = DateTime.now().toUtc();
  }

  @override
  void dispose() {
    _response.dispose();
    super.dispose();
  }

  bool get _isChoice =>
      _question.type == QuestionType.multipleChoice ||
      _question.type == QuestionType.trueFalse;

  bool get _isFlashcard => _question.type == QuestionType.flashcard;
  bool get _isMatching => _question.type == QuestionType.matching;

  String get _currentResponse =>
      _isChoice ? (_selected ?? '') : _response.text.trim();

  bool get _correct {
    if (_isMatching || _isFlashcard) return _manualCorrect;
    return _question.matches(_currentResponse);
  }

  void _check() {
    if (!_isMatching &&
        !_isFlashcard &&
        _currentResponse.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Answer first.')));
      return;
    }
    setState(() => _checked = true);
  }

  Future<void> _next() async {
    if (!_checked) return;
    _answers.add(AnswerRecord(
      question: _question,
      response: _isMatching || _isFlashcard
          ? (_manualCorrect ? 'Known' : 'Review')
          : _currentResponse,
      correct: _correct,
    ));
    if (_index == widget.questions.length - 1) {
      final attempt = StudyAttempt(
        setId: widget.set.id,
        title: widget.set.title,
        mode: widget.mode,
        startedAt: _started,
        finishedAt: DateTime.now().toUtc(),
        answers: List.unmodifiable(_answers),
      );
      await widget.state.saveAttempt(attempt);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => _ResultsPage(
            state: widget.state,
            set: widget.set,
            attempt: attempt,
          ),
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _response.clear();
      _checked = false;
      _manualCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _question;
    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1} of ${widget.questions.length}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LinearProgressIndicator(
              value: (_index + 1) / widget.questions.length),
          const SizedBox(height: 24),
          if (q.topic.isNotEmpty) Chip(label: Text(q.topic)),
          Text(
            q.question,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          if (_isChoice)
            ...q.options.map(
              (option) => RadioListTile<String>(
                value: option,
                groupValue: _selected,
                onChanged:
                    _checked ? null : (value) => setState(() => _selected = value),
                title: Text(option),
              ),
            )
          else if (_isFlashcard)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_checked) Text(q.answer,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800))
                    else
                      const Text('Reveal the answer, then rate yourself.'),
                    if (_checked) ...[
                      const SizedBox(height: 14),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('Review')),
                          ButtonSegment(value: true, label: Text('Know it')),
                        ],
                        selected: {_manualCorrect},
                        onSelectionChanged: (value) =>
                            setState(() => _manualCorrect = value.first),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else if (_isMatching)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...q.pairs.map((p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text('${p.left}  ↔  ${_checked ? p.right : '•••'}'),
                    )),
                if (_checked) ...[
                  const SizedBox(height: 14),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Need review')),
                      ButtonSegment(value: true, label: Text('Correct')),
                    ],
                    selected: {_manualCorrect},
                    onSelectionChanged: (value) =>
                        setState(() => _manualCorrect = value.first),
                  ),
                ],
              ],
            )
          else
            TextField(
              controller: _response,
              enabled: !_checked,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Your answer'),
            ),
          const SizedBox(height: 18),
          if (!_checked)
            FilledButton(
              onPressed: _isFlashcard || _isMatching ? _check : _check,
              child: Text(_isFlashcard ? 'Reveal Answer' : 'Check Answer'),
            )
          else ...[
            if (!_isFlashcard && !_isMatching)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _correct
                        ? 'Correct'
                        : 'Correct answer: ${q.answer}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _correct
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ),
            if (q.explanation.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(q.explanation),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _next,
              child: Text(_index == widget.questions.length - 1
                  ? 'Finish'
                  : 'Next'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultsPage extends StatelessWidget {
  final AppState state;
  final StudySet set;
  final StudyAttempt attempt;

  const _ResultsPage({
    required this.state,
    required this.set,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    final weak = attempt.weakTopics.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${attempt.score}%',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text('${attempt.correctCount} of ${attempt.answers.length} correct'),
          const SizedBox(height: 18),
          if (weak.isNotEmpty) ...[
            Text('Weak topics',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: weak
                  .map((e) => Chip(label: Text('${e.key} • ${e.value}')))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (attempt.mistakes.isNotEmpty)
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _StudyPage(
                    state: state,
                    set: set,
                    questions:
                        attempt.mistakes.map((e) => e.question).toList(),
                    mode: 'mistakes',
                  ),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Review Mistakes'),
            ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Back to library'),
          ),
          const SizedBox(height: 22),
          ...attempt.answers.asMap().entries.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      entry.value.correct
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: entry.value.correct
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(entry.value.question.question),
                    subtitle: Text(
                      entry.value.correct
                          ? 'Correct'
                          : 'Your answer: ${entry.value.response}\nCorrect: ${entry.value.question.answer}',
                    ),
                    isThreeLine: !entry.value.correct,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
