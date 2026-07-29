import 'dart:math';

import 'package:flashi/features/reviewer/domain/quiz_choice_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses stored AI distractors and excludes duplicate answers', () {
    final card = <String, dynamic>{
      'answer': 'Paris',
      'fake_choice_1': 'London',
      'fake_choice_2': 'Berlin',
      'fake_choice_3': 'Madrid',
    };

    final choices = QuizChoiceBuilder.build(
      card: card,
      cards: [
        card,
        {'answer': 'Rome'}
      ],
      random: Random(1),
    );

    expect(choices, hasLength(4));
    expect(choices, containsAll(['Paris', 'London', 'Berlin', 'Madrid']));
    expect(choices.toSet(), hasLength(4));
  });

  test('falls back to other card answers for legacy cards', () {
    final card = <String, dynamic>{'answer': 'Paris'};

    final choices = QuizChoiceBuilder.build(
      card: card,
      cards: [
        card,
        {'answer': 'London'},
        {'answer': 'Berlin'},
        {'answer': 'Madrid'},
      ],
      random: Random(1),
    );

    expect(choices, containsAll(['Paris', 'London', 'Berlin', 'Madrid']));
  });
}
