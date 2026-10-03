import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reviewer_widgets_core/text_to_speech_card_core.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/widget/other/highlight_keywords.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechReview extends StatefulWidget {
  final String reviewer;
  final List<dynamic> cards;
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
  final FlutterTts _flutterTts = FlutterTts();
  final AdManager _adManager = AdManager();

  late final PageController _pageController;
  bool _isSpeaking = false;
  int _currentIndex = 0;
  int _speechSession = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _adManager.loadInterstitialAd(AdUnitId.interstitialAdUnitId);
  }

  @override
  void dispose() {
    _speechSession++;
    _flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _speakAndAutoScroll() async {
    if (_isSpeaking || widget.cards.isEmpty) return;

    final session = ++_speechSession;
    await _flutterTts.awaitSpeakCompletion(true);

    if (!mounted || session != _speechSession) return;
    setState(() => _isSpeaking = true);

    try {
      for (var index = _currentIndex; index < widget.cards.length; index++) {
        if (!mounted || session != _speechSession) return;

        final card = widget.cards[index];
        final question =
            (card['question'] ?? 'No question available').toString();
        final answer = (card['answer'] ?? 'No answer available').toString();

        await _flutterTts.speak('Question: $question. Answer: $answer.');

        if (!mounted || session != _speechSession) return;

        if (index < widget.cards.length - 1) {
          final nextIndex = index + 1;
          setState(() => _currentIndex = nextIndex);

          if (_pageController.hasClients) {
            await _pageController.animateToPage(
              nextIndex,
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    } finally {
      if (mounted && session == _speechSession) {
        setState(() => _isSpeaking = false);
      }
    }
  }

  Future<void> _resetSpeech() async {
    _speechSession++;
    await _flutterTts.stop();

    if (!mounted) return;
    setState(() {
      _isSpeaking = false;
      _currentIndex = 0;
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.record_voice_over_outlined,
                size: 46,
                color: FlashiDesign.brand,
              ),
              const SizedBox(height: 12),
              Text(
                'No cards available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            physics: _isSpeaking
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            controller: _pageController,
            itemCount: widget.cards.length,
            onPageChanged: (index) {
              if (index == _currentIndex) return;
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final card = widget.cards[index];
              return TextToSpeechCardCore(
                question: highlightKeywords(
                  context: context,
                  keyword: card['keyword'],
                  text: card['question'],
                  fontSize: 22,
                  fontColor: Theme.of(context).colorScheme.onPrimary,
                  fontSizeKeyword: 17,
                  isCenter: true,
                ),
                answer: card['answer'] ?? 'No answer available',
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: FlashiDesign.surfaceOf(context),
              border: Border(
                top: BorderSide(color: FlashiDesign.borderOf(context)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSpeaking ? null : _speakAndAutoScroll,
                    icon: Icon(
                      _isSpeaking
                          ? Icons.graphic_eq_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(_isSpeaking ? 'Speaking…' : 'Start speech'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _resetSpeech,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
