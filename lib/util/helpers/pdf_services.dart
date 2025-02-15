import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flashi/provider/pdf_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfService {
  String extractedText = ""; // To hold the extracted text

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

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (await Permission.storage.isGranted && await Permission.manageExternalStorage.isGranted) {
      FilePickerResult? result;

      if( androidInfo.version.sdkInt < 30){
        result = await FilePicker.platform.pickFiles(type: FileType.any);
        if (result != null) {
          File file = File(result.files.single.path!);
          PDFDoc doc = await PDFDoc.fromFile(file);

          // Extracting all text from the document
          String allText = await doc.text;  // Using doc.text to extract all text at once

          return allText;
        }
      }else{
        result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
        if (result != null) {
          File file = File(result.files.single.path!);
          PDFDoc doc = await PDFDoc.fromFile(file);

          // Extracting all text from the document
          String allText = await doc.text;  // Using doc.text to extract all text at once

          return allText;
        }
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

  // Show the dialog to choose extraction type
  void showChoiceDialog(ColorScheme colorScheme, BuildContext context,PdfProvider pdfProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Select Extraction Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Custom Page Range', style: TextStyle(fontSize: 14, color: colorScheme.primary)),
                onTap: () {
                  Navigator.pop(context);
                  showPageRangeDialog(colorScheme, context,pdfProvider);
                },
              ),
              Divider(),
              ListTile(
                title: Text('Custom Page', style: TextStyle(fontSize: 14, color: colorScheme.primary)),
                onTap: () {
                  Navigator.pop(context);
                  showPageNumberDialog(colorScheme, context,pdfProvider);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  // Pick and extract text from a specific page
  Future<void> pickAndExtractPdfSpecificPage(int pageNumber, BuildContext context,PdfProvider pdfProvider) async {
    String result = await extractTextFromSpecificPage(pageNumber);
    pdfProvider.addPdf({
      'title': pdfProvider.pdfs.length.toString(),
      'content': result,
      'created_at': DateTime.now(),
      'favorite': false,
    });
    print(result);

  }

  // Pick and extract text from a page range
  Future<void> pickAndExtractPdfPageRange(int startPage, int endPage, BuildContext context,PdfProvider pdfProvider) async {
    String result = await extractTextFromPageRange(startPage, endPage);
    pdfProvider.addPdf({
      'title':pdfProvider.pdfs.length.toString(),
      'content': result,
      'created_at': DateTime.now(),
      'favorite': false,
    });
    print(result);

  }



  // Show the dialog for entering a specific page number
  void showPageNumberDialog(ColorScheme colorScheme, BuildContext context,PdfProvider pdfProvider) {
    TextEditingController pageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Enter the Page Number',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: pageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter page number (e.g., 3)',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
              ),
            ),
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (pageController.text.isNotEmpty) {
                  int pageNumber = int.tryParse(pageController.text) ?? 0; // Safely parse
                  if (pageNumber > 0) {
                    Navigator.pop(context);
                    pickAndExtractPdfSpecificPage(pageNumber, context,pdfProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid page number! Please enter a valid number.')),
                    );
                  }
                }
              },
              child: Text('Extract', style: TextStyle(fontSize: 14, color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Show the dialog for entering a page range
  void showPageRangeDialog(ColorScheme colorScheme, BuildContext context,PdfProvider pdfProvider) {
    TextEditingController startPageController = TextEditingController();
    TextEditingController endPageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Enter Page Range',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startPageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Start page (e.g., 1)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: endPageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'End page (e.g., 3)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (startPageController.text.isNotEmpty && endPageController.text.isNotEmpty) {
                  int startPage = int.tryParse(startPageController.text) ?? 0;
                  int endPage = int.tryParse(endPageController.text) ?? 0;
                  if (startPage > 0 && endPage >= startPage) {
                    Navigator.pop(context);
                    pickAndExtractPdfPageRange(startPage, endPage, context,pdfProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid page range! Please enter valid pages.')),
                    );
                  }
                }
              },
              child: Text('Extract', style: TextStyle(fontSize: 14, color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
