import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_spacing.dart';

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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.readingMaxWidth,
            minHeight: 420,
            maxHeight: 620,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isFront
                  ? colorScheme.surfaceContainerLow
                  : colorScheme.surfaceContainerHigh,
              borderRadius: AppRadii.large,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(child: content),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: IconButton(
            tooltip: 'Edit card',
            icon: const Icon(Icons.edit_outlined),
            onPressed: widget.onEdit,
          ),
        ),
        if (!isFront)
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              tooltip: 'Read answer',
              icon: const Icon(Icons.volume_up_outlined),
              onPressed: () => _speak(widget.answer),
            ),
          ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Icon(
            Icons.flip_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 28,
          ),
        ),
      ],
    );
  }
}
