import 'dart:async';

import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/core/ads/ad_unit_id.dart';
import 'package:flashi/shared/widgets/highlighted_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flashi/features/reviewer/presentation/widgets/text_to_speech_card.dart';

class TextToSpeechReview extends StatefulWidget {
  final String reviewer;
  final List<dynamic> cards; // List of cards with 'question' and 'answer'
  final String setname;

  const TextToSpeechReview({
    super.key,
    required this.reviewer,
    required this.cards,
    required this.setname,
  });

  @override
  State<TextToSpeechReview> createState() => _TextToSpeechReviewState();
}

class _TextToSpeechReviewState extends State<TextToSpeechReview> {
  final FlutterTts _flutterTts = FlutterTts(); // Initialize TTS
  late final PageController _pageController; // Controller for PageView
  bool _isSpeaking = false; // Track if TTS is speaking
  int _currentIndex = 0; // Track current page index
  AdManager adManager = AdManager();
  Timer? _adPreloadTimer;
  int _speechRevision = 0;

  @override
  void initState() {
    super.initState();

    _adPreloadTimer = Timer(const Duration(minutes: 5), () {
      adManager.loadInterstitialAd(AdUnitId.interstitialAdUnitId);
    });

    _pageController =
        PageController(initialPage: _currentIndex); // Start at the first card
  }

  @override
  void dispose() {
    _speechRevision++;
    _adPreloadTimer?.cancel();
    _flutterTts.stop(); // Stop TTS when widget is disposed
    _pageController.dispose(); // Dispose PageController
    super.dispose();
  }

  Future<void> _speakAndAutoScroll() async {
    if (_isSpeaking) return;
    final revision = ++_speechRevision;

    setState(() {
      _isSpeaking = true;
    });

    for (int i = _currentIndex; i < widget.cards.length; i++) {
      final card = widget.cards[i];
      final question = card['question'] ?? 'No question available';
      final answer = card['answer'] ?? 'No answer available';

      // Speak the content
      await _flutterTts.speak("Question: $question. Answer: $answer.");
      if (!mounted || revision != _speechRevision) return;

      // Wait for the speech to complete
      await _flutterTts.awaitSpeakCompletion(true);
      if (!mounted || revision != _speechRevision) return;

      // Move to the next page if not on the last one
      if (i < widget.cards.length - 1) {
        setState(() {
          _currentIndex = i + 1;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }

    if (!mounted || revision != _speechRevision) return;
    setState(() {
      _isSpeaking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Center(
        child: Text(
          "No cards available",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }

    //ads here

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: _pageController,
            itemCount: widget.cards.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final card = widget.cards[index];
              return TextToSpeechCard(
                question: highlightKeywords(
                    context: context,
                    keyword: card['keyword'],
                    text: card['question'],
                    fontSize: 22,
                    fontColor: Theme.of(context).colorScheme.onSurface,
                    fontSizeKeyword: 17,
                    isCenter: true),
                answer: card['answer'] ?? 'No answer available',
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _speakAndAutoScroll,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text(
                  _isSpeaking ? "Speaking..." : "Start Speech",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_isSpeaking) {
                    _speechRevision++;
                    _flutterTts.stop();
                  }

                  setState(() {
                    _currentIndex = 0;
                    _isSpeaking = false;
                  });
                  _pageController.jumpToPage(0);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
