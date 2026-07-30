import 'package:flashi/features/ai/data/services/chatbot_api.dart';

enum NoteAiAction {
  polish,
  summarize,
  title,
  custom,
}

typedef NoteAiSender = Future<String> Function(
  List<Map<String, String>> messages,
);

class NoteAiAssistant {
  NoteAiAssistant({NoteAiSender? sender})
      : _sender = sender ?? ChatbotApi.sendMessage;

  final NoteAiSender _sender;

  Future<String> assist({
    required NoteAiAction action,
    required String title,
    required String content,
    String instruction = '',
  }) async {
    final task = switch (action) {
      NoteAiAction.polish =>
        'Improve clarity, grammar, and structure while preserving every fact '
            'and the writer\'s meaning. Return only the revised note body.',
      NoteAiAction.summarize =>
        'Create a concise study summary. Return only the summary.',
      NoteAiAction.title =>
        'Suggest one clear title of at most 10 words. Return only the title.',
      NoteAiAction.custom =>
        'Follow this instruction: ${instruction.trim()}. Return only the '
            'requested result.',
    };
    final response = (await _sender([
      {
        'sender': 'user',
        'text': '''
You are a quiet writing assistant inside a notes app.
$task

Title: ${title.trim()}
Note:
${content.trim()}
''',
      },
    ]))
        .trim();

    if (response.isEmpty ||
        response.startsWith('API Key missing') ||
        response.startsWith('Request failed') ||
        response.startsWith('Request timed out') ||
        response.startsWith('Something went wrong') ||
        response.startsWith('No valid response')) {
      throw StateError(response.isEmpty
          ? 'The assistant returned an empty response.'
          : response);
    }
    return response;
  }
}
