import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PdfProvider with ChangeNotifier {
  List<Map<String, dynamic>> _pdfs = [];

  List<Map<String, dynamic>> get pdfs => _pdfs;

  final Box _pdfBox = Hive.box('pdf');  // Open the box to store PDF data

  String _searchQuery = '';

  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  PdfProvider() {
    loadPdfsFromHive();  // Load PDFs when the provider is initialized
  }

  // Load PDFs from Hive storage
  void loadPdfsFromHive() {
    var pdfsFromStorage = _pdfBox.get('pdfs', defaultValue: []);

    if (pdfsFromStorage is List) {
      _pdfs = List<Map<String, dynamic>>.from(
        pdfsFromStorage.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else if (item is Map) {
            return Map<String, dynamic>.from(item);
          } else {
            return {};
          }
        }),
      );
    }
    notifyListeners();
  }

  // Save the current PDFs list to Hive storage
  void savePdfsToHive() {
    _pdfBox.put('pdfs', _pdfs);  // Save the entire list to Hive
  }

  void addPdf(Map<String, dynamic> pdf) {
    _pdfs.add(pdf);
    savePdfsToHive();  // Save to Hive after adding
    notifyListeners();
  }

  // Method to filter PDF list by title
  List<Map<String, dynamic>> filterPdfByTitle() {
    return _pdfs
        .where((pdf) => pdf['title'].toLowerCase().contains(_searchQuery.toLowerCase()))
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
    savePdfsToHive();  // Save to Hive after deleting
    notifyListeners();
  }

  // Toggle favorite status of a PDF by title
  void toggleFavoriteByTitle(String title) {
    final index = _pdfs.indexWhere((pdf) => pdf['title'] == title);
    if (index != -1) {
      _pdfs[index]['favorite'] = !_pdfs[index]['favorite']; // Toggle favorite status
      savePdfsToHive();  // Save to Hive after updating favorite status
      notifyListeners();
    }
  }

  // Method to edit a PDF's details by its title
  void editPdf(String title, Map<String, dynamic> updatedPdf) {
    for (int i = 0; i < _pdfs.length; i++) {
      if (_pdfs[i]['title'] == title) {
        _pdfs[i] = updatedPdf;  // Update the PDF
        break;
      }
    }
    savePdfsToHive();  // Save to Hive after editing
    notifyListeners();
  }

  // Method to search PDFs by title
  List<Map<String, dynamic>> searchPdfByTitle(String title) {
    return _pdfs.where((pdf) => pdf['title'].toLowerCase().contains(title.toLowerCase())).toList();
  }
}
