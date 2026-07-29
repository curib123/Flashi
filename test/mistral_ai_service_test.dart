import 'package:flashi/features/ai/data/services/mistral_ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses AI-generated questions with three fake choices', () async {
    const response = '''
Question: What is the capital of France?
Answer: Paris
Fake Choice 1: London
Fake Choice 2: Berlin
Fake Choice 3: Madrid

Question: Which planet is known as the Red Planet?
Answer: Mars
Fake Choice 1: Venus
Fake Choice 2: Jupiter
Fake Choice 3: Mercury
''';

    final questions = await MistralAiService.parseTextQuestions(response);

    expect(questions, hasLength(2));
    expect(questions.first, {
      'question': 'What is the capital of France?',
      'answer': 'Paris',
      'fake_choice_1': 'London',
      'fake_choice_2': 'Berlin',
      'fake_choice_3': 'Madrid',
    });
    expect(questions.last['fake_choice_3'], 'Mercury');
  });
}
