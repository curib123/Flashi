import 'package:flashi/app/app_shell.dart';
import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/shared/widgets/core/reusable_typing_animation_core.dart';
import 'package:flashi/features/chat/application/chat_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ScrollController _scrollController;
  final TextEditingController _messageController = TextEditingController();
  final AdManager _adManager = AdManager();

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent, // Change this
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _adManager.showInterstitialAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: MediaQuery.sizeOf(context).width < AppBreakpoints.medium
            ? const IconButton(
                tooltip: 'Open navigation',
                onPressed: AppShell.openNavigation,
                icon: Icon(Icons.menu),
              )
            : null,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assistant'),
            Text(
              'Ask, explore, and learn',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: ResponsiveContent(
        maxWidth: AppBreakpoints.readingMaxWidth,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _scrollToBottom(),
                  );
                  if (chatProvider.messages.isEmpty && !chatProvider.isTyping) {
                    return const _AssistantEmptyState();
                  }
                  final messages = chatProvider.messages.reversed.toList();
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    itemCount:
                        messages.length + (chatProvider.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == 0 && chatProvider.isTyping) {
                        return const _TypingBubble();
                      }
                      final message =
                          messages[index - (chatProvider.isTyping ? 1 : 0)];
                      return _MessageBubble(
                        text: _cleanMessage(message['text'] ?? ''),
                        isUser: message['sender'] == 'user',
                      );
                    },
                  );
                },
              ),
            ),
            _Composer(
              controller: _messageController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  String _cleanMessage(String value) =>
      value.replaceAll('*', '').replaceAll('#', '');

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _scrollToBottom();
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setTyping(true);
    chatProvider.sendMessage(message).then((_) {
      chatProvider.setTyping(false);
    });
    _messageController.clear();
  }
}

class _AssistantEmptyState extends StatelessWidget {
  const _AssistantEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'What would you like to learn?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ask a question and Flashi will help you work through it.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: AppRadii.large,
        ),
        child: const ReusableTypingAnimationCore(),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          isUser ? AppSpacing.md : AppSpacing.xxl,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              isUser ? colors.inverseSurface : colors.surfaceContainerHighest,
          borderRadius: AppRadii.large,
          border: isUser ? null : Border.all(color: colors.outlineVariant),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SelectableText(
              text,
              style: TextStyle(
                color: isUser ? colors.onInverseSurface : colors.onSurface,
                height: 1.45,
              ),
            ),
            if (!isUser)
              Positioned(
                top: -8,
                right: -40,
                child: IconButton(
                  tooltip: 'Copy response',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.content_copy_outlined, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: TextField(
          controller: controller,
          minLines: 1,
          maxLines: 5,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => onSend(),
          decoration: InputDecoration(
            hintText: 'Ask Flashi anything',
            suffixIcon: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxs),
              child: IconButton.filled(
                tooltip: 'Send message',
                onPressed: onSend,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
