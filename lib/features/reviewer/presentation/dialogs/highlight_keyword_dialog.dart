import 'package:flashi/shared/dialogs/app_modal.dart';
import 'package:flutter/material.dart';

void showHighlightKeywordDialog(
  BuildContext context,
  Function(String search) onSearch,
) {
  final controller = TextEditingController();
  showAppDialog<void>(
    context: context,
    builder: (context) => AppDialog(
      icon: Icons.highlight_alt_rounded,
      title: 'Highlight keyword',
      description: 'Choose one word or short phrase to emphasize.',
      body: TextField(
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Keyword',
          hintText: 'Enter a word or phrase',
          prefixIcon: Icon(Icons.search_rounded),
        ),
        onSubmitted: (_) => _submit(context, controller, onSearch),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () => _submit(context, controller, onSearch),
          icon: const Icon(Icons.format_color_fill_rounded),
          label: const Text('Highlight'),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

void _submit(
  BuildContext context,
  TextEditingController controller,
  Function(String search) onSearch,
) {
  final keyword = controller.text.trim();
  if (keyword.isEmpty) return;
  onSearch(keyword);
  Navigator.pop(context);
}
