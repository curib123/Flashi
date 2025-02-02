import 'package:flutter/cupertino.dart';

class PdfProvider with ChangeNotifier {
  List<Map<String, dynamic>> _pdfs = [];

  List<Map<String, dynamic>> get pdfs => _pdfs;

  String _searchQuery = '';

  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  void addPdf(Map<String, dynamic> pdf) {
    _pdfs.add(pdf);
    notifyListeners();
  }

  // Method to filter note list by title
  List<Map<String, dynamic>> filterPdfByTitle() {
    return _pdfs
        .where((note) => note['title'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Method to handle search query change
  void onSearchChanged(String value) {
    _searchQuery = value;
    notifyListeners();
  }
  // Method to delete a PDF by its title
  void deletePdf(String title) {
    _pdfs.removeWhere((pdf) => pdf['title'] == title);
    notifyListeners();
  }

  // Toggle favorite status of a note by title
  void toggleFavoriteByTitle(String title) {
    final index = _pdfs.indexWhere((note) => note['title'] == title);
    if (index != -1) {
      _pdfs[index]['favorite'] = !_pdfs[index]['favorite']; // Save to Hive after toggling favorite status
      notifyListeners();
    }
  }
  // Method to edit a PDF's details by its title
  void editPdf(String title, Map<String, dynamic> updatedPdf) {
    for (int i = 0; i < _pdfs.length; i++) {
      if (_pdfs[i]['title'] == title) {
        _pdfs[i] = updatedPdf; // Update the PDF
        break;
      }
    }
    notifyListeners();
  }

  // Method to search PDFs by title
  List<Map<String, dynamic>> searchPdfByTitle(String title) {
    return _pdfs.where((pdf) => pdf['title'].toLowerCase().contains(title.toLowerCase())).toList();
  }
}
