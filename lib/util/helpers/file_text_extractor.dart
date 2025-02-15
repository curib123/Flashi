import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class FileTextExtractor {

  /// Requests necessary permissions before file selection
  static Future<bool> requestPermissions() async {
    if (!await Permission.storage.isGranted) {
      var status = await Permission.storage.request();
      if (status != PermissionStatus.granted) return false;
    }

    if (!await Permission.manageExternalStorage.isGranted) {
      var status = await Permission.manageExternalStorage.request();
      if (status != PermissionStatus.granted) return false;
    }

    return true;
  }

  /// Picks a file and extracts text from PDF or DOCX
  static Future<String> pickAndExtractText() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    bool hasPermission = await requestPermissions();
    if (!hasPermission) return "Permission denied. Please allow access to continue.";

    FilePickerResult? result;

    if( androidInfo.version.sdkInt >= 30){
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );
    }else{
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
    }


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
      return "Error extracting text: $e";
    }
  }
}
