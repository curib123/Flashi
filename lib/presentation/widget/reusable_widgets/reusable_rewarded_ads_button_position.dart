import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_watch_ads_dialog.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class ReusableRewardedAdsButtonPosition extends StatelessWidget {
  final ColorScheme colorScheme;
  final String name;

  const ReusableRewardedAdsButtonPosition({
    super.key,
    required this.colorScheme,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final aiCreditProvider = Provider.of<AiCreditProvider>(context);

    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      child: GestureDetector(
        onTap: () => _handleAdTap(context, aiCreditProvider),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_rounded,
                    color: colorScheme.onPrimary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      aiCreditProvider.adsWatchedToday < 3 ? name : 'Ad Limit Reached',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${aiCreditProvider.adsWatchedToday}/ ${aiCreditProvider.maxAdsPerDay})',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Limited to ${aiCreditProvider.maxAdsPerDay} ads per day",
                style: TextStyle(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAdTap(BuildContext context, AiCreditProvider aiCreditProvider) async {
    bool isConnected = await InternetConnection().hasInternetAccess;

    if (!isConnected) {
      _showDialog(
        context,
        title: "No Internet",
        message: "Please connect to the internet to watch an ad. Try turning on Wi-Fi or mobile data.",
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      );
      return;
    }

    if (aiCreditProvider.adsWatchedToday < aiCreditProvider.maxAdsPerDay) {
      AdManager adManager = AdManager();
      adManager.loadRewardedAd(AdUnitId.rewardedAdUnitId);
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

    } else {
      _showDialog(
        context,
        title: "Ad Limit Reached",
        message: "You have reached the maximum of ${aiCreditProvider.maxAdsPerDay} ads for today. Please come back tomorrow!",
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      );
    }
  }


  void _showDialog(BuildContext context, {
    required String title,
    required String message,
    required List<Widget> actions,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: actions,
      ),
    );
  }
}