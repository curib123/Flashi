import 'dart:async';

import 'package:flashi/core/config/app_env.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient? _supabase;
  late final GoogleSignIn _googleSignIn;
  StreamSubscription<AuthState>? _authSubscription;

  User? _user;
  bool _busy = false;
  String? _error;

  AuthProvider(this._supabase) {
    _googleSignIn = GoogleSignIn(
      serverClientId: AppEnv.googleWebClientId.isEmpty
          ? null
          : AppEnv.googleWebClientId,
    );
    _user = _supabase?.auth.currentUser;
    _authSubscription = _supabase?.auth.onAuthStateChange.listen((event) {
      _user = event.session?.user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get signedIn => _user != null;
  bool get busy => _busy;
  String? get error => _error;
  bool get configured => _supabase != null;

  Future<bool> signInWithGoogle() async {
    if (_supabase == null) {
      _error = 'Supabase credentials are not configured yet.';
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
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        throw StateError('Google did not return the required tokens.');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      _user = response.user;
      return _user != null;
    } catch (error) {
      _error = 'Google sign-in failed. Check your OAuth configuration.';
      debugPrint('Google sign-in failed: ' + error.toString());
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabase?.auth.signOut();
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
