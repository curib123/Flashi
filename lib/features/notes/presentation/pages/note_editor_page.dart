import 'package:flashi/app/navigation/app_router.dart';
import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/app_surface.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/features/notes/application/notes_provider.dart';
import 'package:flashi/features/notes/data/services/note_ai_assistant.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({
    required this.isCreate,
    required this.title,
    required this.isRead,
    required this.date,
    super.key,
  });

  factory NoteEditorPage.fromArguments(NoteEditorArguments arguments) {
    return NoteEditorPage(
      isCreate: arguments.isCreate,
      title: arguments.title,
      isRead: arguments.isRead,
      date: arguments.date,
    );
  }

  final bool isCreate;
  final bool isRead;
  final String title;
  final DateTime date;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final NotesProvider _notes;
  final NoteAiAssistant _assistant = NoteAiAssistant();
  bool _isAssisting = false;

  @override
  void initState() {
    super.initState();
    _notes = context.read<NotesProvider>();
    _notes.titleController.addListener(_refresh);
    _notes.contentController.addListener(_refresh);
  }

  @override
  void dispose() {
    _notes.titleController.removeListener(_refresh);
    _notes.contentController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  int get _wordCount {
    final content = _notes.contentController.text.trim();
    if (content.isEmpty) return 0;
    return content.split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final readOnly = widget.isRead;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreate
            ? 'New note'
            : readOnly
                ? 'Note'
                : 'Edit note'),
        actions: [
          if (readOnly)
            IconButton(
              tooltip: 'Edit note',
              onPressed: _openEditMode,
              icon: const Icon(Icons.edit_outlined),
            )
          else ...[
            IconButton(
              tooltip: 'Writing assistant',
              onPressed: _hasContent && !_isAssisting ? _openAssistant : null,
              icon: _isAssisting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_outlined),
            ),
            TextButton.icon(
              onPressed: _canSave ? _save : null,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Save'),
            ),
          ],
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: ResponsiveContent(
        maxWidth: AppBreakpoints.readingMaxWidth,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              readOnly: readOnly,
              controller: _notes.titleController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: readOnly ? null : 120,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              decoration: InputDecoration(
                hintText: 'Give your note a clear title',
                counterText: '',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _MetadataChip(
                  icon: Icons.schedule_outlined,
                  label: DateFormat('MMM d, yyyy · h:mm a').format(widget.date),
                ),
                _MetadataChip(
                  icon: Icons.text_fields_rounded,
                  label: '$_wordCount ${_wordCount == 1 ? 'word' : 'words'}',
                ),
                const _MetadataChip(
                  icon: Icons.offline_pin_outlined,
                  label: 'Saved offline',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: AppSurface(
                emphasized: !readOnly,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  readOnly: readOnly,
                  controller: _notes.contentController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                  decoration: InputDecoration(
                    hintText:
                        'Write ideas, summaries, formulas, or study reminders…',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: readOnly
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppBreakpoints.readingMaxWidth,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _canSave ? _save : null,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          widget.isCreate ? 'Save note' : 'Save changes',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  bool get _canSave => _notes.titleController.text.trim().isNotEmpty;
  bool get _hasContent => _notes.contentController.text.trim().isNotEmpty;

  Future<void> _openAssistant() async {
    if (!await InternetConnection().hasInternetAccess) {
      if (mounted) {
        _showMessage(
          'The writing assistant needs internet. Your note still works offline.',
        );
      }
      return;
    }
    if (!mounted) return;

    await showAppBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _NoteAssistantSheet(
        onSelected: (action, instruction) {
          Navigator.pop(sheetContext);
          _runAssistant(action, instruction);
        },
      ),
    );
  }

  Future<void> _runAssistant(
    NoteAiAction action,
    String instruction,
  ) async {
    setState(() => _isAssisting = true);
    try {
      final result = await _assistant.assist(
        action: action,
        title: _notes.titleController.text,
        content: _notes.contentController.text,
        instruction: instruction,
      );
      if (!mounted) return;
      await _showAssistantPreview(action, result);
    } catch (error) {
      if (mounted) {
        _showMessage(
          error is StateError
              ? error.message.toString()
              : 'The assistant is unavailable. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isAssisting = false);
    }
  }

  Future<void> _showAssistantPreview(
    NoteAiAction action,
    String result,
  ) {
    return showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        icon: Icons.auto_awesome_outlined,
        title: 'Review suggestion',
        description:
            'Nothing changes until you choose how to use this suggestion.',
        body: SelectableText(result),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep original'),
          ),
          if (action != NoteAiAction.title)
            TextButton(
              onPressed: () {
                final current = _notes.contentController.text.trimRight();
                _notes.contentController.text =
                    current.isEmpty ? result : '$current\n\n$result';
                Navigator.pop(dialogContext);
              },
              child: const Text('Add below'),
            ),
          FilledButton(
            onPressed: () {
              if (action == NoteAiAction.title) {
                _notes.titleController.text =
                    result.replaceAll(RegExp(r'^["“”]|["“”]$'), '').trim();
              } else {
                _notes.contentController.text = result;
              }
              Navigator.pop(dialogContext);
            },
            child: Text(
              action == NoteAiAction.title ? 'Use title' : 'Replace note',
            ),
          ),
        ],
      ),
    );
  }

  void _openEditMode() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.noteEditor,
      arguments: NoteEditorArguments(
        isCreate: false,
        title: widget.title,
        isRead: false,
        date: widget.date,
      ),
    );
  }

  void _save() {
    final newTitle = _notes.titleController.text.trim();
    final content = _notes.contentController.text.trim();
    final original = _notes.noteByTitle(widget.title);
    final hasDuplicate = _notes.hasNoteTitle(
      newTitle,
      excludingTitle: widget.isCreate ? null : widget.title,
    );

    if (hasDuplicate) {
      _showMessage('A note with this title already exists.');
      return;
    }

    final note = <String, dynamic>{
      'title': newTitle,
      'content': content,
      'created_at': original?['created_at'] ?? widget.date,
      'updated_at': DateTime.now(),
      'favorite': original?['favorite'] == true,
    };

    if (widget.isCreate) {
      _notes.addNote(note);
    } else {
      _notes.editNoteByTitle(widget.title, note);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isCreate ? 'Note saved' : 'Changes saved'),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _NoteAssistantSheet extends StatefulWidget {
  const _NoteAssistantSheet({required this.onSelected});

  final void Function(NoteAiAction action, String instruction) onSelected;

  @override
  State<_NoteAssistantSheet> createState() => _NoteAssistantSheetState();
}

class _NoteAssistantSheetState extends State<_NoteAssistantSheet> {
  final TextEditingController _instructionController = TextEditingController();

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSheetHeader(
            title: 'Writing assistant',
            description:
                'Choose an action when you want help. Your note is never changed automatically.',
          ),
          _AssistantAction(
            icon: Icons.auto_fix_high_outlined,
            title: 'Polish writing',
            description: 'Improve clarity and grammar without changing facts.',
            onTap: () => widget.onSelected(NoteAiAction.polish, ''),
          ),
          _AssistantAction(
            icon: Icons.summarize_outlined,
            title: 'Create a study summary',
            description: 'Turn the note into a concise review.',
            onTap: () => widget.onSelected(NoteAiAction.summarize, ''),
          ),
          _AssistantAction(
            icon: Icons.title_rounded,
            title: 'Suggest a title',
            description: 'Generate one short title from the note.',
            onTap: () => widget.onSelected(NoteAiAction.title, ''),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _instructionController,
              onChanged: (_) => setState(() {}),
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Ask for something specific',
                hintText: 'Example: Turn this into a revision checklist',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: FilledButton.icon(
              onPressed: _instructionController.text.trim().isEmpty
                  ? null
                  : () => widget.onSelected(
                        NoteAiAction.custom,
                        _instructionController.text,
                      ),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Ask assistant'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantAction extends StatelessWidget {
  const _AssistantAction({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
