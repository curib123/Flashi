import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AiCreditProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  int _credits = 0;
  int _defaultCredits = 10;
  int _maxAdsPerDay = 10; // Maximum ads a user can watch per day
  int _adsWatchedToday = 0;

  DateTime? _lastUpdated;

  int get credits => _credits;
  int get adsWatchedToday => _adsWatchedToday;
  int get maxAdsPerDay => _maxAdsPerDay;

  AiCreditProvider() {
    _loadCredits();
  }

  /// Load credits and ad watch count securely
  Future<void> _loadCredits() async {
    _credits = await _getSecureInt('credits') ?? 10;
    _adsWatchedToday = await _getSecureInt('ads_watched') ?? 0;

    String? lastUpdatedStr = await _secureStorage.read(key: 'last_updated');
    if (lastUpdatedStr != null) {
      _lastUpdated = DateTime.tryParse(lastUpdatedStr);
    } else {
      _lastUpdated = await _getNetworkTime();
      await _saveCredits();
    }

    await _checkForDailyReset();
  }

  /// Get real-time NTP time (prevents local time cheats)
  Future<DateTime> _getNetworkTime() async {
    try {
      return await NTP.now();
    } catch (e) {
      throw Exception("No internet connection!");
    }
  }

  /// Reset daily credits and ad watch count
  Future<void> _checkForDailyReset() async {
    if (!await _hasInternet()) return;

    final now = await _getNetworkTime();
    if (_lastUpdated == null || now.difference(_lastUpdated!).inDays > 0) {
      if (_credits <= _defaultCredits) {
        _credits = _defaultCredits;
      }
      _adsWatchedToday = 0; // Reset daily ad watch count
      _lastUpdated = now;
      await _saveCredits();
    }

    notifyListeners();
  }

  /// Save credits and ad watch count securely
  Future<void> _saveCredits() async {
    await _secureStorage.write(key: 'credits', value: _credits.toString());
    await _secureStorage.write(key: 'ads_watched', value: _adsWatchedToday.toString());
    await _secureStorage.write(key: 'last_updated', value: _lastUpdated!.toIso8601String());
  }

  /// Retrieve integer from secure storage
  Future<int?> _getSecureInt(String key) async {
    String? value = await _secureStorage.read(key: key);
    return value != null ? int.tryParse(value) : null;
  }

  /// Check if user is online
  Future<bool> _hasInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Use credits
  void useCredit(int amount) {
    if (_credits >= amount) {
      _credits -= amount;
      _saveCredits();
      notifyListeners();
    }
  }

  /// Add credits
  void addCredits(int amount) {
    _credits += amount;
    _saveCredits();
    notifyListeners();
  }

  /// Watch ad to earn credits (with daily limit)
  bool watchAd() {
    if (_adsWatchedToday >= _maxAdsPerDay) {
      return false; // Ads limit reached
    }
    return true;
  }

  void AddAdsWatched() {
    _adsWatchedToday++;
    notifyListeners();
  }
}
