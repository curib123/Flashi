import 'dart:collection';

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
  int _pendingResponses = 0;

  List<Map<String, String>> get messages => UnmodifiableListView(
        _messages.map(UnmodifiableMapView.new),
      );
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
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return;

    _messages.add({'text': normalizedText, 'sender': 'user'});

    // Keep the chat limited to 20 messages, removing the oldest 5 if needed
    if (_messages.length > 20) {
      _messages.removeRange(0, 5);
    }

    _pendingResponses++;
    setTyping(true);
    save();

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
    } finally {
      _pendingResponses--;
      setTyping(_pendingResponses > 0);
    }
  }
}
