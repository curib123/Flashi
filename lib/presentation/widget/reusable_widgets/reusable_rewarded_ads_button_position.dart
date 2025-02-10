import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/provider/save_info_ads_provider.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class ReusableRewardedAdsButtonPosition extends StatefulWidget {
  final ColorScheme colorScheme;
  final String name;

  const ReusableRewardedAdsButtonPosition({
    super.key,
    required this.colorScheme,
    required this.name,
  });

  @override
  State<ReusableRewardedAdsButtonPosition> createState() => _ReusableRewardedAdsButtonPositionState();
}

class _ReusableRewardedAdsButtonPositionState extends State<ReusableRewardedAdsButtonPosition> {
  var startAppSdk = StartAppSdk();

  StartAppRewardedVideoAd? rewardedVideoAd;

  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
    startAppSdk.setTestAdsEnabled(false);

    loadRewardedVideoAd();
  }

  void loadRewardedVideoAd() {
    startAppSdk.loadRewardedVideoAd(
      onAdNotDisplayed: () {
        debugPrint('onAdNotDisplayed: rewarded video');

        setState(() {
          // NOTE rewarded video ad can be shown only once
          this.rewardedVideoAd?.dispose();
          this.rewardedVideoAd = null;
        });
      },
      onAdHidden: () {
        debugPrint('onAdHidden: rewarded video');

        setState(() {
          // NOTE rewarded video ad can be shown only once
          this.rewardedVideoAd?.dispose();
          this.rewardedVideoAd = null;
        });
      },
      onVideoCompleted: () {
        debugPrint('onVideoCompleted: rewarded video completed, user gain a reward');

        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        final saveInfoAdsProvider = Provider.of<SaveInfoAdsProvider>(
            context, listen: false);

        setState(() {
          // TODO give reward to user
          quizProvider.updateQuizSetLimit();
          saveInfoAdsProvider.incrementAdsWatched();
        });
      },
    ).then((rewardedVideoAd) {
      setState(() {
        this.rewardedVideoAd = rewardedVideoAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Rewarded Video ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Rewarded Video ad: $error");
    });
  }


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
            color: widget.colorScheme.primary,
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
                    color: widget.colorScheme.onPrimary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      saveInfoAdsProvider.adsWatchedToday < 5
                          ? widget.name
                          : 'Ad Limit Reached',
                      style: TextStyle(
                        color: widget.colorScheme.onPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${saveInfoAdsProvider.adsWatchedToday}/5)',
                    style: TextStyle(
                      color: widget.colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Limited to 5 ads per day",
                style: TextStyle(
                  color: widget.colorScheme.onPrimary.withOpacity(0.8),
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

    if (saveInfoAdsProvider.adsWatchedToday < 5) {


      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading ad...")
              ],
            ),
          ),
        ),
      );



      Future.delayed(const Duration(seconds: 10), () {
        Navigator.of(context).pop(); // Close loading dialog
        _showConfirmationDialog(context);
      });
    } else {
      _showDialog(
        context,
        title: "Ad Limit Reached",
        message: "You have reached the maximum of 5 ads for today. Please come back tomorrow!",
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

    _showDialog(
      context,
      title: "Watch Ad?",
      message: "Would you like to watch an ad to get free 5 card slots reward?",
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (rewardedVideoAd != null) {
              rewardedVideoAd!.show().onError((error, stackTrace) {
                debugPrint("Error showing Rewarded Video ad: $error");
                return false;
              });
            }

          },
          child: const Text("Yes"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("No"),
        ),
      ],
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
