import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:async';

class AiCreditProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? _deviceId;
  int _credits = 0;
  int _defaultCredits = 10;
  int _maxAdsPerDay = 10;
  int _adsWatchedToday = 0;
  int adCooldown = 0;
  int maxCooldown = 120;
  int _addedCredits = 0;
  DateTime? _lastUpdated;
  Timer? _countdownTimer;

  int get credits => _credits;
  int get addedCredits => _addedCredits;
  int get defaultCredits => _defaultCredits;
  int get adsWatchedToday => _adsWatchedToday;
  int get maxAdsPerDay => _maxAdsPerDay;
  DateTime? get lastUpdated => _lastUpdated;

  AiCreditProvider() {
    _init();
  }

  Future<void> _init() async {
    await _getDeviceId();
    await loadCredits();
  }

  /// Get a unique device identifier
  Future<void> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id; // Unique Android ID
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor; // Unique iOS ID
    }
  }

  /// Load credits securely based on device ID
  Future<void> loadCredits() async {
    if (_deviceId == null) return;

    _credits = await _getSecureInt('${_deviceId}_credits') ?? _defaultCredits;
    _adsWatchedToday = await _getSecureInt('${_deviceId}_ads_watched') ?? 0;
    String? lastUpdatedStr = await _secureStorage.read(key: '${_deviceId}_last_updated');
    _lastUpdated = lastUpdatedStr != null ? DateTime.tryParse(lastUpdatedStr) : await getNetworkTime();

    notifyListeners();
  }

  /// Get real-time NTP time (prevents local time cheats)
  Future<DateTime> getNetworkTime() async {
    try {
      return await NTP.now();
    } catch (e) {
      return DateTime.now(); // Fallback to device time
    }
  }

  Future<void> handleDataChange({DateTime? now}) async {
    _credits += addedCredits;
    _adsWatchedToday = 0;
    if (now != null) _lastUpdated = now;

    await _saveCredits();
    notifyListeners();
  }

  void updateAddedCredits(int value) {
    _addedCredits = value;
    notifyListeners();
  }

  Future<void>  updateCredits(int value) async {
    _credits = value;
    _saveCredits();
    notifyListeners();
  }

  /// Save credits securely tied to the device ID
  Future<void> _saveCredits() async {
    if (_deviceId == null) return;
    await _secureStorage.write(key: '${_deviceId}_credits', value: _credits.toString());
    await _secureStorage.write(key: '${_deviceId}_ads_watched', value: _adsWatchedToday.toString());
    if (_lastUpdated != null) {
      await _secureStorage.write(key: '${_deviceId}_last_updated', value: _lastUpdated!.toIso8601String());
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
    if (connectivityResult == ConnectivityResult.none) return false;

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
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
    return _adsWatchedToday < _maxAdsPerDay && adCooldown <= 0;
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
    _countdownTimer?.cancel();
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
