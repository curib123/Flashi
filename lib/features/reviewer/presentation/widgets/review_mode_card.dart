import 'package:flutter/material.dart';

class ReviewModeCard extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ReviewModeCard(
      {super.key,
      required this.iconData,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      leading: CircleAvatar(
        backgroundColor:
            Theme.of(context).colorScheme.primaryContainer.withOpacity(.3),
        radius: 30,
        child: Icon(
          iconData,
          size: 30,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 15,
            fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 10,
            fontWeight: FontWeight.normal),
      ),
    );
  }
}
