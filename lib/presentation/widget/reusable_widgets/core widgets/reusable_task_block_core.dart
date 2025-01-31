import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ReusableTaskBlockCore extends StatelessWidget {
  final String taskName;
  final DateTime dateTime;
  final bool isChecked;
  final bool isUpdated;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap; // Changed to VoidCallback

  const ReusableTaskBlockCore({
    super.key,
    required this.isChecked,
    required this.taskName,
    required this.dateTime,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    required this.isUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Formatting date and time to 12-hour format
    String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);

    // Get the screen width to make it responsive
    double screenWidth = MediaQuery.of(context).size.width;
    double boxSize = screenWidth * 0.4; // Adjust the multiplier as needed for responsiveness

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: _buildContainerDecoration(colorScheme),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: onTap, // Calling onTap without any argument
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start, // Ensures the elements are aligned properly
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  isChecked ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: colorScheme.primary,
                  size: 28, // Reduced icon size for a more minimal look
                ),
                _buildPopupMenuButton(colorScheme),
              ],
            ),
            SizedBox(height: 10),
            Text(
              taskName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
              ),
              maxLines: 4, // Limit to 3 lines
              overflow: TextOverflow.ellipsis, // Add ellipsis (...) after 3rd line
            ),
            SizedBox(height: 6),
            Text(
              '${isUpdated ? 'Updated' : 'Created'}: $formattedDate',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.secondary,
                fontWeight: FontWeight.normal,
                fontSize: 10,
                overflow: TextOverflow.ellipsis,
                decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none, // Apply line-through if checked
              ),
            ),

          ],
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          colorScheme.secondaryContainer,
          colorScheme.tertiaryContainer,
        ],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ),
      borderRadius: BorderRadius.circular(15),

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

  Row _buildPopupMenuItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
