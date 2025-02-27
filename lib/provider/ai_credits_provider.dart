import 'package:flashi/util/helpers/widget/alert_dialog/show_free_credits_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class AiCreditProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  int _credits = 0;
  int _defaultCredits = 10;
  int _maxAdsPerDay = 10;
  int _adsWatchedToday = 0;
  int adCooldown = 0;
  int maxCooldown = 120;

  DateTime? _lastUpdated;
  Timer? _countdownTimer; // Added Timer reference

  int get credits => _credits;
  int get defaultCredits => _defaultCredits;
  int get adsWatchedToday => _adsWatchedToday;
  int get maxAdsPerDay => _maxAdsPerDay;
  DateTime? get lastUpdated => _lastUpdated;


  AiCreditProvider(){
    loadCredits();
  }

  /// Load credits and ad watch count securely
  Future<void> loadCredits() async {
    _credits = await _getSecureInt('credits') ?? 0;
    _adsWatchedToday = await _getSecureInt('ads_watched') ?? 0;
    String? lastUpdatedStr = await _secureStorage.read(key: 'last_updated');
    _lastUpdated = lastUpdatedStr != null ? DateTime.tryParse(lastUpdatedStr) : await getNetworkTime();
    notifyListeners();
  }

  /// Get real-time NTP time (prevents local time cheats)
  Future<DateTime> getNetworkTime() async {
    try {
      return await NTP.now();
    } catch (e) {
      return DateTime.now(); // Fallback to device time if no internet
    }
  }
  Future<void> handleDataChange({DateTime? now}) async{
    _credits += _defaultCredits;
    _adsWatchedToday = 0;
    _lastUpdated = now;
    _adsWatchedToday = 0;
    await _saveCredits();
    notifyListeners();
  }


  /// Save credits and ad watch count securely
  Future<void> _saveCredits() async {
    await _secureStorage.write(key: 'credits', value: _credits.toString());
    await _secureStorage.write(key: 'ads_watched', value: _adsWatchedToday.toString());
    if (_lastUpdated != null) {
      await _secureStorage.write(key: 'last_updated', value: _lastUpdated!.toIso8601String());
    }
  }

  /// Retrieve integer from secure storage
  Future<int?> _getSecureInt(String key) async {
    String? value = await _secureStorage.read(key: key);
    return value != null ? int.tryParse(value) : null;
  }

  /// Check if user is online
  Future<bool> hasInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Use credits
  Future<void> useCredit(int amount) async {
    if (_credits >= amount) {
      _credits -= amount;
      await _saveCredits();
      notifyListeners();
    }
  }

  /// Add credits
  Future<void> addCredits(int amount) async {
    _credits += amount;
    await _saveCredits();
    notifyListeners();
  }

  /// Watch ad to earn credits (with daily limit)
  bool watchAd() {
    if (_adsWatchedToday >= _maxAdsPerDay || adCooldown > 0) {
      return false;
    }
    return true;
  }

  /// Increment ads watched count and start cooldown timer
  void addAdsWatched() {
    _adsWatchedToday++;
    adCooldown = maxCooldown;
    _startCooldownTimer();
    notifyListeners();
  }

  /// Start ad cooldown timer
  void _startCooldownTimer() {
    _countdownTimer?.cancel(); // Cancel existing timer if any
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (adCooldown > 0) {
        adCooldown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }
}
