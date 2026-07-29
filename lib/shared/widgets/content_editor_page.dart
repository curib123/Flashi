import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/app_surface.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContentEditorPage extends StatelessWidget {
  const ContentEditorPage({
    required this.pageTitle,
    required this.titleController,
    required this.contentController,
    required this.date,
    required this.readOnly,
    required this.onSave,
    required this.onEdit,
    super.key,
  });

  final String pageTitle;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final DateTime date;
  final bool readOnly;
  final VoidCallback onSave;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        actions: [
          if (readOnly)
            IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: ResponsiveContent(
        maxWidth: AppBreakpoints.readingMaxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              readOnly: readOnly,
              controller: titleController,
              textCapitalization: TextCapitalization.sentences,
              style: Theme.of(context).textTheme.headlineSmall,
              decoration: const InputDecoration(
                hintText: 'Untitled',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            Expanded(
              child: AppSurface(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  readOnly: readOnly,
                  controller: contentController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Start writing…',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
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
                child: Align(
                  alignment: Alignment.center,
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppBreakpoints.readingMaxWidth,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onSave,
                        icon: const Icon(Icons.check),
                        label: const Text('Save'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
