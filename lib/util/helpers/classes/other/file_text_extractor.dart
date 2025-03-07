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
    ImageSource? source = await extractor.showImageSourceModal(context);
    if (source == null) return null; // User canceled

    XFile? imageFile = await picker.pickImage(source: source);
    return imageFile != null ? File(imageFile.path) : null;
  }

  Future<ImageSource?> showImageSourceModal(BuildContext context) async {
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent, // Fix transparency issue
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return  Container(
          width: MediaQuery.sizeOf(context).width,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              // Ensure background is not fully transparent
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  "Select Image Source",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 15),
                _buildOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  text: "Open Camera",
                  color: colorScheme.primary,
                  source: ImageSource.camera,
                ),
                const SizedBox(height: 12),
                _buildOption(
                  context,
                  icon: Icons.image_rounded,
                  text: "Open Gallery",
                  color: colorScheme.secondary,
                  source: ImageSource.gallery,
                ),
                const SizedBox(height: 10),
              ],
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
        foregroundColor: Colors.white,
        // Ensure text is visible on any background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      onPressed: () => Navigator.pop(context, source),
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(
          text, style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }
}