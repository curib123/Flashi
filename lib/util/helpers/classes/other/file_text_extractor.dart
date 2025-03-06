import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:image_picker/image_picker.dart';
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
    if (!hasPermission)
      return "Permission denied. Please allow access to continue.";

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
      return "Error reading file";
    }
  }

  static Future<File?> pickOrCaptureImage(BuildContext context) async {
    FileTextExtractor extractor = FileTextExtractor();
    bool hasPermission = await extractor.requestPermissions();
    if (!hasPermission) return null; // Return null if permission is denied

    final ImagePicker picker = ImagePicker();
    ImageSource? source = await extractor.showImageSourceDialog(context);
    if (source == null) return null; // User canceled

    XFile? imageFile = await picker.pickImage(source: source);
    return imageFile != null ? File(imageFile.path) : null;
  }


  Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return showGeneralDialog<ImageSource>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Image Source",
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: animation,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                Text("Select Image Source",
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  text: "Open Camera",
                  color: colorScheme.onSecondary,
                  source: ImageSource.camera,
                ),
                SizedBox(height: 10),
                _buildOption(
                  context,
                  icon: Icons.image_rounded,
                  text: "Open Gallery",
                  color: colorScheme.onSecondary,
                  source: ImageSource.gallery,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption(BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required ImageSource source,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      onPressed: () => Navigator.pop(context, source),
      icon: Icon(icon, size: 24),
      label: Text(text, style: TextStyle(fontSize: 16)),
    );
  }
}

