import 'dart:developer' as developer;

import 'package:flashi/app/navigation/app_router.dart';
import 'package:flashi/features/reviewer/presentation/widgets/review_mode_card.dart';
import 'package:flutter/material.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';

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
      title: 'Flashcards',
      subtitle: 'Study at your own pace with question and answer cards.',
      cards: cards,
      setname: setname,
    ),
    _createReviewerItem(
      context: context,
      icon: Icons.check_circle,
      title: 'Multiple choice',
      subtitle: 'A focused untimed quiz with instant answer feedback.',
      cards: cards,
      setname: setname,
    ),
    _createReviewerItem(
      context: context,
      icon: Icons.timer,
      title: 'Timed challenge',
      subtitle: 'Answer multiple-choice questions against the clock.',
      cards: cards,
      setname: setname,
    ),
    _createReviewerItem(
      context: context,
      icon: Icons.task_rounded,
      title: 'Written answers',
      subtitle: 'Recall each answer without visible choices.',
      cards: cards,
      setname: setname,
    ),
    _createReviewerItem(
      context: context,
      icon: Icons.volume_up,
      title: 'Listen and answer',
      subtitle: 'Hear each prompt for an audio-first review session.',
      cards: cards,
      setname: setname,
    ),
  ];

  showAppDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AppDialog(
        icon: Icons.school_outlined,
        title: 'Choose a study mode',
        description: heading,
        maxWidth: 560,
        body: _ReviewerSelectionScrollView(reviewerList: reviewerList),
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
  developer.log('$title tapped');
  Navigator.pushNamed(
    context,
    AppRoutes.reviewer,
    arguments: ReviewerArguments(
      reviewer: title,
      cards: cards,
      setname: setname,
    ),
  );
}

class _ReviewerSelectionScrollView extends StatelessWidget {
  final List<Map<String, dynamic>> reviewerList;

  const _ReviewerSelectionScrollView({required this.reviewerList});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 520,
        maxHeight: MediaQuery.sizeOf(context).height * .65,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: List.generate(reviewerList.length, (index) {
          final reviewer = reviewerList[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 180 + (index * 35)),
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
    );
  }
}
