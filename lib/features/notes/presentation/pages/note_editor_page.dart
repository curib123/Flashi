import 'package:flashi/app/navigation/app_router.dart';
import 'package:flashi/features/notes/application/notes_provider.dart';
import 'package:flashi/shared/widgets/content_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteEditorPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>();
    return ContentEditorPage(
      pageTitle: isRead
          ? 'View note'
          : isCreate
              ? 'New note'
              : 'Edit note',
      titleController: notes.titleController,
      contentController: notes.contentController,
      date: date,
      readOnly: isRead,
      onEdit: () {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.noteEditor,
          arguments: NoteEditorArguments(
            isCreate: false,
            title: title,
            isRead: false,
            date: date,
          ),
        );
      },
      onSave: () => _save(context, notes),
    );
  }

  void _save(BuildContext context, NotesProvider notes) {
    if (notes.titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A title is required')),
      );
      return;
    }

    final note = <String, dynamic>{
      'title': notes.titleController.text,
      'content': notes.contentController.text,
      'created_at': DateTime.now(),
      'favorite': false,
    };
    if (isCreate) {
      notes.addNote(note);
      notes.titleController.clear();
      notes.contentController.clear();
    } else {
      notes.editNoteByTitle(title, note);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCreate ? 'Note added' : 'Note updated'),
      ),
    );
  }
}
