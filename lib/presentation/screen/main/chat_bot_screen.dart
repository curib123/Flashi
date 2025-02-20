import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/chatbot_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Icon(
            Icons.notes_rounded,
            size: 30,
            color: colorScheme.onPrimary,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: ReusableTitleContent(
          colorScheme: colorScheme,
          title: "My Chatbot ",
          onUpgradePro: () {},
          onSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Consumer<ChatBotProvider>(
                  builder: (context, chatProvider, child) {
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == 0 && chatProvider.isTyping) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const DotWavingAnimation(),
                            ),
                          );
                        }
                        var message = chatProvider.messages.reversed.toList()[index - (chatProvider.isTyping ? 1 : 0)];
                        bool isUser = message['sender'] == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isUser ? colorScheme.primaryContainer : colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message['text']!,
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: colorScheme.primary.withOpacity(0.1),
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: colorScheme.primary),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: TextStyle(color: colorScheme.primary,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: colorScheme.onPrimary),
                        onPressed: () {
                          if (messageController.text.trim().isNotEmpty) {
                            var chatProvider = Provider.of<ChatBotProvider>(context, listen: false);
                            chatProvider.setTyping(true);
                            chatProvider.sendMessage(messageController.text).then((_) {
                              chatProvider.setTyping(false);
                            });
                            messageController.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
        ],
      ),
      backgroundColor: colorScheme.background,
    );
  }
}

// Dot Waving Animation Widget
class DotWavingAnimation extends StatefulWidget {
  const DotWavingAnimation({super.key});

  @override
  _DotWavingAnimationState createState() => _DotWavingAnimationState();
}

class _DotWavingAnimationState extends State<DotWavingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 4 * (1 - (_controller.value + (index * 0.2)) % 1)),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
