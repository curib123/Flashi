import 'package:flashi/data/services/api_client.dart';
import 'package:flutter/foundation.dart';

class AiCreditProvider extends ChangeNotifier {
  final ApiClient _api;

  int _credits = 0;
  bool _loading = false;
  String? _error;

  AiCreditProvider(this._api);

  int get credits => _credits;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get(
        '/api/v1/credits',
        authenticated: true,
      );
      _credits = ((response['balance'] ?? response['credits']) as num?)
              ?.toInt() ??
          0;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void applyGenerationBalance(Map<String, dynamic> response) {
    final value = response['credits'];
    if (value is num) {
      _credits = value.toInt().clamp(0, 1 << 31).toInt();
      notifyListeners();
    }
  }
}
