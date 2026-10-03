import 'package:flashi/core/design/flashi_design.dart';
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

  const ReusableNotesSummaryBlockCore({
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
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final date = DateFormat('MMM d, yyyy').format(timestamp);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(FlashiDesign.smallRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FlashiDesign.smallRadius),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FlashiDesign.smallRadius),
            border: Border.all(color: colors.outline.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isNote ? Icons.note_alt_outlined : Icons.history_rounded,
                    size: 20,
                    color: colors.primary,
                  ),
                  const Spacer(),
                  if (isNote)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: isFavorite ? 'Remove favorite' : 'Favorite',
                      onPressed: onFavorite,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: isFavorite ? colors.error : colors.primary,
                      ),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  content,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.4,
                    color: colors.onSurface.withOpacity(0.62),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurface.withOpacity(0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
