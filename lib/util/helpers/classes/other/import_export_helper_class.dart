import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flashi/provider/quiz_provider.dart';

class ImportExportHelperClass {
  final String directory = '/storage/emulated/0/Flashi';

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ (Scoped Storage) - No need for extra permissions
        return true;
      } else if (androidInfo.version.sdkInt >= 30) {
        // Android 11 & 12 (Needs Manage External Storage)
        PermissionStatus manageStorageStatus =
        await Permission.manageExternalStorage.request();
        return manageStorageStatus.isGranted;
      } else {
        // Android 10 and below
        PermissionStatus storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }
    }
    return true; // For iOS or other platforms, no special permissions needed
  }

  Future<void> exportList(BuildContext context, Map<String, dynamic> sets) async {
    try {
      await requestPermissions();
      final rootDirectory = Directory(directory);

      if (!rootDirectory.existsSync()) {
        await rootDirectory.create(recursive: true);
      }

      String fileName = '${sets['name'] ?? 'empty'}.json';
      final filePath = "${rootDirectory.path}/$fileName";
      final file = File(filePath);

      await file.writeAsString(jsonEncode(convertTimestampsToString(sets)));


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Save Successful: The list has been save to $filePath"),
          backgroundColor: Colors.green,
        ),
      );

      convertStringsToTimestamps(sets);


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Export Failed: Error during export: $e"),
          backgroundColor: Colors.red,
        ),
      );
      print("Error during export: $e");
    }
  }



  Future<void> importList(BuildContext context, QuizProvider quizProvider) async {

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    try {

      FilePickerResult? result;
     if( androidInfo.version.sdkInt < 30){
       result = await FilePicker.platform.pickFiles(
         type: FileType.any,
         initialDirectory: directory,
       );
     }else{
       result = await FilePicker.platform.pickFiles(
         type: FileType.custom,
         allowedExtensions: ['json'],
         initialDirectory: directory,
       );
     }


      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final contents = await file.readAsString();

        // Parse JSON and convert timestamps
        Map<String, dynamic> importedData = jsonDecode(contents);

        // Check if the map already exists in the quiz sets
        bool isDuplicate = quizProvider.quizSets.any((set) => set['name'] == importedData['name']);

        if (isDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Oops! This set already exists! Delete the existing set to continue."),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          // If not a duplicate, convert timestamps and add the set
          Map<String, dynamic> sets = _convertTimestamps(importedData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Import Successful: The list has been imported successfully."),
              backgroundColor: Colors.green,
            ),
          );

          quizProvider.addQuizSet(sets);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Import Canceled: No file selected or import was canceled."),
            backgroundColor: Colors.red,
          ),
        );
        print("File selection canceled or no file selected.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Import Failed: Error during import: $e"),
          backgroundColor: Colors.red,
        ),
      );
      print("Error during import: $e");
    }
  }

  static Map<String, dynamic> convertTimestampsToString(Map<String, dynamic> data) {
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

 static Map<String, dynamic> convertStringsToTimestamps(Map<String, dynamic> data) {
    Map<String, dynamic> convertedData = Map<String, dynamic>.from(data);

    // Convert top-level timestamp from String to DateTime
    if (convertedData.containsKey('timestamp') &&
        convertedData['timestamp'] is String) {
      convertedData['timestamp'] = DateTime.parse(convertedData['timestamp']);
    }

    // Convert timestamps inside cards from String to DateTime
    if (convertedData.containsKey('cards')) {
      List<dynamic> cards = convertedData['cards'];
      for (var card in cards) {
        if (card.containsKey('timestamp') && card['timestamp'] is String) {
          card['timestamp'] = DateTime.parse(card['timestamp']);
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



}

