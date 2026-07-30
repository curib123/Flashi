import 'package:flutter/material.dart';

void showDeleteConfirmationDialog(
    {required BuildContext context,
    required String setName,
    required Function() onDelete}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(16.0)), // Rounded corners
        ),
        title: Row(
          children: [
            Icon(Icons.warning,
                color: Theme.of(context).colorScheme.error,
                size: 30), // Warning icon
            const SizedBox(width: 10),
            Text(
              'Delete quiz set?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        content: Text(
          'This permanently removes “$setName” and all of its cards.',
          style: TextStyle(
              fontSize: 16, color: Theme.of(context).colorScheme.primary),
        ),
        actions: <Widget>[
          // No button with style and color
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without deleting
            },
          ),
          // Yes button with style and color
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onError,
              backgroundColor: Theme.of(context).colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Delete', style: TextStyle(fontSize: 16)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              // Add your deletion logic here
              onDelete();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  content: Row(
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$setName deleted',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
