import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReusableSetCore extends StatelessWidget {
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
    final colorScheme = Theme.of(context).colorScheme;
    final String formattedTimestamp =
        DateFormat('yyyy-MM-dd HH:mm').format(timestamp);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.9),
            colorScheme.primaryContainer.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12.0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        numberOfQuiz.toString(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Last Updated: $formattedTimestamp',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: colorScheme.secondary,
                          ),
                        ),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: colorScheme.surface,
                    icon: Icon(Icons.more_vert, color: colorScheme.primary),
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
                          'Favorate',
                          isFavorate ? Icons.favorite : Icons.favorite_border,
                          'favorate',
                          colorScheme.error),
                      _buildPopupMenuItem(
                          'Edit', Icons.edit, 'edit', colorScheme.primary),
                      _buildPopupMenuItem('View All Pairs', Icons.view_agenda,
                          'view_all', colorScheme.primary),
                      _buildPopupMenuItem('Save in Folder', Icons.save,
                          'export', colorScheme.primary),
                      _buildPopupMenuItem(
                          'Delete', Icons.delete, 'delete', colorScheme.error),
                    ],
                  ),
                ],
              ),
              Divider(
                  height: 20.0, color: colorScheme.primary.withOpacity(0.6)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton('Add Pairs', Icons.add_circle, onAddCard,
                      colorScheme.primary),
                  _buildActionButton('Quiz Mode', Icons.rate_review, onReview,
                      colorScheme.secondary),
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

  TextButton _buildActionButton(
      String label, IconData icon, VoidCallback onPressed, Color color) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 15)),
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
