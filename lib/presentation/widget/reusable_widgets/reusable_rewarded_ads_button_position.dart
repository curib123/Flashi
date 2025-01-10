import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flashlearn/util/helpers/ads/ad_unit_id.dart'; // Assuming you have an AdUnitId
import 'package:flashlearn/util/helpers/ads/ads_manager.dart'; // Assuming you have an AdManager

class ReusableRewardedAdsButtonPosition extends StatefulWidget {
  final ColorScheme colorScheme;
  final String name;
  final Function()? onTap;

  const ReusableRewardedAdsButtonPosition({
    super.key,
    required this.colorScheme,
    required this.name,
    required this.onTap,
  });

  @override
  _ReusableRewardedAdsButtonPositionState createState() =>
      _ReusableRewardedAdsButtonPositionState();
}
class _ReusableRewardedAdsButtonPositionState
    extends State<ReusableRewardedAdsButtonPosition> {
  late AdManager _adManager;
  late Box _box;
  late String _lastAdDate;
  int _adsWatchedToday = 0;

  @override
  void initState() {
    super.initState();

    // Retrieve saved data from Hive
    _box = Hive.box('timerBox');
    _lastAdDate = _box.get('lastAdDate', defaultValue: '');
    _adsWatchedToday = _box.get('adsWatchedToday', defaultValue: 0);

    // Reset ads watched count if the date has changed
    String currentDate = DateTime.now().toIso8601String().substring(0, 10);
    if (_lastAdDate != currentDate) {
      _adsWatchedToday = 0;
      _saveAdWatchState(); // Save reset count
    }
  }

  // Function to load the ad
  void _loadAd() {
    if (_adsWatchedToday >= 3) {
      _showAdLimitReachedDialog();
      return;
    }

    _adManager = AdManager();
    _adManager.loadRewardedAd(AdUnitIds.rewardedAdUnitId); // Assuming this method handles ad loading

    setState(() {
      _adsWatchedToday++; // Increment ads watched
    });

    _saveAdWatchState(); // Save the updated count
  }

  // Function to save ad watch state
  void _saveAdWatchState() async {
    String currentDate = DateTime.now().toIso8601String().substring(0, 10);
    await _box.put('adsWatchedToday', _adsWatchedToday);
    await _box.put('lastAdDate', currentDate); // Save the current date
  }

  // Function to show dialog when ad limit is reached
  void _showAdLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ad Limit Reached"),
        content: Text("You have reached the maximum of 3 ads for today. Please come back tomorrow!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: _adsWatchedToday < 3
            ? () {
          if (widget.onTap != null) {
            widget.onTap!(); // Trigger the onTap function
          }
          _loadAd(); // Load ad if not reached the limit
        }
            : () {
          _showAdLimitReachedDialog(); // Show dialog if ad limit is reached
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 25),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: widget.colorScheme.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_rounded,
                color: widget.colorScheme.onPrimary,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                _adsWatchedToday < 3
                    ? widget.name
                    : 'Ad Limit Reached', // Display limit reached if 3 ads watched
                style: TextStyle(
                  color: widget.colorScheme.onPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              // Display the number of ads watched out of the limit
              Text(
                '($_adsWatchedToday/3)',
                style: TextStyle(
                  color: widget.colorScheme.onPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
