import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/util/helpers/classes/Rewards/token_services.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';

class TokenProvider extends ChangeNotifier {
  int _currentTokens = 50000;
  int _minimumTokens = 50000;
  bool _isSuccessFullFirstPayout = false;
  final double _conversionRate = 0.01;
  String _payoutDate = '';
  bool _isRedeemAvailable = false;
  bool _isReviewing = false;
  String _gCashNumber = '';

  final List<Map<String, int>> payoutOptions = [
    {"tokens": 50000, "amount": 500},
    {"tokens": 25000, "amount": 250},
    {"tokens": 10000, "amount": 100},
    {"tokens": 5000, "amount": 50},
  ];

  TokenProvider( {required AuthProvider authProvider} ) {
    fetchTokens(authProvider.user_id);
    updateIsRedeemAvailable();
  }

  final TokenService _tokenService = TokenService();

  // Getters
  int get currentTokens => _currentTokens;
  double get convertedValue => _currentTokens * _conversionRate;
  String get payoutDate => _payoutDate;
  bool get isRedeemAvailable => _isRedeemAvailable;
  bool get isSuccessFullFirstPayout => _isSuccessFullFirstPayout;
  int get minimumTokens => _minimumTokens;
  bool get isReviewing => _isReviewing;
  String get gCashNumber => _gCashNumber;

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

  Future<void> updateGcashNumber(Future<String?> number) async {
    _gCashNumber = number as String;
    notifyListeners();
  }

  Future<void> updateIsRedeemAvailable() async {
    _isRedeemAvailable = await isPayoutDateReached();
    notifyListeners();
  }

  Future<void> updateIsReviewing(String userId) async {
    _isReviewing = await getIsReviewing(userId);
    notifyListeners();
  }

  Future<bool> getIsReviewing(String userId) async {
    return await getFirstReviewingWithdrawStatus(userId) == "reviewing";
  }


  void updateIsSuccessFullFirstPayout(bool isTrue) {
    _isSuccessFullFirstPayout = isTrue;
    print("is success full first payout $isTrue");
    notifyListeners();
  }

  Future<bool> fetchTokens(String userId) async {
    try {
      fetchPayoutDate();
      _currentTokens = await _tokenService.getUserTokenBalance(userId);
      bool? isUnlock = await hasUserSuccessfulFirstPayout(userId);
      updateIsSuccessFullFirstPayout(isUnlock!);
      if (await getFirstWithdrawStatus(userId) == "approved") {
       if ( await updateUserSuccessfulFirstPayout(userId, true)) {
          print("successfully first payout");
       };
      }else{
        print("error in approval");
      }
      await updateIsRedeemAvailable();
      notifyListeners();

      return true; // Success
    } catch (e) {
      _currentTokens = 0;
      debugPrint("Error fetching tokens: $e");
      return false; // Failure
    }
  }

  /// ✅ Get User's GCash Number
  Future<String?> getUserGcashNumber(String userId) async {
    try {
      return await _tokenService.getUserGcashNumber(userId);
    } catch (e) {
      debugPrint('Error fetching GCash number: $e');
      return null;
    }
  }

  /// ✅ Update User's GCash Number
  Future<bool> updateUserGcashNumber(String userId, String newGcashNumber) async {
    try {
     return await _tokenService.updateUserGcashNumber(userId, newGcashNumber);
    } catch (e) {
      debugPrint('Error updating GCash number: $e');
      return false; // Returns false if there's an error
    }
  }


  Future<bool> updateUserTokenBalance(String userId, int tokenBalance) async {
    try {
        return await _tokenService.updateUserTokenBalance(userId, tokenBalance);
    } catch (e) {
      debugPrint('Error updating token balance: $e');
      return false;
    }
  }

  Future<bool> insertTokenTransaction(
      String userId, int amount, String type, String status, bool success_first_payout) async {
    try {
     return await _tokenService.insertTokenTransaction(userId, amount, type, status, success_first_payout);
    } catch (e) {
      debugPrint('Error inserting token transaction: $e');
      return false;
    }
  }
  Future<int?> getLatestWithdrawAmount(String userId) async {
    try {
      return await _tokenService.getLatestWithdrawAmount(userId);
    } catch (e) {
      debugPrint('Error fetching latest withdrawal amount: $e');
      return null; // Return null if there's an error or no data
    }
  }



  /// ✅ Check if User Has a Successful First Payout
  Future<bool?> hasUserSuccessfulFirstPayout(String userId) async {
    try {
       return await _tokenService.hasUserSuccessfulFirstPayout(userId);
    } catch (e) {
      debugPrint('Error checking first payout: $e');
      return false;
    }
  }
  Future<bool> updateUserSuccessfulFirstPayout(String userId, bool success) async {
    try {
  return await _tokenService.updateUserSuccessfulFirstPayout(userId, success);
    } catch (e) {
      debugPrint('Error updating first payout: $e');
      return false; // Returns false if an error occurred
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

  Future<String?> getFirstWithdrawStatus(String userId) async {
    try {
     return await _tokenService.getFirstWithdrawStatus(userId);
    } catch (e) {
      debugPrint('Error fetching first withdrawal status: $e');
      return null; // Return null if there's an error
    }
  }

  Future<String?> getFirstReviewingWithdrawStatus(String userId) async {
    try {
      return await _tokenService.getFirstReviewingWithdrawStatus(userId);
    } catch (e) {
      debugPrint('Error fetching first reviewing withdrawal status: $e');
      return null; // Return null if there's an error
    }
  }


  /// ✅ Get User's Token Balance
  Future<int> getUserTokenBalance(String userId) async {
    try {
     return await getUserTokenBalance(userId);
    } catch (e) {
      debugPrint('Error fetching token balance: $e');
      return 0;
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
       await _tokenService.requestWithdrawal(userId, amount);

      if (await fetchTokens(userId)) {
        _currentTokens -= amount; // Ensure _currentTokens is properly initialized
        await updateUserTokenBalance(userId, _currentTokens);
        await insertTokenTransaction(userId, amount, "spend", "completed", _isSuccessFullFirstPayout);
        return true;
      }

      return false; // Explicitly return false if withdrawal fails
    } catch (e) {
      debugPrint("Error redeeming tokens: $e");
      await insertTokenTransaction(userId, amount, "spend", "failed",_isSuccessFullFirstPayout);
      return false;
    }

  }
}
