import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/auth_provider.dart';
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

  const ReusableTitleContent({super.key, required this.colorScheme, required this.title, required this.onUpgradePro, required this.onSettings});

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
    return Consumer4<QuizProvider, AiCreditProvider,AuthProvider,NotesProvider>(
      builder: (context, quizProvider, aiCreditProvider,authProvider,notesProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: widget.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.title.length >= 12 ? 14 : 18,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // SizedBox(width: 20,),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                   adManager.loadRewardedAd(AdUnitId.rewardedAdUnitId);
                    bool isConnected = await InternetConnection().hasInternetAccess;
                   showLoadingDialog(context, text: "Loading ads... Please wait.\nIf it doesn’t appear, try again.");
                 if(isConnected){
                   Navigator.of(context).pop();
                   showWatchAdDialog(
                       context: context,
                       title: "Earn Free Credits!",
                       message: "Watch a short ad and instantly earn 5 free credits!",
                       cancelText: "Maybe Later",
                       confirmText: "Watch Ads",
                     onWatchAd: () {
                       showLoadingDialog(context, text: "Loading ads... Please wait.\nIf it doesn’t appear, try again.");
                       Future.delayed(const Duration(seconds: 10), () {
                         Navigator.of(context).pop();
                         adManager.showRewarded(context, 'credits');
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
                          style: TextStyle(fontSize: 15, color: widget.colorScheme.primary,fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.token_rounded, size: 20, color: widget.colorScheme.secondary),
                        SizedBox(width: 5),
                        Icon(Icons.add_circle_rounded,size: 30,color: widget.colorScheme.primary,)
                      ],
                    ),

                  ),
                ),
                IconButton(
                    onPressed: () async {
                      bool isConnected = await InternetConnection().hasInternetAccess;

                      if(isConnected ){

                        if(authProvider.user_id.isNotEmpty){
                          await authProvider.saveFlashcards(authProvider.user_id,quizProvider.quizSets);
                          await authProvider.saveUserCredits(authProvider.user_id, aiCreditProvider.credits);
                          await authProvider.saveNotes(authProvider.user_id, notesProvider.notes);

                          Future.delayed(Duration(seconds: 5),()  {
                            showAuthDialog(context, type: "success","Success", "Your data has been successfully saved!");


                          });
                        }else{
                          showAuthDialog(context,type: "warning", "Warning", "Please sign in to sync your data.");

                        }

                      }else{
                        showAuthDialog(context,type: "error", "Error", "No Internet Connection");
                      }

                     ;
                    },
                    icon: Icon(Icons.save,color: widget.colorScheme.onPrimary,)
                ),

                GestureDetector(
                  onTap: widget.onSettings,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.settings_rounded,
                      size: 30,
                      color: widget.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
