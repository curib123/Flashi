import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_spacing.dart';

class QuizSetCard extends StatelessWidget {
  final String name;
  final String description;
  final int numberOfQuiz;
  final VoidCallback onTap,
      onAddCard,
      onReview,
      onDelete,
      onEdit,
      onFavorate,
      onShare,
      onExport,
      onViewAllCards;
  final DateTime timestamp;
  final bool isFavorate;

  const QuizSetCard({
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
    final colorScheme = Theme.of(context).colorScheme;
    final String formattedTimestamp =
        DateFormat('MMM d, yyyy').format(timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: AppRadii.large,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadii.medium,
                    ),
                    child: Center(
                      child: Text(
                        numberOfQuiz.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          '$numberOfQuiz ${numberOfQuiz == 1 ? 'card' : 'cards'} · Updated $formattedTimestamp',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (description.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: colorScheme.surfaceContainerHigh,
                    icon: const Icon(Icons.more_horiz_rounded),
                    onSelected: (String value) {
                      switch (value) {
                        case 'favorate':
                          onFavorate();
                          break;
                        case 'edit':
                          onEdit();
                          break;
                        case 'view_all':
                          onViewAllCards();
                          break;
                        case 'export':
                          onExport();
                          break;
                        case 'share':
                          onShare();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      _buildPopupMenuItem(
                          isFavorate ? 'Remove favorite' : 'Add to favorites',
                          isFavorate ? Icons.favorite : Icons.favorite_border,
                          'favorate',
                          colorScheme.onSurface),
                      _buildPopupMenuItem('Edit', Icons.edit_outlined, 'edit',
                          colorScheme.onSurface),
                      _buildPopupMenuItem(
                          'View cards',
                          Icons.view_agenda_outlined,
                          'view_all',
                          colorScheme.onSurface),
                      _buildPopupMenuItem('Export', Icons.download_outlined,
                          'export', colorScheme.onSurface),
                      _buildPopupMenuItem(
                          'Delete', Icons.delete, 'delete', colorScheme.error),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onAddCard,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add card'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onReview,
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('Study'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String text, IconData icon, String value, Color iconColor) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: iconColor)),
        ],
      ),
    );
  }
}
