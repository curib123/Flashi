import 'package:flashlearn/presentation/widget/components/reviewer_page.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_reviewer_card_core.dart';
import 'package:flutter/material.dart';
void showReviewSelection({required BuildContext context, required String heading}) {
  final List<Map<String, dynamic>> reviewerList = [
    _createReviewerItem(
      context: context, // Pass the context here
      icon: Icons.library_books,
      title: 'Flashcard Review',
      subtitle: 'Review material using flashcards',
    ),
    _createReviewerItem(
      context: context, // Pass the context here
      icon: Icons.check_circle,
      title: 'Multiple Choice',
      subtitle: 'Choose the correct answer from options',
    ),
    _createReviewerItem(
      context: context, // Pass the context here
      icon: Icons.merge_type,
      title: 'Matching Type',
      subtitle: 'Match items to test your knowledge',
    ),
    _createReviewerItem(
      context: context, // Pass the context here
      icon: Icons.question_answer,
      title: 'Q&A Session',
      subtitle: 'Write your answer to the questions',
    ),
    _createReviewerItem(
      context: context, // Pass the context here
      icon: Icons.volume_up,
      title: 'Text-to-Speech Review',
      subtitle: 'Listen to prompts and review',
    ),
    _createReviewerItem(
      context: context, // Pass the context here
      icon: Icons.label,
      title: 'Keywords Review',
      subtitle: 'Create and review keywords',
    ),
  ];

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 10,
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
  required BuildContext context, // Add context as a parameter
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return {
    'iconData': icon,
    'title': title,
    'subtitle': subtitle,
    'onTap': () => _handleTap(title, context), // Pass context to handleTap
  };
}

void _handleTap(String title, BuildContext context) {
  print('$title tapped');
  // Navigate to ReviewerPage when tapped.
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReviewerPage(reviewer: title,),
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
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Reviewers',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Handles text overflow gracefully
                  maxLines: 1, // Ensures text doesn't wrap to a new line
                ),
               Align(
                 alignment: Alignment.topLeft,
                 child:  Text(
                   heading,
                   style: TextStyle(
                     color: Theme.of(context).colorScheme.onPrimary,
                     fontSize: 15,
                     fontWeight: FontWeight.bold,
                   ),
                   overflow: TextOverflow.ellipsis, // Handles text overflow gracefully
                   maxLines: 1, // Ensures text doesn't wrap to a new line
                 ),
               )
              ],
            )
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: reviewerList.map((reviewer) {
            return ReusableReviewerCardCore(
              iconData: reviewer['iconData'] ?? Icons.help,
              title: reviewer['title'] ?? 'No Title',
              subtitle: reviewer['subtitle'] ?? 'No Subtitle',
              onTap: reviewer['onTap'],
            );
          }).toList(),
        ),
      ),
    );
  }
}
