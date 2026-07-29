import 'dart:math';

abstract final class QuizChoiceBuilder {
  static const _fakeChoiceKeys = [
    'fake_choice_1',
    'fake_choice_2',
    'fake_choice_3',
  ];

  static List<String> build({
    required Map<dynamic, dynamic> card,
    required Iterable<dynamic> cards,
    Random? random,
  }) {
    final correctAnswer = _value(card['answer']);
    final distractors = <String>[];

    void addDistractor(Object? value) {
      final candidate = _value(value);
      if (candidate.isEmpty ||
          candidate.toLowerCase() == correctAnswer.toLowerCase() ||
          distractors.any(
            (answer) => answer.toLowerCase() == candidate.toLowerCase(),
          )) {
        return;
      }
      distractors.add(candidate);
    }

    for (final key in _fakeChoiceKeys) {
      addDistractor(card[key]);
    }

    for (final otherCard in cards) {
      if (otherCard is Map) {
        addDistractor(otherCard['answer']);
      }
    }

    var fallbackNumber = 1;
    while (distractors.length < 3) {
      addDistractor('No answer $fallbackNumber');
      fallbackNumber++;
    }

    return <String>[correctAnswer, ...distractors.take(3)]
      ..shuffle(random ?? Random());
  }

  static String _value(Object? value) => value?.toString().trim() ?? '';
}
