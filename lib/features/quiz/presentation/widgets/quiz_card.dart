import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/shared/widgets/highlighted_text.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';

class QuizCard extends StatelessWidget {
  final String question;
  final String keyword;
  final String answer;
  final bool isIgnore;
  final DateTime timestamp;
  final bool isUpdating;
  final Function() onRemove;
  final Function() onEdit;
  final Function() onIgnore;
  final Function() onKeyword;
  final Function() onRemoveKeyword;
  final FlutterTts flutterTts = FlutterTts();

  QuizCard({
    super.key,
    required this.question,
    required this.answer,
    required this.isIgnore,
    required this.timestamp,
    required this.onRemove,
    required this.onEdit,
    required this.onIgnore,
    required this.isUpdating,
    required this.onKeyword,
    required this.keyword,
    required this.onRemoveKeyword,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: InkWell(
        borderRadius: AppRadii.large,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isIgnore
                ? colorScheme.surfaceContainerLow
                : colorScheme.surfaceContainerHigh,
            borderRadius: AppRadii.large,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isIgnore)
                Text(
                  "Hidden from review",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant),
                )
              else ...[
                highlightKeywords(
                  context: context,
                  keyword: keyword,
                  text: question,
                  fontSize: 14,
                  fontColor: colorScheme.onSurface,
                  fontSizeKeyword: 12,
                  isCenter: false,
                ),
                const SizedBox(height: 8),
                Text(
                  answer,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant),
                ),
                //  const SizedBox(height: 10),
                // Text(
                //   isUpdating ? "Updated on: $formattedTimestamp" : "Created on: $formattedTimestamp",
                //   style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                // ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Read question and answer',
                      icon: const Icon(Icons.volume_up_outlined),
                      onPressed: () async {
                        await flutterTts.speak(
                            'The question: $question The answer: $answer');
                      },
                    ),
                    IconButton(
                      tooltip: 'Card actions',
                      icon: const Icon(Icons.more_horiz_rounded),
                      onPressed: () => _showPopupMenu(context, colorScheme),
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

  void _showPopupMenu(BuildContext context, ColorScheme colorScheme) {
    showAppBottomSheet<void>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHeader(
            title: 'Card actions',
            description: 'Edit, organize, or change review visibility.',
          ),
          _buildMenuItem(
              context, colorScheme, 'Edit card', Icons.edit_outlined, onEdit),
          _buildMenuItem(context, colorScheme, 'Remove', Icons.delete, onRemove,
              isDestructive: true),
          _buildMenuItem(context, colorScheme, 'Highlight keyword',
              Icons.highlight_alt_rounded, onKeyword),
          _buildMenuItem(context, colorScheme, 'Remove highlight',
              Icons.format_color_reset_rounded, onRemoveKeyword),
          _buildMenuItem(context, colorScheme, isIgnore ? 'Unignore' : 'Ignore',
              Icons.visibility, onIgnore),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, ColorScheme colorScheme,
      String text, IconData icon, Function() onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isDestructive ? colorScheme.error : colorScheme.primary),
      title: Text(text,
          style: TextStyle(
              color: isDestructive ? colorScheme.error : colorScheme.primary)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
