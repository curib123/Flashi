import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class FileTextExtractor {
  /// Request necessary permissions for file access
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

  /// Picks a file and extracts text from PDF or DOCX
  static Future<String> pickAndExtractText() async {
    FileTextExtractor extractor = FileTextExtractor();

    bool hasPermission = await extractor.requestPermissions();
    if (!hasPermission) return "Permission denied. Please allow access to continue.";

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result == null) return "No file selected";

    try {
      String? filePath = result.files.single.path;
      if (filePath == null) return "Invalid file";

      File file = File(filePath);

      if (filePath.endsWith(".pdf")) {
        PDFDoc pdfDoc = await PDFDoc.fromFile(file);
        return await pdfDoc.text;
      } else if (filePath.endsWith(".docx")) {
        final bytes = await file.readAsBytes();
        return docxToText(bytes);
      } else {
        return "Unsupported file format";
      }
    } catch (e) {
      return "Error reading file: $e";
    }
  }
}
