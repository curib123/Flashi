import 'package:flashi/core/config/app_env.dart';
import 'package:flashi/data/services/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthUser {
  final String id;
  final String? email;
  final String name;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString(),
      name: json['name']?.toString() ?? 'Flashi learner',
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  late final GoogleSignIn _googleSignIn;

  AuthUser? _user;
  bool _busy = false;
  String? _error;

  AuthProvider(this._api) {
    _googleSignIn = GoogleSignIn(
      serverClientId: AppEnv.googleWebClientId.isEmpty
          ? null
          : AppEnv.googleWebClientId,
    );
  }

  AuthUser? get user => _user;
  bool get signedIn => _user != null && _api.hasSession;
  bool get busy => _busy;
  String? get error => _error;
  bool get configured => AppEnv.googleWebClientId.isNotEmpty;

  Future<void> restore() async {
    if (!_api.hasSession) return;
    try {
      final response = await _api.get('/api/v1/me', authenticated: true);
      final raw = response['user'];
      if (raw is Map) {
        _user = AuthUser.fromJson(Map<String, dynamic>.from(raw));
        notifyListeners();
      }
    } catch (_) {
      await _api.clearSession();
    }
  }

  Future<bool> signInWithGoogle() async {
    if (!configured) {
      _error = 'Google sign-in is not configured for this build.';
      notifyListeners();
      return false;
    }

    _busy = true;
    _error = null;
    notifyListeners();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google did not return an ID token.');
      }

      final response = await _api.post(
        '/api/v1/auth/google',
        authenticated: false,
        body: {
          'idToken': idToken,
          if (googleAuth.accessToken != null)
            'accessToken': googleAuth.accessToken,
        },
      );
      await _api.saveSession(
        Map<String, dynamic>.from(response['session'] as Map),
      );
      _user = AuthUser.fromJson(
        Map<String, dynamic>.from(response['user'] as Map),
      );
      return true;
    } catch (error) {
      _error = 'Google sign-in failed. Check your OAuth configuration.';
      debugPrint('Google sign-in failed: $error');
      await _api.clearSession();
      _user = null;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      if (_api.hasSession) {
        await _api.post('/api/v1/auth/logout');
      }
    } catch (_) {
      // Local sign-out still completes when the network is unavailable.
    }
    await _api.clearSession();
    await _googleSignIn.signOut();
    _user = null;
    notifyListeners();
  }
}
