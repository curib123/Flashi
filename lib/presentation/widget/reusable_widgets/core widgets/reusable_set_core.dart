import 'package:flashi/core/design/flashi_design.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReusableSetCore extends StatelessWidget {
  final String name;
  final String description;
  final int numberOfQuiz;
  final VoidCallback onTap;
  final VoidCallback onAddCard;
  final VoidCallback onReview;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onFavorate;
  final VoidCallback onShare;
  final VoidCallback onExport;
  final VoidCallback onViewAllCards;
  final DateTime timestamp;
  final bool isFavorate;

  const ReusableSetCore({
    super.key,
    required this.name,
    required this.description,
    required this.numberOfQuiz,
    required this.onTap,
    required this.onAddCard,
    required this.onReview,
    required this.onDelete,
    required this.onEdit,
    required this.onFavorate,
    required this.onViewAllCards,
    required this.timestamp,
    required this.isFavorate,
    required this.onShare,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final updated = DateFormat('MMM d, yyyy').format(timestamp);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(FlashiDesign.radius),
        border: Border.all(color: colors.outline.withOpacity(0.13)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FlashiDesign.radius),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.layers_rounded, color: colors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description.isEmpty ? 'No description' : description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colors.onSurface.withOpacity(0.6),
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: isFavorate ? 'Remove favorite' : 'Favorite',
                      onPressed: onFavorate,
                      icon: Icon(
                        isFavorate
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorate ? colors.error : colors.onSurfaceVariant,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit();
                            break;
                          case 'view':
                            onViewAllCards();
                            break;
                          case 'export':
                            onExport();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit set')),
                        PopupMenuItem(value: 'view', child: Text('View all cards')),
                        PopupMenuItem(value: 'export', child: Text('Export')),
                        PopupMenuDivider(),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(
                      icon: Icons.style_outlined,
                      label: numberOfQuiz.toString() + ' cards',
                    ),
                    _InfoPill(
                      icon: Icons.schedule_rounded,
                      label: 'Updated ' + updated,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onAddCard,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add cards'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onReview,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Review'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.45),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
