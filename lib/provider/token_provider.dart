import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/util/helpers/classes/Rewards/token_services.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';

class TokenProvider extends ChangeNotifier {
  int _currentTokens = 50000;
  int _minimumTokens = 50000;
  bool _isUnlockedLowerPayouts = false;
  bool _isSuccessFullFirstPayout = false;
  final double _conversionRate = 0.01;
  String _payoutDate = '';
  bool _isRedeemAvailable = false;

  final List<Map<String, int>> payoutOptions = [
    {"tokens": 50000, "amount": 500},
    {"tokens": 25000, "amount": 250},
    {"tokens": 10000, "amount": 100},
    {"tokens": 5000, "amount": 50},
  ];

  TokenProvider( {required AuthProvider authProvider} ) {
    fetchTokens(authProvider.user_id);
    updateIsSuccessFullFirstPayout(false);
     updateIsUnlockedLowerPayouts();
    updateIsRedeemAvailable();
  }

  final TokenService _tokenService = TokenService();

  // Getters
  int get currentTokens => _currentTokens;
  double get convertedValue => _currentTokens * _conversionRate;
  String get payoutDate => _payoutDate;
  bool get isRedeemAvailable => _isRedeemAvailable;
  bool get isUnlockedLowerPayouts => _isUnlockedLowerPayouts;
  bool get isSuccessFullFirstPayout => _isSuccessFullFirstPayout;
  int get minimumTokens => _minimumTokens;

  /// Fetch payout date from Supabase and update state
  Future<void> fetchPayoutDate() async {
    try {
      _payoutDate = (await _tokenService.fetchPayoutDate())!;
      notifyListeners(); // Notify UI to update
    } catch (e) {
      print('Error fetching payout date: $e');
      notifyListeners();
    }
  }

  Future<void> updateIsRedeemAvailable() async {
    _isRedeemAvailable = await isPayoutDateReached();
    notifyListeners();
  }

  void updateIsUnlockedLowerPayouts() {
    if (_currentTokens >= _minimumTokens && _isSuccessFullFirstPayout) {
      _isUnlockedLowerPayouts = true;
    }
    notifyListeners();
  }

  void updateIsSuccessFullFirstPayout(bool isTrue) {
    _isSuccessFullFirstPayout = isTrue;
    notifyListeners();
  }

  Future<void> fetchTokens(String userId) async {
    try {
       fetchPayoutDate();
      _currentTokens = await _tokenService.getUserTokenBalance(userId);
      if(await hasUserSuccessfulFirstPayout(userId)){
        updateIsSuccessFullFirstPayout(true);
      }
      if ( await getWithdrawalStatus(userId) == "approved" ) {
        await updateUserFirstPayout(userId);
      }
       await updateIsRedeemAvailable();
      notifyListeners();
    } catch (e) {
      _currentTokens = 0;
      debugPrint("Error fetching tokens: $e");
    }
  }

  Future<bool> updateTokens(String userId, int amount, String type) async {
    try {
      bool success = await _tokenService.updateTokens(userId, amount, type, _currentTokens);
      if (success) {
        _currentTokens += amount;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint("Error updating tokens: $e");
      return false;
    }
  }

  /// ✅ Check if User Has a Successful First Payout
  Future<bool> hasUserSuccessfulFirstPayout(String userId) async {
    try {
       return await _tokenService.hasUserSuccessfulFirstPayout(userId);
    } catch (e) {
      debugPrint('Error checking first payout: $e');
      return false;
    }
  }


  Future<bool> isPayoutDateReached() async {
    try {
      DateTime now = await NTP.now();
      DateTime payout = DateTime.parse(_payoutDate);
      return now.isAfter(payout) || now.isAtSameMomentAs(payout);
    } catch (e) {
      debugPrint("Error checking payout date: $e");
      return false;
    }
  }

  Future<DateTime?> fetchNetworkTime() async {
    try {
      return await NTP.now();
    } catch (e) {
      debugPrint("Error fetching network time: $e");
      return null; // Return null if an error occurs
    }
  }

  Future<String?> fetchRemainingTime(String payoutDate, TokenProvider tokenProvider) async {
    DateTime? now = await fetchNetworkTime();
    if (now == null) return null; // Handle error case

    DateTime payout = DateTime.parse(payoutDate);
    Duration difference = payout.difference(now);

    if (difference.inDays > 0) {
      return "Payout in ${difference.inDays} days";
    } else if (difference.inHours > 0) {
      return "Payout in ${difference.inHours} hours";
    } else {
      return "✅ Payout available!";
    }
  }

  /// ✅ Get Withdrawal Status for User
  Future<String?> getWithdrawalStatus(String userId) async {
    try {
         return await _tokenService.getWithdrawalStatus(userId);
    } catch (e) {
      debugPrint('Error fetching withdrawal status: $e');
      return null;
    }
  }

  /// ✅ Update User's Successful First Payout
  Future<bool> updateUserFirstPayout(String userId) async {
    try {
      return await _tokenService.updateUserFirstPayout(userId);
    } catch (e) {
      debugPrint('Error updating first payout: $e');
      return false;
    }
  }

  Future<bool> redeemTokens(String userId, int amount,BuildContext context) async {
    if (!await isPayoutDateReached()) {
      debugPrint("Payout date not reached.");
      showAuthDialog(context, type: "warning", "Warning",  "Payout date not reached.");
      return false;
    }
    if (_currentTokens < amount) {
      debugPrint("Insufficient tokens.");
      showAuthDialog(context, type: "warning", "Warning",  "Insufficient tokens.");
      return false;
    }
    try {
      bool success = await _tokenService.requestWithdrawal(userId, amount);
      if (success) {
        await updateTokens(userId, amount, "withdraw");
        _currentTokens -= amount;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint("Error redeeming tokens: $e");
      return false;
    }
  }
}
