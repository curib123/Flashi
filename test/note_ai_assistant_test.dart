import 'package:flashi/features/notes/data/services/note_ai_assistant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('note assistant sends the selected task and note context', () async {
    late List<Map<String, String>> captured;
    final assistant = NoteAiAssistant(
      sender: (messages) async {
        captured = messages;
        return 'A clearer note';
      },
    );

    final result = await assistant.assist(
      action: NoteAiAction.polish,
      title: 'Biology',
      content: 'Cells are alive.',
    );

    expect(result, 'A clearer note');
    expect(captured, hasLength(1));
    expect(captured.single['sender'], 'user');
    expect(captured.single['text'], contains('preserving every fact'));
    expect(captured.single['text'], contains('Title: Biology'));
    expect(captured.single['text'], contains('Cells are alive.'));
  });

  test('note assistant rejects API error messages', () async {
    final assistant = NoteAiAssistant(
      sender: (_) async => 'Request failed. Please try again.',
    );

    expect(
      () => assistant.assist(
        action: NoteAiAction.summarize,
        title: 'Biology',
        content: 'Cells are alive.',
      ),
      throwsStateError,
    );
  });
}
