import 'package:flashi/features/reviewer/presentation/pages/reviewer_page.dart';
import 'package:flashi/features/reviewer/presentation/widgets/review_mode_card.dart';
import 'package:flutter/material.dart';

void showReviewModeDialog({
  required BuildContext context,
  required String heading,
  required List<dynamic> cards,
  required String setname,
}) {
  final List<Map<String, dynamic>> reviewerList = [
    _createReviewerItem(
      context: context,
      icon: Icons.library_books,
      title: 'Flashcard Review',
      subtitle: 'Review material using flashcards',
      cards: cards,
      setname: setname,
    ),
    _createReviewerItem(
      context: context,
      icon: Icons.check_circle,
      title: 'Multiple Choice (Basic)',
      subtitle: 'Choose the correct answer from options',
      cards: cards,
      setname: setname,
    ),
    _createReviewerItem(
      context: context,
      icon: Icons.timer,
      title: 'Multiple Choice (Timer)',
      subtitle: 'Choose the correct answer from options with timer',
      cards: cards,
      setname: setname,
    ),
    _createReviewerItem(
      context: context,
      icon: Icons.task_rounded,
      title: 'Text Input Basic Review',
      subtitle: 'Identify and input the correct answer',
      cards: cards,
      setname: setname,
    ),
    _createReviewerItem(
      context: context,
      icon: Icons.volume_up,
      title: 'Text-to-Speech Review',
      subtitle: 'Listen to prompts and review',
      cards: cards,
      setname: setname,
    ),
  ];

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 15,
        insetAnimationDuration: const Duration(seconds: 2),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(heading: heading),
            _ReviewerSelectionScrollView(reviewerList: reviewerList),
          ],
        ),
      );
    },
  );
}

Map<String, dynamic> _createReviewerItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required List<dynamic> cards,
  required String setname,
}) {
  return {
    'iconData': icon,
    'title': title,
    'subtitle': subtitle,
    'onTap': () => _handleTap(title, context, cards, setname),
  };
}

void _handleTap(
    String title, BuildContext context, List<dynamic> cards, String setname) {
  print('$title tapped');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReviewerPage(
        reviewer: title,
        cards: cards,
        setname: setname,
      ),
    ),
  );
}

class _DialogHeader extends StatelessWidget {
  final String heading;

  const _DialogHeader({required this.heading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Quiz Mode',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    heading,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _ReviewerSelectionScrollView extends StatelessWidget {
  final List<Map<String, dynamic>> reviewerList;

  const _ReviewerSelectionScrollView({required this.reviewerList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: List.generate(reviewerList.length, (index) {
                final reviewer = reviewerList[index];
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: ReviewModeCard(
                          iconData: reviewer['iconData'] ?? Icons.help,
                          title: reviewer['title'] ?? 'No Title',
                          subtitle: reviewer['subtitle'] ?? 'No Subtitle',
                          onTap: reviewer['onTap'],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Swipe up to see more...",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(width: 8),
              _AnimatedArrowIcon(),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedArrowIcon extends StatefulWidget {
  @override
  _AnimatedArrowIconState createState() => _AnimatedArrowIconState();
}

class _AnimatedArrowIconState extends State<_AnimatedArrowIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: const Icon(
            Icons.keyboard_arrow_up,
            color: Colors.grey,
            size: 30,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
