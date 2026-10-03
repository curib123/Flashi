import 'package:flashi/core/design/flashi_design.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReusableNotesSummaryTileCore extends StatelessWidget {
  final String title;
  final String content;
  final bool isNote;
  final DateTime timestamp;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isHistoryScreen;

  const ReusableNotesSummaryTileCore({
    super.key,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    required this.onEdit,
    required this.onDelete,
    required this.isNote,
    required this.isHistoryScreen,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final date = DateFormat('MMM d, yyyy · h:mm a').format(timestamp);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(FlashiDesign.smallRadius),
        border: Border.all(color: colors.outline.withOpacity(0.12)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        leading: isHistoryScreen
            ? null
            : IconButton(
                tooltip: isFavorite ? 'Remove favorite' : 'Favorite',
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? colors.error : colors.primary,
                ),
              ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1.35,
                  color: colors.onSurface.withOpacity(0.62),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                date,
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurface.withOpacity(0.48),
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
