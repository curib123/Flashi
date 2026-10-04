import 'dart:convert';
import 'dart:typed_data';

import 'package:flashi/core/config/app_env.dart';
import 'package:flashi/data/session_store.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  @override
  String toString() => message;
}

class ApiClient {
  final SessionStore session;
  final http.Client _client;
  bool _refreshing = false;

  ApiClient(this.session, {http.Client? client})
      : _client = client ?? http.Client();

  Uri _uri(String path) {
    final base = AppEnv.apiBaseUrl.endsWith('/')
        ? AppEnv.apiBaseUrl.substring(0, AppEnv.apiBaseUrl.length - 1)
        : AppEnv.apiBaseUrl;
    return Uri.parse('$base$path');
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool authenticated = false,
  }) =>
      _send('GET', path, authenticated: authenticated);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    Map<String, String> headers = const {},
  }) =>
      _send(
        'POST',
        path,
        authenticated: authenticated,
        body: body,
        extraHeaders: headers,
      );

  Future<void> putAbsolute(
    String url,
    Uint8List bytes, {
    required String contentType,
  }) async {
    final response = await _client.put(
      Uri.parse(url),
      headers: {'content-type': contentType},
      body: bytes,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException(
        statusCode: 502,
        code: 'upload_failed',
        message: 'The source file could not be uploaded.',
      );
    }
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    required bool authenticated,
    Map<String, dynamic>? body,
    Map<String, String> extraHeaders = const {},
    bool allowRefresh = true,
  }) async {
    if (authenticated && session.shouldRefresh) {
      await _refreshSession();
    }

    final headers = <String, String>{
      'accept': 'application/json',
      'content-type': 'application/json',
      ...extraHeaders,
    };

    if (authenticated) {
      if (!session.signedIn) {
        throw const ApiException(
          statusCode: 401,
          code: 'unauthorized',
          message: 'Sign in with Google to use online features.',
        );
      }
      headers['authorization'] = 'Bearer ${session.accessToken}';
    }

    final response = method == 'GET'
        ? await _client.get(_uri(path), headers: headers)
        : await _client.post(
            _uri(path),
            headers: headers,
            body: jsonEncode(body ?? const <String, dynamic>{}),
          );

    final payload = _decode(response.body);
    if (response.statusCode == 401 &&
        authenticated &&
        allowRefresh &&
        session.refreshToken.isNotEmpty) {
      await _refreshSession();
      return _send(
        method,
        path,
        authenticated: authenticated,
        body: body,
        extraHeaders: extraHeaders,
        allowRefresh: false,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = (payload['error'] ?? 'request_failed').toString();
      throw ApiException(
        statusCode: response.statusCode,
        code: code,
        message: _messageFor(code, payload['message']?.toString()),
      );
    }
    return payload;
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      final value = jsonDecode(body);
      return value is Map
          ? Map<String, dynamic>.from(value)
          : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> _refreshSession() async {
    if (_refreshing || session.refreshToken.isEmpty) return;
    _refreshing = true;
    try {
      final response = await _client.post(
        _uri('/api/v1/auth/refresh'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
        },
        body: jsonEncode({'refreshToken': session.refreshToken}),
      );
      final payload = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await session.clear();
        throw const ApiException(
          statusCode: 401,
          code: 'session_expired',
          message: 'Your session expired. Sign in again.',
        );
      }
      await _saveSessionPayload(payload);
    } finally {
      _refreshing = false;
    }
  }

  Future<void> saveSessionResponse(Map<String, dynamic> payload) =>
      _saveSessionPayload(payload);

  Future<void> _saveSessionPayload(Map<String, dynamic> payload) async {
    final raw = payload['session'];
    if (raw is! Map) {
      throw const ApiException(
        statusCode: 500,
        code: 'invalid_session',
        message: 'The server returned an invalid session.',
      );
    }
    final data = Map<String, dynamic>.from(raw);
    final access = data['accessToken']?.toString() ?? '';
    final refresh = data['refreshToken']?.toString() ?? '';
    if (access.isEmpty || refresh.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        code: 'invalid_session',
        message: 'The server returned an invalid session.',
      );
    }
    await session.save(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: (data['expiresAt'] as num?)?.toInt(),
    );
  }

  String _messageFor(String code, String? serverMessage) {
    switch (code) {
      case 'insufficient_credits':
        return 'Not enough AI credits for this generation.';
      case 'rate_limited':
        return 'Too many requests. Try again later.';
      case 'unauthorized':
      case 'session_expired':
        return 'Sign in with Google to continue.';
      case 'unsupported_file_type':
      case 'file_content_mismatch':
        return 'That file type or file content is not supported.';
      case 'source_expired':
        return 'That upload expired. Upload the file again.';
      case 'unreadable_or_incomplete_source':
        return 'The notes were unreadable or did not contain enough usable study content.';
      default:
        return serverMessage?.trim().isNotEmpty == true
            ? serverMessage!
            : 'Flashi could not complete the request. Please try again.';
    }
  }

  void dispose() => _client.close();
}
