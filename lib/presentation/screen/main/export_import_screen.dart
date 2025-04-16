
import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/other/import_export_helper_class.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExportImportScreen extends StatefulWidget {
  @override
  _ExportImportScreenState createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends State<ExportImportScreen> {
  final ImportExportHelperClass _helper = ImportExportHelperClass(); // Helper instance for export/import

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Import / Export Set',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back_ios_new_rounded, color: colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: colorScheme.onPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(

          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(),
        child: Column(
          children: [
            _buildSetTile(quizProvider),
            SizedBox(height: 5),
            _buildHeader(colorScheme, quizProvider),


          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, QuizProvider quizProvider) {
    return  ReusableCreateSetButtonPosition(
      icon: Icons.import_export_rounded,
      colorScheme: colorScheme,
      name: 'Import Quiz Set',
      onTap: ()  {
        _helper.importList(context, quizProvider);
      },
    );
  }

  Widget _buildSetTile(QuizProvider quizProvider) {
    final size = MediaQuery
        .of(context)
        .size;

    return Container(
      height: size.height * 0.75,
      child: quizProvider.quizSets.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.import_contacts, // Icon for importing subjects
              size: 60,
              color: Colors.grey[400],
            ),
            SizedBox(height: 10),
            Text(
              "Import Subject Now.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : ListView(
        children: [
          ReusableQuizSetList(
            quizSets: quizProvider.quizSets.reversed.toList(),
          ),
        ],
      ),
    );
  }
}
