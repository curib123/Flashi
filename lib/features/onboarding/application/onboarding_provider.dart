import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnboardingProvider extends ChangeNotifier {
  final Box<dynamic> _onboardingBox = Hive.box('onboarding');

  bool _isFirstTime;

  OnboardingProvider()
      : _isFirstTime = Hive.box('onboarding')
            .get('isFirstTime', defaultValue: true) as bool;

  bool get isFirstTime => _isFirstTime;

  Future<void> completeOnboarding() async {
    if (!_isFirstTime) return;
    await _onboardingBox.put('isFirstTime', false);
    _isFirstTime = false;
    notifyListeners();
  }
}
