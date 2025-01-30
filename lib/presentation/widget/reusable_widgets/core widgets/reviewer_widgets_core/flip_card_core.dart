import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlipCardCore extends StatefulWidget {
  final Widget question;
  final String answer;
  final FlipDirection flipDirection;
  final VoidCallback onEdit;

  const FlipCardCore({
    Key? key,
    required this.question,
    required this.answer,
    required this.flipDirection,
    required this.onEdit,
  }) : super(key: key);

  @override
  _FlipCardCoreState createState() => _FlipCardCoreState();
}

class _FlipCardCoreState extends State<FlipCardCore> {
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
  }

  Future<void> _speak(String content) async {
    await _flutterTts.speak(content);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlipCard(
        direction: widget.flipDirection,
        front: _buildCardSide(
          context,
          content: widget.question,
          isFront: true,
        ),
        back: _buildCardSide(
          context,
          content: Center(
            child: Text(widget.answer, // Convert answer to Text widget
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onPrimary)),
          ),
          isFront: false,
        ),
      ),
    );
  }

  Widget _buildCardSide(BuildContext context, {required Widget content, required bool isFront}) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Card(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: size.width * 0.90,
            height: size.height * 0.80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isFront
                    ? [colorScheme.primary.withOpacity(.8), colorScheme.tertiary.withOpacity(.8)] // Gradient for front side
                    : [colorScheme.tertiary.withOpacity(.8), colorScheme.primary.withOpacity(.8)], // Gradient for back side
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: Offset(2, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Center(child: content), // Use Widget directly
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            icon: Icon(Icons.edit, color: colorScheme.onPrimary, size: 24),
            onPressed: widget.onEdit,
          ),
        ),
        if (!isFront) // Only show the speaker icon for answers
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.volume_up, color: colorScheme.onPrimary, size: 24),
              onPressed: () => _speak(widget.answer), // Read aloud the answer
            ),
          ),
        Positioned(
          bottom: 16,
          left: size.width * 0.45,
          child: Transform.translate(
            offset: const Offset(-14, 0),
            child: isFront
                ? Icon(Icons.rotate_right, color: colorScheme.onPrimary, size: 40)
                : Icon(Icons.rotate_left, color: colorScheme.onPrimary, size: 40),
          ),
        ),
      ],
    );
  }
}
