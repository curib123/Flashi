import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/util/helpers/import_export_helper_class.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReusableTitleContent extends StatefulWidget {

  final ColorScheme colorScheme;
  final String title;
  final VoidCallback onUpgradePro;
  final VoidCallback onSettings;

  const ReusableTitleContent({super.key, required this.colorScheme, required this.title, required this.onUpgradePro, required this.onSettings});

  @override
  State<ReusableTitleContent> createState() => _ReusableTitleContentState();
}

class _ReusableTitleContentState extends State<ReusableTitleContent> {

  final ImportExportHelperClass _helper = ImportExportHelperClass(); // Helper instance for export/import


  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: widget.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: widget.title.length >= 12 ?   18: 20,
            overflow: TextOverflow.ellipsis
          ),
        ),
        Row(
          children: [
            // IconButton(
            //     onPressed: onUpgradePro,
            //     icon: Icon(
            //       Icons.diamond_rounded,
            //       color: colorScheme.onPrimary,
            //       size: 30,
            //     )),
            IconButton(
                onPressed: (){
                  _helper.importList(context, quizProvider);
                },
                icon: Icon(
                  Icons.archive_rounded,
                  color: widget.colorScheme.onPrimary,
                  size: 30,
                )),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: widget.onSettings,
              child: CircleAvatar(
                backgroundColor: widget.colorScheme.primary,
                child: Icon(
                  Icons.settings,
                  size: 30,
                  color: widget.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
