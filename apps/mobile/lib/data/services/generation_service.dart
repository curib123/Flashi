import 'dart:io';
import 'package:flashi/data/services/api_client.dart';
import 'package:flashi/domain/study.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class GenerationService {
  final ApiClient api;
  const GenerationService(this.api);

  Future<StudySet> generateText({
    required String text,
    required String title,
    required SetKind kind,
    required int count,
    required String difficulty,
    required List<QuestionType> questionTypes,
    List<String> topics = const [],
  }) =>
      _generate({
        'sourceType': 'text',
        'text': text,
        'title': title,
        'kind': setKindWire(kind),
        'count': count,
        'difficulty': difficulty,
        'questionTypes': questionTypes.map(questionTypeWire).toList(),
        'topics': topics,
      });

  Future<StudySet> generateFile({
    required File file,
    required bool image,
    required String title,
    required SetKind kind,
    required int count,
    required String difficulty,
    required List<QuestionType> questionTypes,
    List<String> topics = const [],
  }) async {
    final filename = file.uri.pathSegments.last;
    final mimeType = _mimeType(filename);
    final size = await file.length();
    final upload = await api.post(
      '/api/v1/uploads/create',
      body: {'filename': filename, 'mimeType': mimeType, 'size': size},
    );
    final uploadId = upload['uploadId']?.toString() ?? '';
    final signedUrl = upload['signedUrl']?.toString() ?? '';
    if (uploadId.isEmpty || signedUrl.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        code: 'invalid_upload_ticket',
        message: 'The server could not prepare the upload.',
      );
    }
    await api.putAbsolute(
      signedUrl,
      await file.readAsBytes(),
      contentType: mimeType,
    );
    return _generate({
      'sourceType': image ? 'image' : 'file',
      'uploadId': uploadId,
      'title': title,
      'kind': setKindWire(kind),
      'count': count,
      'difficulty': difficulty,
      'questionTypes': questionTypes.map(questionTypeWire).toList(),
      'topics': topics,
    });
  }

  Future<StudySet> _generate(Map<String, dynamic> body) async {
    final response = await api.post(
      '/api/v1/generate',
      body: body,
      headers: {'idempotency-key': _uuid.v4()},
    );
    final raw = response['result'];
    if (raw is! Map) {
      throw const ApiException(
        statusCode: 500,
        code: 'invalid_generation',
        message: 'The generated study set was invalid.',
      );
    }
    return StudySet.fromJson(Map<String, dynamic>.from(raw));
  }

  String _mimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return switch (extension) {
      'pdf' => 'application/pdf',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'rtf' => 'application/rtf',
      'odt' => 'application/vnd.oasis.opendocument.text',
      'md' => 'text/markdown',
      'txt' => 'text/plain',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'jpeg' || 'jpg' => 'image/jpeg',
      _ => throw const ApiException(
          statusCode: 415,
          code: 'unsupported_file_type',
          message: 'That file type is not supported.',
        ),
    };
  }
}
