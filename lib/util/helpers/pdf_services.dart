import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfService {
  Future<void> requestPermissions() async {
    // Check and request storage permission
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
    // Check and request external storage management permission
    if (!await Permission.manageExternalStorage.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }
  Future<String> extractTextFromWholeDocument() async {
    await requestPermissions();

    if (await Permission.storage.isGranted && await Permission.manageExternalStorage.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        File file = File(result.files.single.path!);
        PDFDoc doc = await PDFDoc.fromFile(file);

        // Extracting all text from the document
        String allText = await doc.text;  // Using doc.text to extract all text at once

        return allText;
      }
    }
    return "Permissions not granted. Please allow storage permissions.";
  }

  Future<String> extractTextFromPageRange(int startPage, int endPage) async {
    await requestPermissions();

    if (await Permission.storage.isGranted && await Permission.manageExternalStorage.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        File file = File(result.files.single.path!);
        PDFDoc doc = await PDFDoc.fromFile(file);

        // Check if the page range is valid
        if (startPage > 0 && endPage <= doc.length && startPage <= endPage) {
          String allText = "";

          for (int i = startPage - 1; i < endPage; i++) { // pageAt is zero-based
            PDFPage page = doc.pageAt(i);
            String pageText = await page.text;
            allText += "Page ${i + 1}:\n$pageText\n\n"; // Formatting for each page
          }

          return allText;
        } else {
          return "Invalid page range. Please ensure the range is within the document's length.";
        }
      }
    }

    return "Permissions not granted. Please allow storage permissions.";
  }


  Future<String> extractTextFromSpecificPage(int pageNumber) async {
    await requestPermissions();

    if (await Permission.storage.isGranted && await Permission.manageExternalStorage.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        File file = File(result.files.single.path!);
        PDFDoc doc = await PDFDoc.fromFile(file);

        if (pageNumber > 0 && pageNumber <= doc.length) {
          PDFPage page = doc.pageAt(pageNumber - 1); // pageAt is zero-based
          return await page.text;
        }
      }
    }
    return "Page $pageNumber does not exist in the document.";
  }
}

