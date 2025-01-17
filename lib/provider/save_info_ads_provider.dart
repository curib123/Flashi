import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SaveInfoAdsProvider with ChangeNotifier {
  late Box _box;
  String _lastAdDate = '';
  int _adsWatchedToday = 0;

  SaveInfoAdsProvider() {
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _box = Hive.box('timerBox');
    _lastAdDate = _box.get('lastAdDate', defaultValue: '');
    _adsWatchedToday = _box.get('adsWatchedToday', defaultValue: 0);

    // Reset ads watched if the date has changed
    String currentDate = DateTime.now().toIso8601String().substring(0, 10);
    if (_lastAdDate != currentDate) {
      _adsWatchedToday = 0;
      _saveAdWatchState();
    }

    notifyListeners();
  }

  int get adsWatchedToday => _adsWatchedToday;
  String get lastAdDate => _lastAdDate;

  Future<void> incrementAdsWatched() async {
    _adsWatchedToday++;
    await _saveAdWatchState();
    notifyListeners();
  }

  Future<void> _saveAdWatchState() async {
    String currentDate = DateTime.now().toIso8601String().substring(0, 10);
    await _box.put('adsWatchedToday', _adsWatchedToday);
    await _box.put('lastAdDate', currentDate);
  }
}
