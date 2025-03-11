import 'package:flutter/material.dart';

void showGcashNumberModal(BuildContext context, Function(String) onSave) {
  TextEditingController gcashController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter GCash Number",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: gcashController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                hintText: "Enter your GCash number",
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // ✅ Rounded corners
                  borderSide: BorderSide.none, // ✅ No border
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity, // ✅ Full-width button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14), // ✅ Comfortable height
                  backgroundColor: Theme.of(context).colorScheme.primary, // ✅ Primary color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // ✅ Rounded button
                  ),
                  elevation: 3, // ✅ Slight elevation for depth
                ),
                onPressed: () {
                  String gcashNumber = gcashController.text.trim();
                  if (gcashNumber.isNotEmpty) {
                    onSave(gcashNumber);
                    Navigator.pop(context); // Close the modal
                  }
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // ✅ Ensures visibility
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
