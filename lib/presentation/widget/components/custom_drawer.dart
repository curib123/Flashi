import 'package:flashi/presentation/screen/main/history_screen.dart';
import 'package:flashi/presentation/widget/components/see_all_quiz_set_list.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/chatbot_provider.dart';
import 'package:flashi/provider/notes_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashi/presentation/screen/main/favorate_screen.dart';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/provider/bottom_navigation_provider.dart';
import 'package:flashi/util/helpers/classes/other/wepage_launcher.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/about_alert_dialog.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(color: colorScheme.onSurface, fontSize: 16);

    Widget buildListTile({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
    }) {
      return ListTile(
        leading: Icon(icon, color: colorScheme.primary, size: 26),
        title: Text(title, style: textStyle),
        titleAlignment: ListTileTitleAlignment.center,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      );
    }

    return Consumer5<BottomNavigationProvider,QuizProvider,AiCreditProvider,NotesProvider,ChatBotProvider>(
      builder: (context, bottomNavProvider,quizProvider, aiCreditProvider,notesProvider,chatBotProvider ,child) {
        return Drawer(
          backgroundColor: colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          child: Column(
            children: [
              Container(
                width: MediaQuery.sizeOf(context).shortestSide,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(12),

                      child: Column(
                        children: [
                          Text("Flashi",
                              style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color:colorScheme.primary)),
                          const SizedBox(height: 5),
                          Text("Quiz Maker & Learner",
                              style:  TextStyle(fontSize: 16, color: colorScheme.primary.withOpacity(0.7))),
                        ],
                      ),
                    ),
                    // Optional: Add a divider for better separation
                    Divider(color: colorScheme.primary.withOpacity(0.2), thickness: 1, indent: 20, endIndent: 20),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [

                    buildListTile(
                      icon: Icons.layers_rounded,
                      title: 'Quiz Set',
                      onTap: () {
                        Navigator.pop(context);
                        quizProvider.searchController.text = quizProvider.searchQuery;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeeAllQuizSetList(
                              name: 'All Quiz Set',
                              colorScheme: colorScheme,
                            ),
                          ),
                        );
                      },
                    ),
                    buildListTile(
                      icon: Icons.favorite_rounded,
                      title: 'Favorites',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FavoriteScreen()));
                      },
                    ),
                    buildListTile(
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsScreen()));
                      },
                    ),
                    Divider(color: colorScheme.primary.withOpacity(0.2), thickness: 1, indent: 20, endIndent: 20),
                    buildListTile(
                      icon: Icons.smart_toy_rounded,
                      title: 'Chatbot',
                      onTap: () {
                        Navigator.pop(context);
                        bottomNavProvider.toogleNavigation(0);
                      },
                    ),
                    buildListTile(
                      icon: Icons.history_rounded,
                      title: 'Quiz Generated History',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoryScreen()));
                      },
                    ),

                    Divider(color: colorScheme.primary.withOpacity(0.2), thickness: 1, indent: 20, endIndent: 20),
                    buildListTile(
                      icon: Icons.contact_mail,
                      title: 'Contact Us',
                      onTap: () {
                        Navigator.pop(context);
                        WebPageLauncher('').launchEmail();
                      },
                    ),
                    buildListTile(
                      icon: Icons.info_rounded,
                      title: 'About Us',
                      onTap: () {
                        Navigator.pop(context);
                        showAnimatedAboutDialog(context);
                      },
                    ),
                    buildListTile(
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy Policy',
                      onTap: () {
                        Navigator.pop(context);
                        WebPageLauncher(
                            'https://curib123.github.io/flashi_/privacy_policy.html')
                            .launch();
                      },
                    ),
                    buildListTile(
                      icon: Icons.info_rounded,
                      title: 'Terms & Conditions',
                      onTap: () {
                        Navigator.pop(context);
                        WebPageLauncher(
                            'https://curib123.github.io/flashi_/terms%26condition.html')
                            .launch();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}