import 'dart:convert';

import 'package:flashi/core/config/app_env.dart';
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
  final String Function()? _accessTokenProvider;
  final http.Client _client;

  ApiClient({
    String Function()? accessTokenProvider,
    http.Client? client,
  })  : _accessTokenProvider = accessTokenProvider,
        _client = client ?? http.Client();

  Uri _uri(String path) {
    final base = AppEnv.apiBaseUrl.endsWith('/')
        ? AppEnv.apiBaseUrl.substring(0, AppEnv.apiBaseUrl.length - 1)
        : AppEnv.apiBaseUrl;
    return Uri.parse(base + path);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool authenticated = false,
  }) async {
    return _send('GET', path, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    return _send(
      'POST',
      path,
      authenticated: authenticated,
      body: body,
    );
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    required bool authenticated,
    Map<String, dynamic>? body,
  }) async {
    final headers = <String, String>{
      'accept': 'application/json',
      'content-type': 'application/json',
    };

    if (authenticated) {
      final token = _accessTokenProvider?.call();
      if (token == null || token.isEmpty) {
        throw const ApiException(
          statusCode: 401,
          code: 'unauthorized',
          message: 'Sign in with Google to use AI generation.',
        );
      }
      headers['authorization'] = 'Bearer ' + token;
    }

    final response = method == 'GET'
        ? await _client.get(_uri(path), headers: headers)
        : await _client.post(
            _uri(path),
            headers: headers,
            body: jsonEncode(body ?? const <String, dynamic>{}),
          );

    Map<String, dynamic> payload = const {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) payload = decoded;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = (payload['error'] ?? 'request_failed').toString();
      throw ApiException(
        statusCode: response.statusCode,
        code: code,
        message: _messageFor(code),
      );
    }

    return payload;
  }

  String _messageFor(String code) {
    switch (code) {
      case 'insufficient_credits':
        return 'Not enough energy. Earn more energy and try again.';
      case 'reward_unavailable':
        return 'Reward limit or cooldown reached. Try again later.';
      case 'unauthorized':
        return 'Sign in with Google to continue.';
      case 'unsupported_file_type':
        return 'That file type is not supported.';
      default:
        return 'Flashi could not complete the request. Please try again.';
    }
  }

  void dispose() => _client.close();
}
