import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  static const _accessKey = 'flashi_access_token';
  static const _refreshKey = 'flashi_refresh_token';
  static const _expiryKey = 'flashi_access_expiry';

  final FlutterSecureStorage _storage;
  String _accessToken = '';
  String _refreshToken = '';
  int? _expiresAt;

  SessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;
  bool get signedIn => _accessToken.isNotEmpty && _refreshToken.isNotEmpty;

  bool get shouldRefresh {
    if (_expiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return _expiresAt! <= now + 60;
  }

  Future<void> load() async {
    _accessToken = await _storage.read(key: _accessKey) ?? '';
    _refreshToken = await _storage.read(key: _refreshKey) ?? '';
    _expiresAt = int.tryParse(await _storage.read(key: _expiryKey) ?? '');
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required int? expiresAt,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _expiresAt = expiresAt;
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
      if (expiresAt != null)
        _storage.write(key: _expiryKey, value: expiresAt.toString())
      else
        _storage.delete(key: _expiryKey),
    ]);
  }

  Future<void> clear() async {
    _accessToken = '';
    _refreshToken = '';
    _expiresAt = null;
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _expiryKey),
    ]);
  }
}
