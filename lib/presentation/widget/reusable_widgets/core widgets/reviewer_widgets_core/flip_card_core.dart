import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlipCardCore extends StatefulWidget {
  final String question;
  final String answer;
  final FlipDirection flipDirection;
  final VoidCallback onEdit;

  const FlipCardCore({
    Key? key,
    required this.question,
    required this.answer,
    this.flipDirection = FlipDirection.HORIZONTAL, // Default to horizontal
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
          content: widget.answer,
          isFront: false,
        ),
      ),
    );
  }

  Widget _buildCardSide(BuildContext context, {required String content, required bool isFront}) {
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
            height: size.height * 0.70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isFront
                    ? [colorScheme.primary, colorScheme.tertiary] // Gradient for the front side
                    : [colorScheme.tertiary, colorScheme.primary], // Gradient for the back side
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
            child: Center(
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
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
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(Icons.volume_up, color: colorScheme.onPrimary, size: 24),
            onPressed: () => _speak(content), // Trigger TTS for the current content
          ),
        ),
        Positioned(
          bottom: 16, // Adjusted distance from the bottom edge
          left: size.width * 0.45, // Center horizontally based on the card's width
          child: Transform.translate(
            offset: Offset(-14, 0), // Adjust to ensure the icon is centered
            child: isFront
                ? Icon(Icons.rotate_right, color: colorScheme.onPrimary, size: 40)
                : Icon(Icons.rotate_left, color: colorScheme.onPrimary, size: 40),
          ),
        ),

      ],
    );
  }
}
