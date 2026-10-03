import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/components/custom_drawer.dart';
import 'package:flashi/provider/chatbot_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _send(ChatBotProvider provider, [String? preset]) async {
    final text = (preset ?? _messageController.text).trim();
    if (text.isEmpty || provider.isTyping) return;

    _messageController.clear();
    provider.setTyping(true);
    _scrollToBottom();

    try {
      await provider.sendMessage(text);
    } finally {
      provider.setTyping(false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _clean(String text) => text.replaceAll('*', '').replaceAll('#', '');

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Flashi AI'),
            Text(
              'Study assistant',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ChatBotProvider>(
        builder: (context, provider, child) {
          final messages = provider.messages;

          return Column(
            children: [
              if (messages.length <= 1)
                _PromptPanel(onPrompt: (value) => _send(provider, value)),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    FlashiDesign.pagePadding,
                    12,
                    FlashiDesign.pagePadding,
                    20,
                  ),
                  itemCount: messages.length + (provider.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && provider.isTyping) {
                      return const _TypingBubble();
                    }

                    final message = messages[index];
                    final isUser = message['sender'] == 'user';
                    final text = _clean(message['text'] ?? '');

                    return _MessageBubble(
                      text: text,
                      isUser: isUser,
                      onCopy: isUser
                          ? null
                          : () {
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                ),
                              );
                            },
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      top: BorderSide(color: colors.outline.withOpacity(0.12)),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            hintText: 'Ask about what you are studying...',
                            prefixIcon: Icon(Icons.auto_awesome_outlined),
                          ),
                          onSubmitted: (_) => _send(provider),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: FilledButton(
                          onPressed:
                              provider.isTyping ? null : () => _send(provider),
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Icon(Icons.arrow_upward_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PromptPanel extends StatelessWidget {
  final ValueChanged<String> onPrompt;

  const _PromptPanel({required this.onPrompt});

  @override
  Widget build(BuildContext context) {
    const prompts = [
      'Explain this topic simply',
      'Quiz me with 5 questions',
      'Make a study plan',
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        FlashiDesign.pagePadding,
        8,
        FlashiDesign.pagePadding,
        4,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FlashiDesign.primaryFaintOf(context),
        borderRadius: BorderRadius.circular(FlashiDesign.radius),
        border: Border.all(color: FlashiDesign.primarySoftOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded),
              SizedBox(width: 8),
              Text(
                'Study faster with Flashi',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prompts
                .map(
                  (prompt) => ActionChip(
                    label: Text(prompt),
                    onPressed: () => onPrompt(prompt),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final VoidCallback? onCopy;

  const _MessageBubble({
    required this.text,
    required this.isUser,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: isUser ? colors.primary : colors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 18),
          ),
          border: isUser
              ? null
              : Border.all(color: colors.outline.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: SelectableText(
                text,
                style: TextStyle(
                  height: 1.45,
                  color: isUser ? colors.onPrimary : colors.onSurface,
                ),
              ),
            ),
            if (onCopy != null) ...[
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Copy',
                visualDensity: VisualDensity.compact,
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 17),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outline.withOpacity(0.12)),
        ),
        child: Text(
          'Flashi is thinking…',
          style: TextStyle(color: colors.onSurface.withOpacity(0.65)),
        ),
      ),
    );
  }
}
