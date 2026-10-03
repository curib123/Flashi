import 'package:flashi/data/services/api_client.dart';
import 'package:flashi/data/services/startio_service.dart';
import 'package:flutter/foundation.dart';

class AppConfigProvider extends ChangeNotifier {
  final ApiClient _api;
  final StartIoService _ads;

  bool _loading = false;
  String? _error;
  Map<String, dynamic> _config = const {};

  AppConfigProvider(this._api, this._ads);

  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic> get config => _config;

  Map<String, dynamic> get ads =>
      Map<String, dynamic>.from(_config['ads'] as Map? ?? const {});

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _config = await _api.get('/api/v1/config');
      final adConfig = ads;
      await _ads.configure(testMode: adConfig['testMode'] != false);
    } catch (error) {
      _error = 'Server config unavailable. Manual study mode still works.';
      debugPrint('Config load failed: ' + error.toString());
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
