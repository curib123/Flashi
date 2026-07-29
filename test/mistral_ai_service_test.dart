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

  test('normalizes numbered output and removes invalid duplicates', () async {
    const response = '''
1. Question:  What   is ATP?
Answer: Adenosine triphosphate
Fake Choice 1: Adenosine diphosphate
Fake Choice 2: Adenosine triphosphate
Fake Choice 3: Adenosine diphosphate

2) Question: What is ATP?
Answer: Duplicate

- Question: Where is ATP produced?
Answer: Mitochondria
Fake Choice 1: Nucleus
''';

    final questions = await MistralAiService.parseTextQuestions(response);

    expect(questions, hasLength(2));
    expect(questions.first['question'], 'What is ATP?');
    expect(questions.first['fake_choice_1'], 'Adenosine diphosphate');
    expect(questions.first['fake_choice_2'], isEmpty);
    expect(questions.last['question'], 'Where is ATP produced?');
  });

  test('splits source text without cutting words when a boundary is nearby',
      () {
    const source =
        'Photosynthesis converts light into energy. Chlorophyll absorbs light. '
        'Plants release oxygen during this process.';

    final chunks = MistralAiService.splitTextIntoChunks(source, 55);

    expect(chunks.join(' '), source);
    expect(chunks, everyElement(isNot(isEmpty)));
    expect(chunks.first, endsWith('.'));
  });
}
