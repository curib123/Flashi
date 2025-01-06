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
  Map<String, dynamic> _sets = {};  // Holds the selected quiz set
  final ImportExportHelperClass _helper = ImportExportHelperClass();  // Helper instance for export/import

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Export / Import',
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
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildDropdownSection(
            context: context,
            label: 'All Sets',
            value: quizProvider.quizSets.isNotEmpty
                ? quizProvider.quizSets.firstWhere(
                  (set) => set['isDefault'] == true, // Replace with your condition
              orElse: () => quizProvider.quizSets[0],
            )['name']
                : null,
            items: quizProvider.quizSets
                .map((set) => DropdownMenuItem<String>(
              value: set['name'] as String,
              child: Text(set['name'] as String),
            ))
                .toList(),
            onChanged: (String? newValue) {
              setState(() {
                if (newValue != null) {
                  _sets = quizProvider.quizSets.firstWhere(
                        (set) => set['name'] == newValue,
                    orElse: () => {},
                  );
                } else {
                  _sets = {}; // If no value selected, reset
                }
              });
            },
            hintText: 'Select Set to Export',
          ),
        ),

        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _sets.isNotEmpty
                    ? () => _helper.exportList(context, _sets)
                    : null,  // Ensure export button is only enabled if a set is selected
                icon: Icon(Icons.file_upload),
                label: Text("Export Set"),
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(colorScheme.onSecondary),
                  backgroundColor: WidgetStatePropertyAll(colorScheme.secondary),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 15)),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _helper.importList(context, quizProvider),
                icon: Icon(Icons.file_download),
                label: Text("Import Set"),
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(colorScheme.onTertiary),
                  backgroundColor: WidgetStatePropertyAll(colorScheme.tertiary),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 15)),
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
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.6,
      child: ListView(
        children: [
          ReusableQuizSetList(quizSets: quizProvider.quizSets.reversed.toList())
        ],
      ),
    );
  }

  Widget _buildDropdownSection({
    required String hintText,
    required BuildContext context,
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: items,
            onChanged: onChanged,
            hint: Text(hintText),
          ),
        ),
      ],
    );
  }
}
