import 'package:flashi/app/navigation/app_router.dart';
import 'package:flashi/features/history/application/history_provider.dart';
import 'package:flashi/shared/widgets/content_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryEditorPage extends StatelessWidget {
  const HistoryEditorPage({
    required this.isCreate,
    required this.title,
    required this.isRead,
    required this.date,
    super.key,
  });

  factory HistoryEditorPage.fromArguments(HistoryEditorArguments arguments) {
    return HistoryEditorPage(
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
    final history = context.watch<HistoryProvider>();
    return ContentEditorPage(
      pageTitle: isRead ? 'History detail' : 'Edit history',
      titleController: history.titleController,
      contentController: history.contentController,
      date: date,
      readOnly: isRead,
      onEdit: () {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.historyEditor,
          arguments: HistoryEditorArguments(
            isCreate: false,
            title: title,
            isRead: false,
            date: date,
          ),
        );
      },
      onSave: () => _save(context, history),
    );
  }

  void _save(BuildContext context, HistoryProvider history) {
    if (history.titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A title is required')),
      );
      return;
    }

    final item = <String, dynamic>{
      'title': history.titleController.text,
      'content': history.contentController.text,
      'created_at': DateTime.now(),
      'favorite': false,
    };
    if (isCreate) {
      history.addHistory(item);
      history.titleController.clear();
      history.contentController.clear();
    } else {
      history.editHistoryByTitle(title, item);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCreate ? 'History added' : 'History updated'),
      ),
    );
  }
}
