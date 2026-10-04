import 'package:flashi/core/config/app_env.dart';
import 'package:flashi/data/services/api_client.dart';
import 'package:flashi/data/session_store.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final ApiClient api;
  final SessionStore session;
  late final GoogleSignIn _google;

  AuthService(this.api, this.session) {
    _google = GoogleSignIn(
      serverClientId:
          AppEnv.googleWebClientId.isEmpty ? null : AppEnv.googleWebClientId,
    );
  }

  bool get signedIn => session.signedIn;

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    final user = await _google.signIn();
    if (user == null) return null;
    final auth = await user.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const ApiException(
        statusCode: 400,
        code: 'google_token_missing',
        message: 'Google did not return an ID token.',
      );
    }
    final response = await api.post(
      '/api/v1/auth/google',
      authenticated: false,
      body: {
        'idToken': idToken,
        if (auth.accessToken != null) 'accessToken': auth.accessToken,
      },
    );
    await api.saveSessionResponse(response);
    final raw = response['user'];
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  Future<void> signOut() async {
    try {
      if (session.signedIn) await api.post('/api/v1/auth/logout');
    } finally {
      await _google.signOut();
      await session.clear();
    }
  }
}
