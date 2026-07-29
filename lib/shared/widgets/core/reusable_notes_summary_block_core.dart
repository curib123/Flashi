import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReusableNotesSummaryBlockCore extends StatelessWidget {
  final String title;
  final String content;
  final bool isNote;
  final DateTime timestamp;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ReusableNotesSummaryBlockCore({
    required this.title,
    required this.content,
    required this.timestamp,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    required this.onEdit,
    required this.onDelete,
    required this.isNote,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: _buildContainerDecoration(colorScheme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFavoriteButton(colorScheme),
            Spacer(),
            _buildTitle(colorScheme),
            SizedBox(height: 8),
            _buildSubtitle(colorScheme),
            Spacer(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isNote
            ? [
                colorScheme.secondaryContainer.withOpacity(0.2),
                colorScheme.primaryContainer,
              ]
            : [
                colorScheme.tertiaryContainer.withOpacity(0.2),
                colorScheme.secondaryContainer,
              ], // Fallback gradient colors
        begin: Alignment.bottomCenter,
        end: Alignment.topLeft,
      ),
      borderRadius: BorderRadius.circular(15),
    );
  }

  Row _buildFavoriteButton(ColorScheme colorScheme) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            color: colorScheme.primary,
          ),
          onPressed: onFavorite,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        Spacer(),
        _buildPopupMenuButton(colorScheme)
      ],
    );
  }

  Text _buildTitle(ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Column _buildSubtitle(ColorScheme colorScheme) {
    // Formatting date and time to 12-hour format
    String formattedDate =
        DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          formattedDate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 8,
            color: colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  PopupMenuButton<String> _buildPopupMenuButton(ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      icon: Icon(
        Icons.more_vert_rounded,
        color: colorScheme.primary,
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: _buildPopupMenuItem(
            icon: Icons.edit,
            color: colorScheme.primary,
            text: 'Edit',
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: _buildPopupMenuItem(
            icon: Icons.delete,
            color: colorScheme.error,
            text: 'Delete',
          ),
        ),
      ],
    );
  }

  Row _buildPopupMenuItem(
      {required IconData icon, required Color color, required String text}) {
    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
