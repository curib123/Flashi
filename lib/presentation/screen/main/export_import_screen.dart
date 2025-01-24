import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashlearn/util/helpers/import_export_helper_class.dart';
import 'package:flutter/material.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
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
          'Import / Restore Set',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back_ios_new_rounded, color: colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildHeader(colorScheme, quizProvider),
            SizedBox(height: 10),
            _buildSetTile(quizProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, QuizProvider quizProvider) {
    return Column(
      children: [

        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _helper.importList(context, quizProvider),
                icon: Icon(Icons.file_download,color: Colors.white,),
                label: Text("Import Set"),
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(
                      colorScheme.onTertiary),
                  backgroundColor: WidgetStatePropertyAll(colorScheme.tertiary),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 15)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSetTile(QuizProvider quizProvider) {
    final size = MediaQuery
        .of(context)
        .size;
    return Container(
      height: size.height * 0.6,
      child: ListView(
        children: [
          ReusableQuizSetList(quizSets: quizProvider.quizSets.reversed.toList())
        ],
      ),
    );
  }
}
