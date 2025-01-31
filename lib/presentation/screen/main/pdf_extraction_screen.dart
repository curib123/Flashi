import 'package:flashlearn/presentation/screen/main/settings_screen.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/util/helpers/pdf_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PdfExtractionScreen extends StatelessWidget {
  const PdfExtractionScreen({super.key});

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
          title: 'Flashcard with PDF',
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
          PdfPickerButton(colorScheme: colorScheme),
          SizedBox(height: 10),
          _buildSetTile(quizProvider, context),
        ],
      ),
    );
  }
}

class PdfPickerButton extends StatefulWidget {
  final ColorScheme colorScheme;

  const PdfPickerButton({Key? key, required this.colorScheme}) : super(key: key);

  @override
  _PdfPickerButtonState createState() => _PdfPickerButtonState();
}

class _PdfPickerButtonState extends State<PdfPickerButton> {
  final PdfService pdfService = PdfService();
  String extractedText = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showChoiceDialog(widget.colorScheme),
              icon: Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              label: Text(
                "Create Flashcard From PDF",
                style: TextStyle(overflow: TextOverflow.ellipsis),
              ),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(widget.colorScheme.onTertiary),
                backgroundColor: MaterialStateProperty.all(widget.colorScheme.tertiary),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )),
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15)),
              ),
            ),
          ),
          SizedBox(height: 20),
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
                  int pageNumber = int.parse(pageController.text);
                  Navigator.pop(context);
                  _pickAndExtractPdfSpecificPage(pageNumber);
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
                  int startPage = int.parse(startPageController.text);
                  int endPage = int.parse(endPageController.text);
                  Navigator.pop(context);
                  _pickAndExtractPdfPageRange(startPage, endPage);
                }
              },
              child: Text('Extract', style: TextStyle(fontSize: 14, color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndExtractPdfPageRange(int startPage, int endPage) async {
    String result = await pdfService.extractTextFromPageRange(startPage, endPage);
    setState(() {
      extractedText = result;
    });
    print(extractedText);
  }

  Future<void> _pickAndExtractPdfWholePage() async {
    String result = await pdfService.extractTextFromWholeDocument();
    setState(() {
      extractedText = result;
    });
    print(extractedText);
  }

  Future<void> _pickAndExtractPdfSpecificPage(int pageNumber) async {
    String result = await pdfService.extractTextFromSpecificPage(pageNumber);
    setState(() {
      extractedText = result;
    });
    print(extractedText);
  }
}

Widget _buildSetTile(QuizProvider quizProvider, BuildContext context) {
  final size = MediaQuery.of(context).size;
  return Container(
    height: size.height * 0.6,
    child: ListView(
      children: [
        ReusableQuizSetList(quizSets: quizProvider.quizSets.reversed.toList())
      ],
    ),
  );
}
