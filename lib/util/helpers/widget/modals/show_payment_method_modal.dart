import 'package:flutter/material.dart';

void showPaymentMethodModal(
    BuildContext context, String method, Function(String) onSave) {
  TextEditingController controller = TextEditingController();
  bool isGcash = method == "GCash";

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
              isGcash ? "Enter GCash Number" : "Enter PayPal Email",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: isGcash ? TextInputType.phone : TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                hintText: isGcash ? "Enter your GCash number" : "Enter your PayPal email",
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                onPressed: () {
                  String inputValue = controller.text.trim();
                  if (inputValue.isNotEmpty) {
                    onSave(inputValue);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
