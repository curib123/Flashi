import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';

class QuizImportExportService {
  final String directory = '/storage/emulated/0/Flashi';

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ (Scoped Storage) - No need for extra permissions
        return true;
      } else {
        // Android 12 and below
        PermissionStatus storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }
    }
    return true;
  }

  Future<void> exportList(
      BuildContext context, Map<String, dynamic> sets) async {
    try {
      bool permissionGranted = await requestPermissions();
      if (!context.mounted) return;
      if (!permissionGranted) {
        showSnack(context, "Permission Denied: Storage permission required.",
            Colors.red);
        return;
      }

      final rootDirectory = Directory(directory);
      if (!rootDirectory.existsSync()) {
        await rootDirectory.create(recursive: true);
      }

      String fileName = '${sets['name'] ?? 'empty'} (Flashi).json';
      final filePath = "${rootDirectory.path}/$fileName";
      final file = File(filePath);

      await file.writeAsString(jsonEncode(convertTimestampsToString(sets)));
      if (!context.mounted) return;

      showSnack(
          context,
          "Save Successful: The list has been saved to $filePath",
          Colors.green);
      convertStringsToTimestamps(sets); // restore original format if needed
    } catch (e) {
      showSnack(context, "Export Failed: $e", Colors.red);
      developer.log('Quiz export failed.', error: e);
    }
  }

  Future<void> importList(
      BuildContext context, QuizProvider quizProvider) async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (!context.mounted) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        initialDirectory: androidInfo.version.sdkInt < 30 ? directory : null,
      );
      if (!context.mounted) return;

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final contents = await file.readAsString();
        if (!context.mounted) return;
        Map<String, dynamic> importedData = jsonDecode(contents);

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
        showSnack(context, "Import Canceled: No file selected.", Colors.red);
      }
    } catch (e) {
      if (!context.mounted) return;
      showSnack(context, "Import Failed: $e", Colors.red);
      developer.log('Quiz import failed.', error: e);
    }
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
