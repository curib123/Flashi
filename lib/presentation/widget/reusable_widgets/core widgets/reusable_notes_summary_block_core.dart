import 'package:flutter/material.dart';

class ReusableNotesSummaryBlockCore extends StatelessWidget {
  final String title;
  final String content;
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
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(10),
        decoration: _buildContainerDecoration(colorScheme),
        width: 150,
        height: 150,
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
        colors: [
          colorScheme.primaryContainer,
          colorScheme.secondaryContainer,
        ],
        begin: Alignment.bottomRight,
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

  Text _buildSubtitle(ColorScheme colorScheme) {
    return Text(
      content,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: colorScheme.secondary,
      ),
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

  Row _buildPopupMenuItem({required IconData icon, required Color color, required String text}) {
    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
