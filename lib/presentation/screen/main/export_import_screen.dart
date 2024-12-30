import 'dart:convert';
import 'dart:io';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ExportImportPage extends StatefulWidget {
  @override
  _ExportImportPageState createState() => _ExportImportPageState();
}

class _ExportImportPageState extends State<ExportImportPage> {

  List<Map<String, dynamic>> defaultValue = [
    {
      'name': "Life Lessons (Template)",
      'timestamp': DateTime.now(),
      'description': "Reflective questions to gain insights and wisdom.",
      'cards': [
        {
          'isUpdating': false,
          'question': "What is the most important lesson you’ve learned in life?",
          'answer': "Patience and persistence lead to success.",
          'isIgnore': false,
          'timestamp': DateTime.now()
        },
        {
          'isUpdating': false,
          'question': "What advice would you give to your younger self?",
          'answer': "Don’t fear failure; it’s part of growth.",
          'isIgnore': false,
          'timestamp': DateTime.now()
        },
        {
          'isUpdating': false,
          'question': "What does success mean to you?",
          'answer': "Living a fulfilling and happy life while helping others.",
          'isIgnore': false,
          'timestamp': DateTime.now()
        }
      ],
      'numberOfQuiz': 3,
    },
    {
      'name': "World Trivia (Template)",
      'timestamp': DateTime.now(),
      'description': "Challenge your knowledge about countries and cultures.",
      'cards': [
        {
          'isUpdating': false,
          'question': "What country has the largest population in the world?",
          'answer': "China",
          'isIgnore': false,
          'timestamp': DateTime.now()
        },
        {
          'isUpdating': false,
          'question': "What is the longest river in the world?",
          'answer': "The Nile River",
          'isIgnore': false,
          'timestamp': DateTime.now()
        },
        {
          'isUpdating': false,
          'question': "Which city is known as the 'City of Love'?",
          'answer': "Paris",
          'isIgnore': false,
          'timestamp': DateTime.now()
        }
      ],
      'numberOfQuiz': 3,
    }
  ];

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

  @override
  void initState() {
    super.initState();
    if (defaultValue.isNotEmpty) {
      _sets = defaultValue.first;
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
        _statusMessage = "List exported to: $filePath";
        print("$filePath");
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error during export: $e";
      });
      print("Error during export: $e");
    }
  }

  Map<String, dynamic> _convertTimestampsToString(Map<String, dynamic> data) {
    Map<String, dynamic> convertedData = Map<String, dynamic>.from(data);

    // Convert top-level timestamp to String
    if (convertedData.containsKey('timestamp') && convertedData['timestamp'] is DateTime) {
      convertedData['timestamp'] = (convertedData['timestamp'] as DateTime).toIso8601String();
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
        _sets = _convertTimestamps(importedData);

        setState(() {
          _statusMessage = "List imported from:";
          Provider.of<QuizProvider>(context,listen: false).addQuizSet(_sets);
        });
      } else {
        setState(() {
          _statusMessage = "Import canceled.";
        });
        print("File selection canceled or no file selected.");
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error during import: $e";
      });
      print("Error during import: $e");
    }
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Export / Import',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onPrimary),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: _buildDropdownSection(
                context: context,
                label: 'All Sets',
                value: _sets.isNotEmpty ? _sets['name'] as String? : null,
                items: defaultValue
                    .map((set) => DropdownMenuItem<String>(
                  value: set['name'] as String?,
                  child: Text(set['name'] as String),
                ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _statusMessage = "Selected Set: $newValue";
                    _sets = defaultValue.firstWhere((set) => set['name'] == newValue);
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportList,
                    icon: Icon(Icons.file_upload),
                    label: Text("Export List"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _importList,
                    icon: Icon(Icons.file_download),
                    label: Text("Import List"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Status: $_statusMessage"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required BuildContext context,
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
