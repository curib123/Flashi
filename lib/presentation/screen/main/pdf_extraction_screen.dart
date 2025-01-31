import 'package:flashlearn/presentation/screen/main/settings_screen.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/util/helpers/pdf_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PdfExtractionScreen extends StatefulWidget {
  const PdfExtractionScreen({super.key});

  @override
  _PdfExtractionScreenState createState() => _PdfExtractionScreenState();
}

class _PdfExtractionScreenState extends State<PdfExtractionScreen> {
  String extractedText = '';
  final PdfService pdfService = PdfService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onPrimary,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: ReusableTitleContent(
          colorScheme: colorScheme,
          title: 'Extract PDF',
          onUpgradePro: () {},
          onSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          _buttonCreatePDF(colorScheme),
          SizedBox(height: 20),
          Center(
            child: Text('Extracted PDF Text',style: TextStyle(color: colorScheme.primary),),
          ),
          SizedBox(height: 20),
          _extractedPdfText(), // Display the extracted PDF text
        ],
      ),
    );
  }

  Widget _buttonCreatePDF(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Added vertical margin
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showChoiceDialog(colorScheme),
              icon: Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              label: Text(
                "Extract PDF Text",
                style: TextStyle(overflow: TextOverflow.ellipsis),
              ),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(colorScheme.onTertiary),
                backgroundColor: MaterialStateProperty.all(colorScheme.tertiary),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )),
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChoiceDialog(ColorScheme colorScheme) {
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
                title: Text('Entire Document', style: TextStyle(fontSize: 14, color: colorScheme.primary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndExtractPdfWholePage();
                },
              ),
              Divider(),
              ListTile(
                title: Text('Custom Page Range', style: TextStyle(fontSize: 14, color: colorScheme.primary)),
                onTap: () {
                  Navigator.pop(context);
                  _showPageRangeDialog(colorScheme);
                },
              ),
              Divider(),
              ListTile(
                title: Text('Custom Page', style: TextStyle(fontSize: 14, color: colorScheme.primary)),
                onTap: () {
                  Navigator.pop(context);
                  _showPageNumberDialog(colorScheme);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _extractedPdfText() {
    return Expanded( // Wrap in Expanded for proper scrolling behavior
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 40),
        child: SingleChildScrollView( // Use SingleChildScrollView to make it scrollable
          child: Text(
            extractedText,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndExtractPdfPageRange(int startPage, int endPage) async {
    String result = await pdfService.extractTextFromPageRange(startPage, endPage);
    if (mounted) { // Ensure setState is only called when the widget is still mounted
      setState(() {
        extractedText = result;
      });
    }
    print(extractedText);
  }

  Future<void> _pickAndExtractPdfWholePage() async {
    String result = await pdfService.extractTextFromWholeDocument();
    if (mounted) {
      setState(() {
        extractedText = result;
      });
    }
    print(extractedText);
  }

  Future<void> _pickAndExtractPdfSpecificPage(int pageNumber) async {
    String result = await pdfService.extractTextFromSpecificPage(pageNumber);
    if (mounted) {
      setState(() {
        extractedText = result;
      });
    }
    print(extractedText);
  }

  void _showPageNumberDialog(ColorScheme colorScheme) {
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
                    _pickAndExtractPdfSpecificPage(pageNumber);
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

  void _showPageRangeDialog(ColorScheme colorScheme) {
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
                    _pickAndExtractPdfPageRange(startPage, endPage);
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
