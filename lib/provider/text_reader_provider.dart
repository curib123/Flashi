import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TextReaderProvider with ChangeNotifier {
  // Open the box for textReader
  final Box _textReader = Hive.box('textReader');

  // Define the text property
  String _text = '';

  final TextEditingController _textController = TextEditingController();

  // Get the stored text, with a default if it's empty
  String get text => _text.isEmpty ? "Paste or type your text here..." : _text;
  TextEditingController get textController => _textController;

  // Initialize Hive and load the text when the provider is created
  TextReaderProvider() {
    _loadText();
  }

  // Load the saved text from Hive
  void _loadText() {
    // Load text from Hive or default to an empty string if not found
    _text = _textReader.get('text', defaultValue:text) ?? '';
    _textController.text = _text;  // Update the controller with loaded text
    notifyListeners();  // Notify listeners after loading
  }

  // Save text to Hive
  void _saveText() {
    _textReader.put('text', _text);  // Save text to Hive
    notifyListeners();  // Notify listeners after saving
  }

  // Update the text and save it to Hive if not a PDF
  void updateText(String newText, bool isNotPdf) {
    _text = newText;
    _textController.text = newText; // Ensure the controller has the updated text

    // Save text only if it's not a PDF
    if (isNotPdf) {
      _saveText();
    }
    notifyListeners();  // Notify listeners after updating
  }
}
