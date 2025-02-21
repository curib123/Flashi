import 'package:flashi/provider/save_info_ads_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/classes/ads/ad_unit_id.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
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
    final saveInfoAdsProvider = Provider.of<SaveInfoAdsProvider>(context);

    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      child: GestureDetector(
        onTap: () => _handleAdTap(context, saveInfoAdsProvider),
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
                      saveInfoAdsProvider.adsWatchedToday < 3
                          ? name
                          : 'Ad Limit Reached',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${saveInfoAdsProvider.adsWatchedToday}/3)',
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
                "Limited to 3 ads per day",
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

  Future<void> _handleAdTap(BuildContext context, SaveInfoAdsProvider saveInfoAdsProvider) async {
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

    if (saveInfoAdsProvider.adsWatchedToday < 3) {
      AdManager adManager = AdManager();
      adManager.loadRewardedAd(AdUnitId.rewardedAdUnitId);

      showLoadingDialog(context, text: "Loading ads... Please wait.\nIf it doesn’t appear, try again.");

      Future.delayed(const Duration(seconds: 10), () {
        Navigator.of(context).pop(); // Close loading dialog
        _showConfirmationDialog(context);

      });
    } else {
      _showDialog(
        context,
        title: "Ad Limit Reached",
        message: "You have reached the maximum of 3 ads for today. Please come back tomorrow!",
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      );
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Watch Ad?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Would you like to watch an ad to get a free 5 card slots reward?",
            style: TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                AdManager().showRewarded(context, "cards");
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("No"),
            ),
          ],
        );
      },
    );
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