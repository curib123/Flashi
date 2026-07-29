// Dot Waving Animation Widget
import 'package:flutter/material.dart';

class ReusableTypingAnimationCore extends StatefulWidget {
  const ReusableTypingAnimationCore({super.key});

  @override
  _ReusableTypingAnimationCoreState createState() =>
      _ReusableTypingAnimationCoreState();
}

class _ReusableTypingAnimationCoreState
    extends State<ReusableTypingAnimationCore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset:
                  Offset(0, 4 * (1 - (_controller.value + (index * 0.2)) % 1)),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
