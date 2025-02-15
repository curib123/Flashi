import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flashi/util/helpers/widget/highlight_keywords.dart';

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
    // Get the current color scheme
    final colorScheme = Theme.of(context).colorScheme;

    // Format the timestamp
    String formattedTimestamp = "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 15,
      shadowColor: colorScheme.shadow.withOpacity(0.5),
      child: InkWell(
        onTap: () {
          // Add functionality to reveal the answer or other interactions
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.tertiaryContainer, colorScheme.secondaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
            title: isIgnore
                ? Text(
              "This card has been hidden and marked as ignored.",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary.withOpacity(0.6),
              ),
            )
                : highlightKeywords( context: context, keyword: keyword, text: question, fontSize: 15, fontColor: colorScheme.primary, fontSizeKeyword: 10, isCenter: false), // Add highlight to the question text
            subtitle: isIgnore
                ? null
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2),
                Text(
                  answer,
                  style: TextStyle(fontSize: 16, color: colorScheme.secondary,fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                isUpdating
                    ? Text(
                  "Updated on: $formattedTimestamp",
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                )
                    : Text(
                  "Created on: $formattedTimestamp",
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.volume_up, color: colorScheme.primary),
                  onPressed: () async {
                    await flutterTts.speak('The question: $question The Answer: $answer');
                  },
                  splashColor: colorScheme.primary.withOpacity(0.2),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: colorScheme.primary),
                  onPressed: () {
                    _showPopupMenu(context, colorScheme);
                  },
                  splashColor: colorScheme.primary.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // Popup menu for more options (Edit, Remove, Ignore)
  void _showPopupMenu(BuildContext context, ColorScheme colorScheme) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero); // Get the position

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + renderBox.size.width - 48, // Position based on widget size
        position.dy + 50, // Slightly above to avoid overflow
        0.0,
        0.0,
      ),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: colorScheme.primary),
              SizedBox(width: 8),
              Text('Edit', style: TextStyle(color: colorScheme.primary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete, color: colorScheme.error),
              SizedBox(width: 8),
              Text('Remove', style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'keyword',
          child: Row(
            children: [
              Icon(Icons.key, color: colorScheme.primary),
              SizedBox(width: 8),
              Text('Highlight keyword', style: TextStyle(color: colorScheme.primary)),
            ],
          ),
        ),  PopupMenuItem(
          value: 'remove_keyword',
          child: Row(
            children: [
              Icon(Icons.key_off, color: colorScheme.error),
              SizedBox(width: 8),
              Text('Remove keyword', style: TextStyle(color: colorScheme.primary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'ignore',
          child: Row(
            children: [
              Icon(
                isIgnore ? Icons.visibility_off : Icons.visibility,
                color: colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(isIgnore ? 'Unignore' : 'Ignore', style: TextStyle(color: colorScheme.primary)),
            ],
          ),
        ),
      ],
      elevation: 13.0,
    ).then((value) {
      if (value == 'edit') {
        onEdit();
      } else if (value == 'remove') {
        onRemove();
      } else if (value == 'ignore') {
        onIgnore();
      } else if (value == 'keyword') {
        onKeyword();
      }else if (value == 'remove_keyword') {
        onRemoveKeyword();
      }
    });
  }
}
