import 'dart:io';

import 'package:flashi/data/services/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GenerationProvider extends ChangeNotifier {
  final ApiClient _api;
  final SupabaseClient? _supabase;

  bool _busy = false;
  String? _error;

  GenerationProvider(this._api, this._supabase);

  bool get busy => _busy;
  String? get error => _error;

  Future<Map<String, dynamic>> generateTopic({
    required String topic,
    required String description,
    required String quizType,
    required int count,
  }) {
    return _run({
      'sourceType': 'topic',
      'title': topic,
      'description': description,
      'quizType': quizType,
      'count': count,
    });
  }

  Future<Map<String, dynamic>> generateFromFile({
    required File file,
    required String quizType,
    required int count,
    required bool image,
  }) async {
    if (_supabase == null) {
      throw const ApiException(
        statusCode: 503,
        code: 'supabase_not_configured',
        message: 'Supabase is not configured yet.',
      );
    }

    _busy = true;
    _error = null;
    notifyListeners();

    try {
      final filename = file.uri.pathSegments.last;
      final mimeType = _mimeType(filename);
      final size = await file.length();

      final upload = await _api.post(
        '/api/v1/uploads/create',
        body: {
          'filename': filename,
          'mimeType': mimeType,
          'size': size,
        },
      );

      final bucket = upload['bucket'].toString();
      final path = upload['path'].toString();
      final token = upload['token'].toString();

      await _supabase.storage.from(bucket).uploadToSignedUrl(
            path,
            token,
            file,
            FileOptions(contentType: mimeType, cacheControl: '0'),
          );

      return await _api.post(
        '/api/v1/generate',
        body: {
          'sourceType': image ? 'image' : 'file',
          'storagePath': path,
          'filename': filename,
          'mimeType': mimeType,
          'quizType': quizType,
          'count': count,
        },
      );
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _run(Map<String, dynamic> body) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      return await _api.post('/api/v1/generate', body: body);
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  String _mimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'rtf':
        return 'application/rtf';
      case 'odt':
        return 'application/vnd.oasis.opendocument.text';
      case 'md':
        return 'text/markdown';
      case 'txt':
        return 'text/plain';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
