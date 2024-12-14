import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ReviewerSettingsProvider with ChangeNotifier {
  final Box _settingsBox = Hive.box('settings');

  // Default values
  FlipDirection _flashCardFlippingDirection = FlipDirection.HORIZONTAL;
  int _timeDuration = 10;

  // Getters for values
  FlipDirection get flashCardFlippingDirection => _flashCardFlippingDirection;
  int get timeDuration => _timeDuration;

  // Constructor to load settings from Hive
  ReviewerSettingsProvider() {
    _loadSettings();
  }

  // Load settings from Hive
  void _loadSettings() {
    // Load flashCardFlippingDirection from Hive (0: HORIZONTAL, 1: VERTICAL)
    int savedDirection = _settingsBox.get('flashCardFlippingDirection', defaultValue: 0);
    _flashCardFlippingDirection = FlipDirection.values[savedDirection];

    // Load timeDuration from Hive
    _timeDuration = _settingsBox.get('timeDuration', defaultValue: 10);

    notifyListeners();
  }

  // Update flash card flipping direction and save to Hive
  void updateflashCardFlippingDirection(FlipDirection newDirection) {
    _flashCardFlippingDirection = newDirection;
    // Save the integer value of the enum to Hive
    _settingsBox.put('flashCardFlippingDirection', newDirection.index);
    notifyListeners();
  }

  // Update time duration and save to Hive
  void updateTimeDuration(int newTimeDuration) {
    _timeDuration = newTimeDuration;
    _settingsBox.put('timeDuration', newTimeDuration);
    notifyListeners();
  }
}
