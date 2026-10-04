import 'dart:convert';
import 'dart:io';

import 'package:flashi/core/config/app_env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  static const _accessTokenKey = 'flashi_access_token';
  static const _refreshTokenKey = 'flashi_refresh_token';
  static const _expiresAtKey = 'flashi_expires_at';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  String? _accessToken;
  String? _refreshToken;
  int? _expiresAt;

  ApiClient({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  bool get hasSession =>
      (_accessToken?.isNotEmpty ?? false) && (_refreshToken?.isNotEmpty ?? false);

  Uri _uri(String path) {
    final base = AppEnv.apiBaseUrl.endsWith('/')
        ? AppEnv.apiBaseUrl.substring(0, AppEnv.apiBaseUrl.length - 1)
        : AppEnv.apiBaseUrl;
    return Uri.parse(base + path);
  }

  Future<void> restoreSession() async {
    _accessToken = await _storage.read(key: _accessTokenKey);
    _refreshToken = await _storage.read(key: _refreshTokenKey);
    _expiresAt = int.tryParse(await _storage.read(key: _expiresAtKey) ?? '');
  }

  Future<void> saveSession(Map<String, dynamic> session) async {
    _accessToken = session['accessToken']?.toString();
    _refreshToken = session['refreshToken']?.toString();
    _expiresAt = (session['expiresAt'] as num?)?.toInt();

    if (_accessToken == null || _refreshToken == null) {
      throw const ApiException(
        statusCode: 500,
        code: 'invalid_session',
        message: 'The server returned an invalid session.',
      );
    }

    await _storage.write(key: _accessTokenKey, value: _accessToken);
    await _storage.write(key: _refreshTokenKey, value: _refreshToken);
    await _storage.write(key: _expiresAtKey, value: _expiresAt?.toString() ?? '');
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _expiresAtKey),
    ]);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool authenticated = false,
  }) {
    return _send('GET', path, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    Map<String, String>? headers,
  }) {
    return _send(
      'POST',
      path,
      authenticated: authenticated,
      body: body,
      extraHeaders: headers,
    );
  }

  Future<void> putSignedFile({
    required String signedUrl,
    required File file,
    required String contentType,
  }) async {
    final response = await _client.put(
      Uri.parse(signedUrl),
      headers: {'content-type': contentType},
      body: await file.readAsBytes(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        code: 'upload_failed',
        message: 'The study source could not be uploaded.',
      );
    }
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    required bool authenticated,
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) async {
    if (authenticated) {
      await _refreshIfNeeded();
      if (_accessToken == null || _accessToken!.isEmpty) {
        throw const ApiException(
          statusCode: 401,
          code: 'unauthorized',
          message: 'Sign in with Google to use AI generation.',
        );
      }
    }

    final headers = <String, String>{
      'accept': 'application/json',
      'content-type': 'application/json',
      ...?extraHeaders,
    };
    if (authenticated) headers['authorization'] = 'Bearer $_accessToken';

    final response = method == 'GET'
        ? await _client.get(_uri(path), headers: headers)
        : await _client.post(
            _uri(path),
            headers: headers,
            body: jsonEncode(body ?? const <String, dynamic>{}),
          );

    final payload = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = (payload['error'] ?? 'request_failed').toString();
      if (response.statusCode == 401 && authenticated) {
        await clearSession();
      }
      throw ApiException(
        statusCode: response.statusCode,
        code: code,
        message: (payload['message'] as String?) ?? _messageFor(code),
      );
    }
    return payload;
  }

  Future<void> _refreshIfNeeded() async {
    if (_accessToken == null || _refreshToken == null) return;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (_expiresAt != null && _expiresAt! > now + 60) return;

    final response = await _client.post(
      _uri('/api/v1/auth/refresh'),
      headers: const {
        'accept': 'application/json',
        'content-type': 'application/json',
      },
      body: jsonEncode({'refreshToken': _refreshToken}),
    );
    final payload = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await clearSession();
      throw const ApiException(
        statusCode: 401,
        code: 'session_expired',
        message: 'Your session expired. Sign in again.',
      );
    }
    await saveSession(Map<String, dynamic>.from(payload['session'] as Map));
  }

  Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    return decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};
  }

  String _messageFor(String code) {
    switch (code) {
      case 'insufficient_credits':
        return 'Not enough energy. Please try again after credits are available.';
      case 'unauthorized':
        return 'Sign in with Google to continue.';
      case 'unsupported_file_type':
        return 'That file type is not supported.';
      case 'generation_processing':
        return 'This generation is still processing.';
      case 'unreadable_or_incomplete_source':
        return 'Flashi could not read enough usable study material from that source.';
      default:
        return 'Flashi could not complete the request. Please try again.';
    }
  }

  void dispose() => _client.close();
}
