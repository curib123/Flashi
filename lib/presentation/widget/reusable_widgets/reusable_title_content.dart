import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/chatbot_provider.dart';
import 'package:flashi/provider/notes_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_watch_ads_dialog.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class ReusableTitleContent extends StatefulWidget {
  final ColorScheme colorScheme;
  final String title;
  final VoidCallback onUpgradePro;
  final VoidCallback onSettings;
  final bool isEnergyShow ;

  const ReusableTitleContent({super.key, required this.colorScheme, required this.title, required this.onUpgradePro, required this.onSettings, required this.isEnergyShow});

  @override
  State<ReusableTitleContent> createState() => _ReusableTitleContentState();
}

class _ReusableTitleContentState extends State<ReusableTitleContent> {

  AdManager adManager = AdManager();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    adManager.loadRewardedAd(AdUnitId.rewardedAdUnitId);
  }
  @override
  Widget build(BuildContext context) {
    return Consumer5<QuizProvider, AiCreditProvider,AuthProvider,NotesProvider,ChatBotProvider>(
      builder: (context, quizProvider, aiCreditProvider,authProvider,notesProvider,chatBotProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: widget.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.title.length >= 10 ? 15 : 18,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // SizedBox(width: 20,),
            Row(
              children: [
                widget.isEnergyShow ? GestureDetector(
                  onTap: () async {
                   adManager.loadRewardedAd(AdUnitId.rewardedAdUnitId);
                    bool isConnected = await InternetConnection().hasInternetAccess;
                   showLoadingDialog(context, text: "Loading ads... Please wait.\nIf it doesn’t appear, try again.");
                 if(isConnected){
                   Navigator.of(context).pop();
                   showWatchAdDialog(
                       context: context,
                       title: "Earn Free energy!",
                       message: "Watch a short ad and instantly earn 5 free energy!",
                       cancelText: "Maybe Later",
                       confirmText: "Watch Ads",
                     onWatchAd: () {
                       showLoadingDialog(context, text: "Loading ads... Please wait.\nIf it doesn’t appear, try again.");
                       Future.delayed(const Duration(seconds: 10), () {
                         Navigator.of(context).pop();
                         adManager.showRewarded(context, 'energy');
                       });
                     },
                   );
                 }else{
                   Navigator.of(context).pop();
                   showAuthDialog(context, "Error", "Please connect to internet");
                 }
                  },
                  child: Container(
                    padding: EdgeInsets.only(left:10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: widget.colorScheme.onPrimary,
                    ),
                    child: Row(
                      children: [
                        Text(
                          aiCreditProvider.credits.toString(),
                          style: TextStyle(fontSize:  aiCreditProvider.credits.toString().length >= 5 ? 12 :  15, color: widget.colorScheme.primary,fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.offline_bolt_rounded, size: 20, color: widget.colorScheme.secondary),
                        SizedBox(width: 2),
                        Icon(Icons.add_circle_rounded,size: 30,color: widget.colorScheme.primary,)
                      ],
                    ),

                  ),
                ) : Text(""),
              SizedBox(width: 20,),
               authProvider.user_id.isEmpty ? GestureDetector(
                  onTap: widget.onSettings,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.settings_rounded,
                      size: 30,
                      color: widget.colorScheme.onPrimary,
                    ),
                  ),
                ) : GestureDetector(
                 onTap: () {
                  authProvider.user_id.isNotEmpty ?   showAuthDialog(context, type: "info", "Info", "You are logged in!")
                      : showAuthDialog(context, type: "warning", "Warning", "You are not logged in!");
                 },
                 child: CircleAvatar(
                   radius: 15,
                   backgroundColor: widget.colorScheme.onPrimary,
                   child: Icon(
                     Icons.person_rounded,
                     size: 25,
                     color: widget.colorScheme.primary,
                   ),
                 )
                 ),

              ],
            ),
          ],
        );
      },
    );
  }
}
