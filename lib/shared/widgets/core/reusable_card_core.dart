import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flashi/shared/widgets/highlighted_text.dart';

class ReusableCardCore extends StatelessWidget {
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

  ReusableCardCore({
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 10,
      shadowColor: colorScheme.shadow.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withOpacity(0.9),
                colorScheme.primaryContainer.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isIgnore)
                Text(
                  "This card is hidden.",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary.withOpacity(0.5)),
                )
              else ...[
                highlightKeywords(
                  context: context,
                  keyword: keyword,
                  text: question,
                  fontSize: 14,
                  fontColor: colorScheme.primary,
                  fontSizeKeyword: 12,
                  isCenter: false,
                ),
                const SizedBox(height: 8),
                Text(
                  answer,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.secondary),
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
                      icon: Icon(Icons.volume_up_rounded,
                          color: colorScheme.primary),
                      onPressed: () async {
                        await flutterTts.speak(
                            'The question: $question The answer: $answer');
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert_rounded,
                          color: colorScheme.primary),
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
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Wrap(
        children: [
          _buildMenuItem(context, colorScheme, 'Edit', Icons.edit, onEdit),
          _buildMenuItem(context, colorScheme, 'Remove', Icons.delete, onRemove,
              isDestructive: true),
          _buildMenuItem(
              context, colorScheme, 'Highlight keyword', Icons.key, onKeyword),
          _buildMenuItem(context, colorScheme, 'Remove keyword', Icons.key_off,
              onRemoveKeyword),
          _buildMenuItem(context, colorScheme, isIgnore ? 'Unignore' : 'Ignore',
              Icons.visibility, onIgnore),
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
