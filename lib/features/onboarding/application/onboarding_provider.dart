import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({Box<dynamic>? box})
      : _box = box ?? Hive.box<dynamic>('onboarding') {
    _isFirstTime = _box.get('isFirstTime', defaultValue: true) as bool;
  }

  final Box<dynamic> _box;
  late bool _isFirstTime;

  bool get isFirstTime => _isFirstTime;

  Future<void> completeOnboarding() async {
    if (!_isFirstTime) return;
    await _box.put('isFirstTime', false);
    _isFirstTime = false;
    notifyListeners();
  }
}
