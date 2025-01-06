import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnboardingProvider with ChangeNotifier {
  // Hive box for storing onboarding state
  final Box _onboardingBox = Hive.box('onboarding');

  // Variable to track if it's the first time
   bool first = true;

  OnboardingProvider() {
    // Initialize the `first` variable with the stored value or default
    first = _onboardingBox.get('isFirstTime', defaultValue: true);
  }

  bool get isFirstTime => first;

  void completeOnboarding() {
    // Update the stored value in the box and variable
    _onboardingBox.put('isFirstTime', false);
    first = false;
    notifyListeners();
  }
}
