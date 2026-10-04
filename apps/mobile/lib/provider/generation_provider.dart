import 'dart:io';

import 'package:flashi/data/services/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class GenerationProvider extends ChangeNotifier {
  final ApiClient _api;
  final Uuid _uuid = const Uuid();

  bool _busy = false;
  String? _error;

  GenerationProvider(this._api);

  bool get busy => _busy;
  String? get error => _error;

  Future<Map<String, dynamic>> generateTopic({
    required String topic,
    required String description,
    required String quizType,
    required int count,
  }) {
    final notes = 'Topic: ${topic.trim()}\nStudy scope: ${description.trim()}';
    return _run({
      'sourceType': 'text',
      'text': notes,
      'title': topic.trim(),
      'kind': 'quiz',
      'difficulty': 'medium',
      'questionTypes': [quizType],
      'topics': [topic.trim()],
      'count': count,
    });
  }

  Future<Map<String, dynamic>> generateFromFile({
    required File file,
    required String quizType,
    required int count,
    required bool image,
  }) async {
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
      final uploadId = upload['uploadId']?.toString();
      final signedUrl = upload['signedUrl']?.toString();
      if (uploadId == null ||
          uploadId.isEmpty ||
          signedUrl == null ||
          signedUrl.isEmpty) {
        throw const ApiException(
          statusCode: 500,
          code: 'invalid_upload_authorization',
          message: 'The server could not authorize this upload.',
        );
      }

      await _api.putSignedFile(
        signedUrl: signedUrl,
        file: file,
        contentType: mimeType,
      );

      return await _generate({
        'sourceType': image ? 'image' : 'file',
        'uploadId': uploadId,
        'title': filename,
        'kind': 'quiz',
        'difficulty': 'medium',
        'questionTypes': [quizType],
        'topics': const <String>[],
        'count': count,
      });
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
      return await _generate(body);
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _generate(Map<String, dynamic> body) {
    return _api.post(
      '/api/v1/generate',
      body: body,
      headers: {'idempotency-key': _uuid.v4()},
    );
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
        return 'image/jpeg';
      default:
        throw const ApiException(
          statusCode: 400,
          code: 'unsupported_file_type',
          message: 'That file type is not supported.',
        );
    }
  }
}
