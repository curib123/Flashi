import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Flashcard extends StatefulWidget {
  final Widget question;
  final String answer;
  final FlipDirection flipDirection;
  final VoidCallback onEdit;

  const Flashcard({
    super.key,
    required this.question,
    required this.answer,
    required this.flipDirection,
    required this.onEdit,
  });

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard> {
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
            child: Text(
              widget.answer,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          isFront: false,
        ),
      ),
    );
  }

  Widget _buildCardSide(BuildContext context,
      {required Widget content, required bool isFront}) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          width: size.width * 0.90,
          height: size.height * 0.80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: isFront
                  ? [
                      colorScheme.primary.withValues(alpha: 0.8),
                      colorScheme.primary.withValues(alpha: 0.5),
                    ]
                  : [
                      colorScheme.primary.withValues(alpha: 0.5),
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Center(child: content),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 26),
            onPressed: widget.onEdit,
          ),
        ),
        if (!isFront)
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.white, size: 26),
              onPressed: () => _speak(widget.answer),
            ),
          ),
        Positioned(
          bottom: 16,
          left: size.width * 0.45,
          child: Transform.translate(
            offset: const Offset(-14, 0),
            child: Icon(
              isFront ? Icons.flip : Icons.flip,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}
