import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';
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
    return showAppBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSheetHeader(
              title: 'Add an image',
              description: 'Take a new photo or choose one from your library.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  _buildOption(
                    context,
                    icon: Icons.camera_alt_outlined,
                    text: 'Use camera',
                    source: ImageSource.camera,
                    primary: true,
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    context,
                    icon: Icons.photo_library_outlined,
                    text: 'Choose from library',
                    source: ImageSource.gallery,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Button builder for camera/gallery options
  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String text,
    required ImageSource source,
    bool primary = false,
  }) {
    final button = primary ? FilledButton.icon : OutlinedButton.icon;
    return SizedBox(
      width: double.infinity,
      child: button(
        onPressed: () => Navigator.pop(context, source),
        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }
}
