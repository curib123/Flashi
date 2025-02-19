import 'package:flutter/material.dart';
import 'dart:ui';

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) {
      return _LoadingDialog();
    },
  );
}

class _LoadingDialog extends StatefulWidget {
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
      duration: Duration(seconds: 1), // Rotation duration
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
      elevation: 0, // No shadow
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Subtle blur effect
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05), // Semi-transparent white background
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _controller, // Continuous rotation
                child: Icon(
                  Icons.hourglass_bottom,
                  size: 60,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Please wait...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
