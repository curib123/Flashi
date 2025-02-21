import 'package:flutter/material.dart';
import 'dart:ui';

void showLoadingDialog(BuildContext context, {required String text}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false, // Prevent back button dismissal
        child: _LoadingDialog(text: text), // Pass text to _LoadingDialog
      );
    },
  );
}

class _LoadingDialog extends StatefulWidget {
  final String text; // Define a text property

  const _LoadingDialog({required this.text}); // Constructor with required text

  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<_LoadingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Rotation duration
    )..repeat(); // Continuous rotation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Fully transparent background
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Subtle blur effect
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1), // Semi-transparent background
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
            children: [
              RotationTransition(
                turns: _controller, // Continuous rotation
                child: Icon(
                  Icons.android,
                  size: 65,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Center( // Ensures the text is centered
                child: Text(
                  widget.text, // Use widget.text instead of text
                  textAlign: TextAlign.center, // Centers the text
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
