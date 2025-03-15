import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_typing_animation_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/chatbot_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {

  late final ScrollController _scrollController;
  TextEditingController messageController = TextEditingController();
  AdManager adManager = AdManager();

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
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose(); // Prevent memory leak
    adManager.showInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

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

          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: ReusableTitleContent(
          colorScheme: colorScheme,
          title: "Chatbot ",
          onUpgradePro: () {},
          onSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          isEnergyShow: false,
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
         Positioned(
           top: MediaQuery.of(context).size.height * 0.3,
           right: MediaQuery.of(context).size.width * 0.35,
             child:  Icon(Icons.smart_toy_rounded,size: 100,color: colorScheme.primary.withOpacity(0.3),),),
          Column(
            children: [
              Expanded(
                child: Consumer<ChatBotProvider>(
                  builder: (context, chatProvider, child) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    return ListView.builder(
                      controller: _scrollController, // Add this
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {

                        if (index == 0 && chatProvider.isTyping) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const ReusableTypingAnimationCore(),
                            ),
                          );
                        }
                        var message = chatProvider.messages.reversed.toList()[index - (chatProvider.isTyping ? 1 : 0)];
                        bool isUser = message['sender'] == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isUser ? [
                                      colorScheme.primaryContainer.withOpacity(0.9),
                                      colorScheme.secondaryContainer.withOpacity(0.2),
                                    ] :
                                    [
                                      colorScheme.primaryContainer.withOpacity(0.3),
                                      colorScheme.secondaryContainer.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                                  ),

                                ),

                                child: Padding(
                                  padding: const EdgeInsets.only(right: 30), // Space for the copy icon
                                  child: SelectableText(
                                    message['text']!.replaceAll('*', '').replaceAll('#', ''), // Removes * and #
                                    style: TextStyle(
                                      color: isUser ? colorScheme.onPrimaryContainer : colorScheme.onSecondaryContainer,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              if (!isUser)
                                Positioned(
                                  top: 15,
                                  right: 15,
                                  child: GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(text: message['text']!.replaceAll('*', '').replaceAll('#', '')),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: colorScheme.primary,
                                          content: Text(
                                            'Copied to clipboard',
                                            style: TextStyle(color: colorScheme.onPrimary),
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                            ],
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
                            hintText: "Ask Questions ...",
                            hintStyle: TextStyle(color: colorScheme.primary),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: TextStyle(color: colorScheme.primary,fontWeight: FontWeight.w500),
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
                        icon: Icon(Icons.send, color: colorScheme.onPrimary,size: 30,),
                        onPressed: () {
                          _scrollToBottom(); // Scroll after sending
                          if (messageController.text.trim().isNotEmpty) {
                            // Scroll to the bottom after a short delay
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

