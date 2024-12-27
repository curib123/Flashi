
import 'package:flashlearn/util/helpers/snackbar/reusable_snackbar.dart';
import 'package:flutter/material.dart';

void showDeleteConfirmationDialog({required BuildContext context,required String setName, required Function() onDelete}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)), // Rounded corners
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color:  Theme.of(context).colorScheme.error, size: 30), // Warning icon
            const SizedBox(width: 10),
            Text(
              'Confirm Deletion',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:  Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete $setName',
          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary),
        ),
        actions: <Widget>[
          // No button with style and color
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey, shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('No', style: TextStyle(fontSize: 16)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without deleting
            },
          ),
          // Yes button with style and color
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor:  Theme.of(context).colorScheme.onError,
              backgroundColor:  Theme.of(context).colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Yes', style: TextStyle(fontSize: 16)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              // Add your deletion logic here
              onDelete();
              showCustomSnackbar(context: context,  message: 'Remove {$setName}',);
            },
          ),
        ],
      );
    },
  );
}
