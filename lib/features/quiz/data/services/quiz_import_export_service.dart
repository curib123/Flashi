import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';

class QuizImportExportService {
  Future<void> exportList(
      BuildContext context, Map<String, dynamic> sets) async {
    try {
      final fileName = '${_safeFileName(sets['name'])} (Flashi).json';
      final bytes = Uint8List.fromList(
        utf8.encode(jsonEncode(convertTimestampsToString(sets))),
      );
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export quiz set',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['json'],
        bytes: bytes,
      );
      if (!context.mounted) return;

      if (savedPath == null) {
        showSnack(context, 'Export canceled.', Colors.orange);
        return;
      }
      showSnack(context, 'Quiz set exported successfully.', Colors.green);
    } catch (e) {
      if (!context.mounted) return;
      showSnack(context, 'Export failed. Please choose another location.',
          Colors.red);
      developer.log('Quiz export failed.', error: e);
    }
  }

  Future<void> importList(
      BuildContext context, QuizProvider quizProvider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Import quiz set',
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (!context.mounted) return;

      if (result != null) {
        final selectedFile = result.files.single;
        final bytes = selectedFile.bytes ??
            (selectedFile.path == null
                ? null
                : await File(selectedFile.path!).readAsBytes());
        if (bytes == null) {
          throw const FormatException('The selected file could not be opened.');
        }
        final decoded = jsonDecode(utf8.decode(bytes));
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('The file is not a Flashi quiz set.');
        }
        if (!context.mounted) return;
        final importedData = decoded;

        bool isDuplicate = quizProvider.quizSets
            .any((set) => set['name'] == importedData['name']);

        if (isDuplicate) {
          showSnack(context, "Oops! This set already exists!", Colors.orange);
        } else {
          Map<String, dynamic> sets = _convertTimestamps(importedData);
          quizProvider.addQuizSet(sets);
          showSnack(context, "Import Successful!", Colors.green);
        }
      } else {
        showSnack(context, 'Import canceled.', Colors.orange);
      }
    } catch (e) {
      if (!context.mounted) return;
      showSnack(context, 'Import failed. Select a valid Flashi JSON file.',
          Colors.red);
      developer.log('Quiz import failed.', error: e);
    }
  }

  static String _safeFileName(Object? value) {
    final name = (value?.toString().trim().isNotEmpty ?? false)
        ? value.toString().trim()
        : 'Quiz Set';
    return name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
  }

  static Map<String, dynamic> convertTimestampsToString(
      Map<String, dynamic> data) {
    Map<String, dynamic> converted = Map<String, dynamic>.from(data);
    if (converted.containsKey('timestamp') &&
        converted['timestamp'] is DateTime) {
      converted['timestamp'] =
          (converted['timestamp'] as DateTime).toIso8601String();
    }
    if (converted.containsKey('cards')) {
      for (var card in converted['cards']) {
        if (card.containsKey('timestamp') && card['timestamp'] is DateTime) {
          card['timestamp'] = (card['timestamp'] as DateTime).toIso8601String();
        }
      }
    }
    return converted;
  }

  static Map<String, dynamic> convertStringsToTimestamps(
      Map<String, dynamic> data) {
    Map<String, dynamic> converted = Map<String, dynamic>.from(data);
    if (converted.containsKey('timestamp') &&
        converted['timestamp'] is String) {
      converted['timestamp'] = DateTime.parse(converted['timestamp']);
    }
    if (converted.containsKey('cards')) {
      for (var card in converted['cards']) {
        if (card.containsKey('timestamp') && card['timestamp'] is String) {
          card['timestamp'] = DateTime.parse(card['timestamp']);
        }
      }
    }
    return converted;
  }

  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    if (data.containsKey('timestamp')) {
      data['timestamp'] = DateTime.parse(data['timestamp']);
    }
    if (data.containsKey('cards')) {
      for (var card in data['cards']) {
        if (card.containsKey('timestamp')) {
          card['timestamp'] = DateTime.parse(card['timestamp']);
        }
      }
    }
    return data;
  }

  void showSnack(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
