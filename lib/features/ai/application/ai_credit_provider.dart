import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntp/ntp.dart';

typedef DeviceIdLoader = Future<String?> Function();
typedef NetworkTimeLoader = Future<DateTime> Function();
typedef InternetChecker = Future<bool> Function();

class AiCreditProvider extends ChangeNotifier {
  AiCreditProvider({
    FlutterSecureStorage? secureStorage,
    DeviceIdLoader? deviceIdLoader,
    NetworkTimeLoader? networkTimeLoader,
    InternetChecker? internetChecker,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _deviceIdLoader = deviceIdLoader ?? _loadDeviceId,
        _networkTimeLoader = networkTimeLoader ?? _loadNetworkTime,
        _internetChecker = internetChecker ?? _checkInternet {
    ready = _initialize();
  }

  static const int _defaultCredits = 10;
  static const int _maxAdsPerDay = 10;
  static const int _maxCooldownSeconds = 60;

  final FlutterSecureStorage _secureStorage;
  final DeviceIdLoader _deviceIdLoader;
  final NetworkTimeLoader _networkTimeLoader;
  final InternetChecker _internetChecker;

  late final Future<void> ready;
  String? _deviceId;
  int _credits = 0;
  int _adsWatchedToday = 0;
  int _cooldownSeconds = 0;
  int _addedCredits = 0;
  DateTime? _lastUpdated;
  Timer? _countdownTimer;
  bool _isInitialized = false;
  bool _isDisposed = false;
  Object? _lastError;

  int get credits => _credits;
  int get addedCredits => _addedCredits;
  int get defaultCredits => _defaultCredits;
  int get adsWatchedToday => _adsWatchedToday;
  int get maxAdsPerDay => _maxAdsPerDay;
  int get cooldownSeconds => _cooldownSeconds;
  int get adCooldown => _cooldownSeconds;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isInitialized => _isInitialized;
  Object? get lastError => _lastError;

  Future<void> _initialize() async {
    try {
      _deviceId = await _deviceIdLoader();
      await loadCredits();
    } catch (error) {
      _lastError = error;
    } finally {
      _isInitialized = true;
      _notifyIfActive();
    }
  }

  Future<void> loadCredits() async {
    final deviceId = _deviceId;
    if (deviceId == null) return;

    _credits = await _getSecureInt('${deviceId}_credits') ?? _defaultCredits;
    _adsWatchedToday = await _getSecureInt('${deviceId}_ads_watched') ?? 0;
    final lastUpdatedValue =
        await _secureStorage.read(key: '${deviceId}_last_updated');
    _lastUpdated = lastUpdatedValue == null
        ? await getNetworkTime()
        : DateTime.tryParse(lastUpdatedValue);
  }

  Future<DateTime> getNetworkTime() async {
    try {
      return await _networkTimeLoader();
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<bool> hasInternet() => _internetChecker();

  Future<void> handleDataChange({DateTime? now}) async {
    _credits += _addedCredits;
    _adsWatchedToday = 0;
    if (now != null) _lastUpdated = now;
    await _saveCredits();
    _notifyIfActive();
  }

  void updateAddedCredits(int value) {
    if (value < 0 || _addedCredits == value) return;
    _addedCredits = value;
    _notifyIfActive();
  }

  Future<void> updateCredits(int value) async {
    if (value < 0 || _credits == value) return;
    _credits = value;
    await _saveCredits();
    _notifyIfActive();
  }

  Future<void> useCredit(int amount) async {
    if (amount <= 0 || _credits < amount) return;
    _credits -= amount;
    await _saveCredits();
    _notifyIfActive();
  }

  Future<void> addCredits(int amount) async {
    if (amount <= 0) return;
    _credits += amount;
    await _saveCredits();
    _notifyIfActive();
  }

  bool watchAd() => _adsWatchedToday < _maxAdsPerDay && _cooldownSeconds == 0;

  void addAdsWatched() {
    if (!watchAd()) return;
    _adsWatchedToday++;
    _cooldownSeconds = _maxCooldownSeconds;
    _startCooldownTimer();
    _notifyIfActive();
  }

  Future<void> _saveCredits() async {
    final deviceId = _deviceId;
    if (deviceId == null) return;
    await Future.wait([
      _secureStorage.write(
        key: '${deviceId}_credits',
        value: _credits.toString(),
      ),
      _secureStorage.write(
        key: '${deviceId}_ads_watched',
        value: _adsWatchedToday.toString(),
      ),
      if (_lastUpdated != null)
        _secureStorage.write(
          key: '${deviceId}_last_updated',
          value: _lastUpdated!.toIso8601String(),
        ),
    ]);
  }

  Future<int?> _getSecureInt(String key) async {
    final value = await _secureStorage.read(key: key);
    return value == null ? null : int.tryParse(value);
  }

  void _startCooldownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds == 0) {
        timer.cancel();
        return;
      }
      _cooldownSeconds--;
      _notifyIfActive();
    });
  }

  void _notifyIfActive() {
    if (!_isDisposed) notifyListeners();
  }

  static Future<String?> _loadDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) return (await deviceInfo.androidInfo).id;
    if (Platform.isIOS) {
      return (await deviceInfo.iosInfo).identifierForVendor;
    }
    return null;
  }

  static Future<DateTime> _loadNetworkTime() => NTP.now();

  static Future<bool> _checkInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return false;
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _countdownTimer?.cancel();
    super.dispose();
  }
}
