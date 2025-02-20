import 'package:flutter/material.dart';
import 'package:flashi/util/helpers/classes/api/ai/core/chatbot_api.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatBotProvider extends ChangeNotifier {
  // Box for storing chat messages
  final Box _chatBox = Hive.box('chatMessages');

  final List<Map<String, String>> _messages = [
    {'text': 'Hello! How can I assist you today?', 'sender': 'bot'}
  ];
  bool _isTyping = false;

  List<Map<String, String>> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  ChatBotProvider() {
    load(); // Load messages on initialization
  }

  void setTyping(bool value) {
    _isTyping = value;
    notifyListeners();
  }

  void save() {
    _chatBox.put('messages', _messages.map((msg) => Map<String, String>.from(msg)).toList());
  }

  void load() {
    final savedMessages = _chatBox.get('messages', defaultValue: []) as List<dynamic>;

    if (savedMessages.isNotEmpty) {
      _messages.clear();
      _messages.addAll(savedMessages.map((msg) => Map<String, String>.from(msg)));
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return; // Prevent sending empty messages

    _messages.add({'text': text, 'sender': 'user'});

    // Check if messages exceed 20 and remove the oldest 5
    if (_messages.length >= 20) {
      _messages.removeRange(0, 5);
    }

    notifyListeners();
    save(); // Save chat after adding user message

    print("User Message: $text");

    try {
      String aiResponse = await ChatbotApi.sendMessage(_messages);
      print("Bot Response: $aiResponse");

      _messages.add({'text': aiResponse, 'sender': 'bot'});

      // Again, check if messages exceed 20 after adding bot response
      if (_messages.length >= 20) {
        _messages.removeRange(0, 5);
      }

      save(); // Save chat after adding bot response
    } catch (e) {
      print("Error: $e");
      _messages.add({'text': 'Sorry, something went wrong. Please try again.', 'sender': 'bot'});

      if (_messages.length >= 20) {
        _messages.removeRange(0, 5);
      }

      save();
    }

    notifyListeners();
  }
}
