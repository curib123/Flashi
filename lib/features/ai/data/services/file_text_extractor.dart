import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:image_picker/image_picker.dart';

class FileTextExtractor {
  /// Pick a file (PDF or DOCX) and extract text
  static Future<String> pickAndExtractText() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose a PDF or DOCX file',
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx'],
    );

    if (result == null) return "No file selected";

    try {
      final selectedFile = result.files.single;
      final extension = selectedFile.extension?.toLowerCase();
      final filePath = selectedFile.path;
      if (extension == 'pdf') {
        if (filePath == null) return 'The selected PDF could not be opened.';
        final file = File(filePath);
        PDFDoc pdfDoc = await PDFDoc.fromFile(file);
        return await pdfDoc.text;
      } else if (extension == 'docx') {
        final bytes = selectedFile.bytes ??
            (filePath == null ? null : await File(filePath).readAsBytes());
        if (bytes == null) return 'The selected DOCX could not be opened.';
        return docxToText(bytes);
      } else {
        return "Unsupported file format";
      }
    } catch (e) {
      return "Error reading file: ${e.toString()}";
    }
  }

  /// Pick or capture an image from camera or gallery
  static Future<File?> pickOrCaptureImage(BuildContext context) async {
    final extractor = FileTextExtractor();
    final ImagePicker picker = ImagePicker();
    ImageSource? source = await extractor.showImageSourceModal(context);
    if (source == null) return null;

    XFile? imageFile = await picker.pickImage(source: source);
    return imageFile != null ? File(imageFile.path) : null;
  }

  /// Modal bottom sheet to choose image source
  Future<ImageSource?> showImageSourceModal(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: MediaQuery.sizeOf(context).width,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
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

  /// Button builder for camera/gallery options
  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required ImageSource source,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      onPressed: () => Navigator.pop(context, source),
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
