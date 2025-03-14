import 'dart:convert';
import 'dart:math';
import 'package:flashi/util/helpers/classes/Rewards/daily_rewards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class DailyActivitiesProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final List<Map<String, dynamic>> _activities = [];



  DailyActivitiesProvider() {
    _loadActivities();
    refreshDailyActivities();
  }

  // READ: Get the activities list
  List<Map<String, dynamic>> get activities => List.unmodifiable(_activities);

  // LOAD: Retrieve stored activities from Secure Storage
  Future<void> _loadActivities() async {
    String? storedData = await _secureStorage.read(key: 'activities');
    if (storedData != null) {
      List<dynamic> decodedData = jsonDecode(storedData);
      _activities.clear();
      _activities.addAll(decodedData.cast<Map<String, dynamic>>());
    } else {
      _activities.addAll(dailyRewards); // Load default activities if no data is found
    }
    notifyListeners();
  }

  // SAVE: Store activities in Secure Storage
  Future<void> _saveActivities() async {
    await _secureStorage.write(key: 'activities', value: jsonEncode(_activities));
  }

  // CREATE: Add a new activity
  Future<void> addActivity(Map<String, dynamic> activity) async {
    activity['iteration'] = 0; // Initialize iteration
    _activities.add(activity);
    await _saveActivities();
    notifyListeners();
  }

  // UPDATE: Modify an existing activity
  Future<void> updateActivity(int index, Map<String, dynamic> updatedActivity) async {
    if (index >= 0 && index < _activities.length) {
      _activities[index] = updatedActivity;
      await _saveActivities();
      notifyListeners();
    }
  }

  // UPDATE SPECIFIC FIELDS
  Future<void> updateActivityDetails(int index, {int? amount, double? rewards, bool? isStart}) async {
    if (index >= 0 && index < _activities.length) {
      if (amount != null) _activities[index]['amount'] = amount;
      if (rewards != null) _activities[index]['rewards'] = rewards;
      if (isStart != null) _activities[index]['isStart'] = isStart;
      await _saveActivities();
      notifyListeners();
    }
  }

  // CLAIM REWARD: Increases iteration and toggles claim status
  Future<void> toggleClaimReward(int index) async {
    if (index >= 0 && index < _activities.length) {
      _activities[index]['isClaim'] = !_activities[index]['isClaim'];

      if (_activities[index]['isClaim']) {
        _activities[index]['iteration'] = (_activities[index]['iteration'] ?? 0) + 1;
      }

      await _saveActivities();
      notifyListeners();
    }
  }

  // TOGGLE START: Toggle 'isStart' status
  Future<void> toggleStart(int index) async {
    if (index >= 0 && index < _activities.length) {
      _activities[index]['isStart'] = !_activities[index]['isStart'];
      await _saveActivities();
      notifyListeners();
    }
  }

  // DELETE: Remove an activity
  Future<void> deleteActivity(int index) async {
    if (index >= 0 && index < _activities.length) {
      _activities.removeAt(index);
      await _saveActivities();
      notifyListeners();
    }
  }

  // CLEAR STORAGE: Delete all activities from secure storage
  Future<void> clearAllActivities() async {
    _activities.clear();
    await _secureStorage.delete(key: 'activities');
    notifyListeners();
  }

  // RESET DAILY ACTIVITIES AND SCALE REWARDS
  Future<void> refreshDailyActivities() async {
    String? lastUpdatedDate = await _secureStorage.read(key: 'lastUpdatedDate');
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastUpdatedDate != todayDate) {
      Random random = Random();
      bool hasChanges = false;

      for (var activity in _activities) {
        if (activity['isClaim'] == true) {
          int iteration = (activity['iteration'] ?? 0);
          int minAmount = activity['minAmount'] ?? 5;
          int maxAmount = activity['maxAmount'] ?? 20;
          double minRewards = activity['minRewards'] ?? 10.0;
          double maxRewards = activity['maxRewards'] ?? 60.0;

          // Boost amount & rewards based on iteration
          double iterationFactor = 1 + (iteration * 0.01);
          int boostedAmount = (minAmount + random.nextInt((maxAmount - minAmount + 1))) * iterationFactor.toInt();
          double boostedRewards = (minRewards + (random.nextDouble() * (maxRewards - minRewards))) * iterationFactor;

          // Prevent extreme values (capping)
          activity['amount'] = min(boostedAmount, maxAmount * 2);
          activity['rewards'] = min(boostedRewards, maxRewards * 2);

          activity['isClaim'] = false; // Reset claim status
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await Future.wait([
          _secureStorage.write(key: 'lastUpdatedDate', value: todayDate),
          _saveActivities(),
        ]);
        notifyListeners();
      }
    }
  }
}
