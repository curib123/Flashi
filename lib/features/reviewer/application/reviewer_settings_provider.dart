import 'package:flip_card/flip_card.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ReviewerSettingsProvider extends ChangeNotifier {
  ReviewerSettingsProvider({Box<dynamic>? box})
      : _box = box ?? Hive.box<dynamic>('reviewer_settings') {
    final directionIndex =
        _box.get('flashCardFlippingDirection', defaultValue: 1);
    _flipDirection = directionIndex is int &&
            directionIndex >= 0 &&
            directionIndex < FlipDirection.values.length
        ? FlipDirection.values[directionIndex]
        : FlipDirection.VERTICAL;
    _timeDuration = _box.get('timeDuration', defaultValue: 10) as int;
  }

  final Box<dynamic> _box;
  late FlipDirection _flipDirection;
  late int _timeDuration;

  FlipDirection get flashCardFlippingDirection => _flipDirection;
  int get timeDuration => _timeDuration;

  void updateFlashCardFlippingDirection(FlipDirection direction) {
    if (_flipDirection == direction) return;
    _flipDirection = direction;
    _box.put('flashCardFlippingDirection', direction.index);
    notifyListeners();
  }

  void updateTimeDuration(int duration) {
    if (duration <= 0 || _timeDuration == duration) return;
    _timeDuration = duration;
    _box.put('timeDuration', duration);
    notifyListeners();
  }
}
