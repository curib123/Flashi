import 'dart:convert';
import 'dart:io';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_quiz_set_summary_list.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flashlearn/provider/quiz_provider.dart';

class ExportImportPage extends StatefulWidget {
  @override
  _ExportImportPageState createState() => _ExportImportPageState();
}

class _ExportImportPageState extends State<ExportImportPage> {
  Map<String, dynamic> _sets = {};
  String _statusMessage = "Ready";
  final String _directory = '/storage/emulated/0/FlashLearn/Export/Sets';

  Future<void> _requestPermissions() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
    if (!await Permission.manageExternalStorage.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  Future<void> _exportList() async {
    try {
      await _requestPermissions();
      final rootDirectory = Directory(_directory);

      if (!rootDirectory.existsSync()) {
        await rootDirectory.create(recursive: true);
      }

      String fileName = '${_sets['name'] ?? 'exported_list'}.json';
      final filePath = "${rootDirectory.path}/$fileName";
      final file = File(filePath);

      // Convert to JSON with timestamp as String
      String exportedJson = jsonEncode(_convertTimestampsToString(_sets));

      await file.writeAsString(exportedJson);

      setState(() {
        if (_sets.isNotEmpty) {
          _statusMessage = "List exported to: $filePath";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Export Successful: The list has been exported to $filePath"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _statusMessage = "Select Set To Export";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("No Set Selected. Please select a set to export."),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error during export: $e";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Export Failed: Error during export: $e"),
            backgroundColor: Colors.red,
          ),
        );
      });
      print("Error during export: $e");
    }
  }

  Future<void> _importList() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'], // Only allow JSON files
        initialDirectory: _directory,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final contents = await file.readAsString();

        // Parse JSON and convert timestamps
        Map<String, dynamic> importedData = jsonDecode(contents);

        // Check if the map already exists in the _sets variable
        if (_sets['name'] == importedData['name']) {
          setState(() {
            _statusMessage = "This set is already imported.";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Oops! This set already exists! Delete The exist to Continue"),
                backgroundColor: Colors.orange,
              ),
            );
          });
          return; // Skip the import if it's a duplicate
        }

        _sets = _convertTimestamps(importedData);

        setState(() {
          _statusMessage = "List imported from:";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Import Successful: The list has been imported successfully."),
              backgroundColor: Colors.green,
            ),
          );

          Provider.of<QuizProvider>(context, listen: false).addQuizSet(_sets);
        });
      } else {
        setState(() {
          _statusMessage = "Import canceled.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Import Canceled: No file selected or import was canceled."),
              backgroundColor: Colors.red,
            ),
          );
        });
        print("File selection canceled or no file selected.");
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error during import: $e";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Import Failed: Error during import: $e"),
            backgroundColor: Colors.red,
          ),
        );
      });
      print("Error during import: $e");
    }
  }


  Map<String, dynamic> _convertTimestampsToString(Map<String, dynamic> data) {
    Map<String, dynamic> convertedData = Map<String, dynamic>.from(data);

    // Convert top-level timestamp to String
    if (convertedData.containsKey('timestamp') &&
        convertedData['timestamp'] is DateTime) {
      convertedData['timestamp'] =
          (convertedData['timestamp'] as DateTime).toIso8601String();
    }

    // Convert timestamps inside cards to String
    if (convertedData.containsKey('cards')) {
      List<dynamic> cards = convertedData['cards'];
      for (var card in cards) {
        if (card.containsKey('timestamp') && card['timestamp'] is DateTime) {
          card['timestamp'] = (card['timestamp'] as DateTime).toIso8601String();
        }
      }
    }

    return convertedData;
  }

  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    // Parse the top-level timestamp if it exists
    if (data.containsKey('timestamp')) {
      data['timestamp'] = DateTime.parse(data['timestamp']);
    }

    // Parse timestamps inside cards
    if (data.containsKey('cards')) {
      List<dynamic> cards = data['cards'];
      for (var card in cards) {
        if (card.containsKey('timestamp')) {
          card['timestamp'] = DateTime.parse(card['timestamp']);
        }
      }
    }

    return data;
  }

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
            _Header(colorScheme, quizProvider),
            SizedBox(height: 10),
            _SetTile(quizProvider),
          ],
        ),
      ),
    );
  }

  Widget _Header(ColorScheme colorScheme, QuizProvider quizProvider) {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: _buildDropdownSection(
            context: context,
            label: 'All Sets',
            value: _sets.isNotEmpty ? _sets['name'] as String? : null,
            items: quizProvider.quizSets
                .map((set) => DropdownMenuItem<String>(
              value: set['name'] as String?,
              child: Text(
                set['name'] as String,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ))
                .toList(),
            onChanged: (newValue) {
              setState(() {
                _statusMessage = "Selected Set: $newValue";
                _sets = quizProvider.quizSets
                    .firstWhere((set) => set['name'] == newValue);
              });
            },
            hintText: 'Select Set to Export',
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center buttons horizontally
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _exportList,
                icon: Icon(Icons.file_upload),
                label: Text("Export List"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _importList,
                icon: Icon(Icons.file_download),
                label: Text("Import List"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.tertiary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _SetTile(QuizProvider quizProvider) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.6,
      child: ListView(
        children: [
          ReusableQuizSetSummaryList(quizSets: quizProvider.quizSets.reversed.toList())
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
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: items,
            onChanged: onChanged,
            hint: Text(
              hintText,
              style: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            underline: SizedBox(), // Remove the underline for a cleaner look
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
