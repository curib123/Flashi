import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/provider/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateHistoryScreen extends StatelessWidget {
  final bool isCreate;
  final bool isRead;
  final String title;
  final DateTime date;

  const CreateHistoryScreen({
    super.key,
    required this.isCreate,
    required this.title,
    required this.isRead,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRead ? 'Generated content' : 'Edit generated content'),
        actions: [
          if (isRead)
            IconButton(
              tooltip: 'Edit',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateHistoryScreen(
                    isCreate: false,
                    title: title,
                    isRead: false,
                    date: date,
                  ),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FlashiDesign.pagePadding,
            8,
            FlashiDesign.pagePadding,
            16,
          ),
          child: Column(
            children: [
              TextField(
                readOnly: isRead,
                controller: provider.titleController,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('MMM d, yyyy · h:mm a').format(date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.48),
                      ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(FlashiDesign.radius),
                    border:
                        Border.all(color: colors.outline.withOpacity(0.12)),
                  ),
                  child: TextField(
                    readOnly: isRead,
                    controller: provider.contentController,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Generated questions and answers',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                  ),
                ),
              ),
              if (!isRead) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _save(context, provider),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save changes'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _save(BuildContext context, HistoryProvider provider) {
    final newTitle = provider.titleController.text.trim();
    final content = provider.contentController.text.trim();
    if (newTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title before saving.')),
      );
      return;
    }

    final existing = provider.history.where((item) => item['title'] == title);
    final favorite =
        existing.isNotEmpty ? existing.first['favorite'] == true : false;

    provider.editHistoryByTitle(
      title,
      {
        'title': newTitle,
        'content': content,
        'created_at': DateTime.now(),
        'favorite': favorite,
      },
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History item updated.')),
    );
  }
}
