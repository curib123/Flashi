import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReusableNotesSummaryTileCore extends StatelessWidget {
  final String title;
  final String content;
  final DateTime timestamp;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ReusableNotesSummaryTileCore({
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
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: _buildContainerDecoration(colorScheme),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          leading: _buildFavoriteButton(colorScheme),
          title: _buildTitle(colorScheme),
          subtitle: _buildSubtitle(colorScheme),
          trailing: _buildPopupMenuButton(colorScheme),
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

  IconButton _buildFavoriteButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
        color: colorScheme.primary,
      ),
      onPressed: onFavorite,
    );
  }

  Text _buildTitle(ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
        overflow: TextOverflow.ellipsis
      ),
    );
  }
  Column _buildSubtitle(ColorScheme colorScheme) {
    // Formatting date and time to 12-hour format
    String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp);

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
        const SizedBox(height: 10,),
        Text(
          formattedDate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
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
