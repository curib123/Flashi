import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_maintenace_alert_box.dart';
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
    return Consumer2<QuizProvider, AiCreditProvider>(
      builder: (context, quizProvider, aiCreditProvider, child) {
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
                   showMaintenanceDialog(context, "No Internet", "Please connect to internet");
                 }
                  },
                  child: Container(
                    padding: EdgeInsets.only(left:10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
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

                SizedBox(width: 20),
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
