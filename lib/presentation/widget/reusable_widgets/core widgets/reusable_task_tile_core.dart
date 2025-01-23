import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ReusableTaskTileCore extends StatelessWidget {
  final String taskName;
  final DateTime dateTime;
  final bool isChecked;
  final bool isUpdated;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap; // Changed to VoidCallback

  const ReusableTaskTileCore({
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

    return Container(
      decoration:_buildContainerDecoration(colorScheme) ,
      margin: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
      child: ListTile(

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Icon(
          isChecked ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: colorScheme.primary,
        ),
        title: Text(
          taskName,
          style: TextStyle(
            fontSize: taskName.length <= 13 ? 15 : 13,
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            decoration: !isChecked ? TextDecoration.none : TextDecoration.lineThrough, // Apply line-through for past dates
          ),
        ),
        subtitle: Text(
          '${isUpdated ? 'Updated' : 'Created'}: $formattedDate',
          style: TextStyle(
            color: colorScheme.secondary,
            fontWeight: FontWeight.normal,
            fontSize: 10,
            overflow: TextOverflow.ellipsis,
            decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none, // Apply line-through if checked
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
