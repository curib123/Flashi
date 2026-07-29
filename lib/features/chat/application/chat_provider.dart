import 'package:flashi/util/helpers/classes/api/ai/core/chatbot_api.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatProvider extends ChangeNotifier {
  // Box for storing chat messages
  final Box _chatBox = Hive.box('chatMessages');

  // Default messages
  List<Map<String, String>> _messages = [
    {'text': 'Hello! How can I assist you today?', 'sender': 'bot'}
  ];

  bool _isTyping = false;

  List<Map<String, String>> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  ChatProvider() {
    load(); // Load messages on initialization
  }

  void setTyping(bool value) {
    if (_isTyping == value) return;
    _isTyping = value;
    notifyListeners();
  }

  void updateMessages(List<Map<String, String>> newMessages) {
    _messages = newMessages.map(Map<String, String>.from).toList();
    notifyListeners();
    save();
  }

  void save() {
    _chatBox.put('messages',
        _messages.map((msg) => Map<String, String>.from(msg)).toList());
  }

  void load() {
    final savedMessages = _chatBox.get('messages') as List<dynamic>? ?? [];

    if (savedMessages.isEmpty) {
      // Ensure the default message is stored
      _messages = [
        {'text': 'Hello! How can I assist you today?', 'sender': 'bot'}
      ];
      save();
    } else {
      _messages =
          savedMessages.map((msg) => Map<String, String>.from(msg)).toList();
    }

    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return; // Prevent sending empty messages

    _messages.add({'text': text, 'sender': 'user'});

    // Keep the chat limited to 20 messages, removing the oldest 5 if needed
    if (_messages.length > 20) {
      _messages.removeRange(0, 5);
    }

    notifyListeners();
    save(); // Save chat after adding user message

    try {
      final aiResponse = await ChatbotApi.sendMessage(_messages);

      _messages.add({'text': aiResponse, 'sender': 'bot'});

      if (_messages.length > 100) {
        _messages.removeRange(0, 20);
      }

      save(); // Save chat after adding bot response
    } catch (_) {
      _messages.add({
        'text': 'Sorry, something went wrong. Please try again.',
        'sender': 'bot'
      });

      if (_messages.length > 100) {
        _messages.removeRange(0, 20);
      }

      save();
    }
    notifyListeners();
  }
}
