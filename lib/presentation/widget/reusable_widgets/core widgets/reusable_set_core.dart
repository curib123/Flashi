import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class ReusableSetCore extends StatelessWidget {
  final String name;
  final String description;
  final int numberOfQuiz;
  final VoidCallback onTap;
  final VoidCallback onAddCard; // Action for "Add Cards"
  final VoidCallback onReview; // Action for "Review"
  final VoidCallback onDelete; // Action for "Delete"
  final VoidCallback onEdit; // Action for "Edit"
  final VoidCallback onFavorate; // Action for "Favorate"
  final VoidCallback onViewAllCards; // Action for "View All Cards"
  final DateTime timestamp; // Added timestamp parameter
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
    required this.onEdit, // Added parameter
    required this.onFavorate, // Added parameter
    required this.onViewAllCards, // Added parameter
    required this.timestamp,
    required this.isFavorate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm').format(timestamp);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiaryContainer.withOpacity(.8),
            colorScheme.primaryContainer.withOpacity(.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Subtle shadow
            blurRadius: 10.0,
            offset: const Offset(0, 7), // Shadow position
          ),
        ],
        color: Colors.white, // Background color
      ),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with More Options icon
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Left-side icon or avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        numberOfQuiz.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // Text information
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
                          'Last updated: $formattedTimestamp',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // More Options Dropdown
                  Align(
                    alignment: Alignment.topRight,
                    child: PopupMenuButton<String>(
                      elevation: 15,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      shadowColor: colorScheme.primary,
                      color: colorScheme.onPrimary,
                      icon: Icon(Icons.more_vert, color: colorScheme.primary),
                      onSelected: (String value) {
                        if (value == 'delete') {
                          onDelete();
                        } else if (value == 'edit') {
                          onEdit();
                        } else if(value == 'favorate'){
                          onFavorate();
                        } else if(value == 'view_all'){
                          onViewAllCards();
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'favorate',
                            child: Row(
                              children: [
                                isFavorate ?  Icon(Icons.favorite, color: colorScheme.error) :  Icon(Icons.favorite_outline, color: colorScheme.error),
                                const SizedBox(width: 8),
                                Text('Favorate', style: TextStyle(color: colorScheme.primary)),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: colorScheme.primary),
                                const SizedBox(width: 8),
                                Text('Edit', style: TextStyle(color: colorScheme.primary)),
                              ],
                            ),
                          ),
                          // View All Cards Option
                          PopupMenuItem<String>(
                            value: 'view_all',
                            child: Row(
                              children: [
                                Icon(Icons.add_card, color: colorScheme.primary),
                                const SizedBox(width: 8),
                                Text('View All Cards', style: TextStyle(color: colorScheme.primary)),
                              ],
                            ),
                          ),
                          // Delete Option
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: colorScheme.error),
                                const SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: colorScheme.error)),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Displaying timestamp
            Divider(height: 1.0, color: colorScheme.primary),
            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Add Cards Button
                  TextButton.icon(
                    onPressed: onAddCard,
                    icon: Icon(Icons.add_circle, color: colorScheme.primary),
                    label: Text(
                      "Add Cards",
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                  // Review Button
                  TextButton.icon(
                    onPressed: onReview,
                    icon: Icon(Icons.rate_review, color: colorScheme.secondary),
                    label: Text(
                      "Review",
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
