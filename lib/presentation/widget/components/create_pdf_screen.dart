import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/provider/pdf_provider.dart';
import 'package:flashlearn/util/helpers/snackbar/reusable_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreatePdfScreen extends StatefulWidget {
  final bool isRead;
  final String title;
  final DateTime date;

  const CreatePdfScreen({
    Key? key,
    required this.title,
    required this.isRead,
    required this.date,
  }) : super(key: key);

  @override
  State<CreatePdfScreen> createState() => _CreatePdfScreenState();
}

class _CreatePdfScreenState extends State<CreatePdfScreen> {
  late FlutterTts flutterTts;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    flutterTts = FlutterTts();

    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    // Set queue mode (useful for long text)
    await flutterTts.setQueueMode(1); // 1 = enqueue mode, 0 = interrupt mode

    // Set up listeners
    flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        isPlaying = false;
      });
      debugPrint("TTS Error: $msg");
    });
  }

  Future<void> toggleReading(String content) async {
    if (isPlaying) {
      await flutterTts.stop();
      setState(() {
        isPlaying = false; // Ensure UI updates
      });
      return;
    }

    setState(() {
      isPlaying = false; // Stop if unsupported language

    });


    // Filter the content to only include English words and numbers
    String filteredContent = filterContent(content);

    setState(() {
      isPlaying = true;
    });

    await flutterTts.speak(filteredContent); // Speak the filtered content
  }

// Example filter function to keep only English words and numbers
  String filterContent(String content) {
    // Keep only English letters (a-z, A-Z) and numbers (0-9)
    return content.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ''); // Remove anything that is not a letter, number, or space
  }


  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pdfProvider = Provider.of<PdfProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(colorScheme, context, widget.title, pdfProvider),
      body: Stack(
        children: [
          _buildBody(size, pdfProvider),
          _buildTitleInputField(pdfProvider),
          ReusableCreateSetButtonPosition(
            colorScheme: colorScheme,
            name: isPlaying ? 'Stop Reading' : 'Start Reading',
            onTap: () async {
              await toggleReading(pdfProvider.contentController.text);
            },
            icon: isPlaying ? Icons.stop : Icons.volume_up_rounded,
          ),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
        ],
      ),
    );
  }

  AppBar _buildAppBar(ColorScheme colorScheme, BuildContext context, String title, PdfProvider pdfProvider) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'View Pdf',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.onPrimary,
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.onPrimary),
            onPressed: () {
              pdfProvider.editPdf(title, {
                'title': pdfProvider.titleController.text,
                'content': pdfProvider.contentController.text,
                'created_at': DateTime.now(),
                'favorite': false,
              });

              showCustomSnackbar(context: context, message: 'Successfully Updated');
            },
          ),
        ],
      ),
      backgroundColor: colorScheme.primary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }

  Widget _buildBody(Size size, PdfProvider pdfProvider) {
    String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(widget.date);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      children: [
        SizedBox(height: 80),
        Text('Content', style: TextStyle(color: Colors.grey)),
        _buildContentInputField(size, pdfProvider),
        Center(child: Text(formattedDate))
      ],
    );
  }

  Widget _buildTitleInputField(PdfProvider pdfProvider) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: TextField(
        readOnly: !widget.isRead,
        controller: pdfProvider.titleController,
        decoration: InputDecoration(
          hintText: 'Title Here',
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildContentInputField(Size size, PdfProvider pdfProvider) {
    return Container(
      width: size.width,
      child: TextField(
        readOnly: !widget.isRead,
        controller: pdfProvider.contentController,
        maxLines: 21,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: 'Type your content here...',
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
