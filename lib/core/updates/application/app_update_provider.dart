import 'dart:convert';

import 'package:flashi/core/config/app_environment.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

typedef PackageInfoLoader = Future<PackageInfo> Function();

class AppUpdateProvider extends ChangeNotifier {
  AppUpdateProvider({
    http.Client? client,
    PackageInfoLoader? packageInfoLoader,
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _packageInfoLoader = packageInfoLoader ?? PackageInfo.fromPlatform;

  static final Uri _releaseInfoUri = Uri.parse(AppEnvironment.releaseConfigUrl);

  final http.Client _client;
  final bool _ownsClient;
  final PackageInfoLoader _packageInfoLoader;

  String _currentVersion = '';
  String _latestVersion = '';
  String _downloadLink = '';
  String _patchNote = '';
  bool _isChecking = false;
  Object? _lastError;

  String get currentVersion => _currentVersion;
  String get latestVersion => _latestVersion;
  String get downloadLink => _downloadLink;
  String get patchNote => _patchNote;
  bool get isChecking => _isChecking;
  Object? get lastError => _lastError;
  bool get updateAvailable =>
      _isNewerVersion(current: _currentVersion, latest: _latestVersion);

  Future<bool> checkAppVersion() async {
    if (_isChecking) return updateAvailable;
    _isChecking = true;
    _lastError = null;
    notifyListeners();

    try {
      final packageInfo = await _packageInfoLoader();
      _currentVersion = packageInfo.version;
      await fetchLatestVersion();
      return updateAvailable;
    } catch (error) {
      _lastError = error;
      _latestVersion = _currentVersion;
      return false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatestVersion() async {
    final response = await _client.get(_releaseInfoUri);
    if (response.statusCode != 200) {
      throw http.ClientException(
        'Unable to load release information (${response.statusCode})',
        _releaseInfoUri,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _latestVersion = data['latest_version']?.toString() ?? _currentVersion;
    _downloadLink = data['download_link']?.toString() ?? '';
    _patchNote = data['patch_note']?.toString() ?? '';
  }

  bool _isNewerVersion({
    required String current,
    required String latest,
  }) {
    final currentParts = _parseVersion(current);
    final latestParts = _parseVersion(latest);
    final length = currentParts.length > latestParts.length
        ? currentParts.length
        : latestParts.length;

    for (var index = 0; index < length; index++) {
      final currentPart = index < currentParts.length ? currentParts[index] : 0;
      final latestPart = index < latestParts.length ? latestParts[index] : 0;
      if (latestPart != currentPart) return latestPart > currentPart;
    }
    return false;
  }

  List<int> _parseVersion(String value) => value
      .split('.')
      .map((part) => int.tryParse(part.split('-').first) ?? 0)
      .toList(growable: false);

  @override
  void dispose() {
    if (_ownsClient) _client.close();
    super.dispose();
  }
}
