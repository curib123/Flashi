import 'package:flashi/data/services/api_client.dart';
import 'package:flashi/data/services/startio_service.dart';
import 'package:flutter/foundation.dart';

class AiCreditProvider extends ChangeNotifier {
  final ApiClient _api;
  final StartIoService _ads;

  int _credits = 0;
  bool _loading = false;
  String? _error;

  AiCreditProvider(this._api, this._ads);

  int get credits => _credits;
  bool get loading => _loading;
  String? get error => _error;

  int get adsWatchedToday => 0;
  int get maxAdsPerDay => 10;
  int get adCooldown => 0;

  void setBalance(int value) {
    _credits = value < 0 ? 0 : value;
    notifyListeners();
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get(
        '/api/v1/credits',
        authenticated: true,
      );
      setBalance((response['credits'] as num?)?.toInt() ?? 0);
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> earnReward() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final session = await _api.post('/api/v1/credits/reward-session');
      final sessionId = session['sessionId']?.toString();
      if (sessionId == null || sessionId.isEmpty) {
        throw const ApiException(
          statusCode: 500,
          code: 'invalid_reward_session',
          message: 'Could not start the reward.',
        );
      }

      return await _ads.showRewarded(
        onReward: () async {
          final completed = await _api.post(
            '/api/v1/credits/reward-complete',
            body: {'sessionId': sessionId},
          );
          setBalance((completed['credits'] as num?)?.toInt() ?? _credits);
        },
      );
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  bool watchAd() => !_loading;
  void addAdsWatched() {}

  Future<void> addCredits(int amount) async => refresh();
  Future<void> useCredit(int amount) async => refresh();
}
