import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ReusableStudySchedulerCore extends StatelessWidget {
  final String setName;
  final DateTime dateTime;
  final bool isChecked;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap; // Changed to VoidCallback

  const ReusableStudySchedulerCore({
    super.key,
    required this.isChecked,
    required this.setName,
    required this.dateTime,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Formatting date and time to 12-hour format
    String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);

    // Method to check if the date is not in the past
    bool isNotPastDate() {
      return dateTime.isAtSameMomentAs(DateTime.now()) || dateTime.isAfter(DateTime.now());
    }

    return Container(
      decoration: _buildContainerDecoration(colorScheme),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(
          isChecked ? Icons.favorite_rounded : Icons.favorite_border_outlined,
          color: colorScheme.primary,
        ),
        title: Text(
          setName,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            decoration: isNotPastDate() ? TextDecoration.none : TextDecoration.lineThrough, // Apply line-through for past dates
          ),
        ),
        subtitle: Text(
          'Schedule: $formattedDate',
          style: TextStyle(
            color: colorScheme.secondary,
            fontWeight: FontWeight.normal,
            fontSize: 10,
            overflow: TextOverflow.ellipsis,
            decoration: isNotPastDate() ? TextDecoration.none : TextDecoration.lineThrough, // Apply line-through for past dates
          ),
        ),
        trailing: _buildPopupMenuButton(colorScheme),
        onTap: onTap, // Calling onTap without any argument
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
        Text(text),
      ],
    );
  }
}
