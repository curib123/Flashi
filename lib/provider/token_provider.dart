import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/util/helpers/classes/Rewards/token_services.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ntp/ntp.dart';

class TokenProvider extends ChangeNotifier {
  double _currentTokens = 0;
  double _minimumTokens = 100000;
  bool _isSuccessFullFirstPayout = false;
  final double _conversionRate = 50000;
  String _payoutDate = '';
  bool _isRedeemAvailable = false;
  bool _isReviewing = false;
  String _gCashNumber = '';
  String _paypalEmail = '';
  String _payoutMethod = 'GCash';

  List<String> paymentMethods = ["GCash", "PayPal"];
  final List<Map<String, double>> payoutOptions = [
    {"tokens": 100000, "amount": 2},
    {"tokens": 50000, "amount": 1},
    {"tokens": 20000, "amount": 0.3},
    {"tokens": 10000, "amount": 0.1},
  ];

  TokenProvider( {required AuthProvider authProvider} ) {
    fetchTokens(authProvider.user_id);
    updateIsRedeemAvailable();
    loadDataPaymentMethod();
  }

  final TokenService _tokenService = TokenService();
  final Box _storage = Hive.box('payment_method'); // Hive box for settings

  // Getters
  double get currentTokens => _currentTokens;
  double get convertedValue => double.parse((_currentTokens / _conversionRate).toStringAsFixed(2));
  String get payoutDate => _payoutDate;
  bool get isRedeemAvailable => _isRedeemAvailable;
  bool get isSuccessFullFirstPayout => _isSuccessFullFirstPayout;
  double get minimumTokens => _minimumTokens;
  bool get isReviewing => _isReviewing;
  String get gCashNumber => _gCashNumber;
  String get paypalEmail => _paypalEmail;
  String get payoutMethod => _payoutMethod;



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

  void updateGcashNumber(String number)  {
    _gCashNumber = number;
    saveDataPaymentMethod();
    notifyListeners();
  }

  void updatePaypalEmail(String email)  {
    _paypalEmail = email;
    saveDataPaymentMethod();
    notifyListeners();
  }

  void updatePayoutMethod(String method) {
    _payoutMethod = method;
    saveDataPaymentMethod();
    notifyListeners();
  }
  void saveDataPaymentMethod() {
    _storage.put('gcashNumber', _gCashNumber);
    _storage.put('paypalEmail', _paypalEmail);
    _storage.put('paypalMethod', _payoutMethod);
    notifyListeners();
  }

  void loadDataPaymentMethod() {
    _gCashNumber = _storage.get('gcashNumber', defaultValue: "");
    _paypalEmail = _storage.get('paypalEmail', defaultValue: "");
    _paypalEmail = _storage.get('paypalMethod', defaultValue: "");
    notifyListeners();
  }
 void updateUserToken(double newValue) {
    _currentTokens = newValue;
    notifyListeners();
  }

  void modifyUserTokens({required isIncrement, required double requiredTokens}) {
    if (isIncrement) {
      _currentTokens += requiredTokens;
    } else {
      _currentTokens -= requiredTokens;
    }
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
      updateUserToken(await getUserTokenBalance(userId));
      print("Current Token : ${await getUserTokenBalance(userId)}");
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
      debugPrint("Error fetching tokens: $e");
      return false; // Failure
    }
  }


  Future<bool> updateUserTokenBalance(String userId, double tokenBalance) async {
    try {
        return await _tokenService.updateUserTokenBalance(userId, tokenBalance);
    } catch (e) {
      debugPrint('Error updating token balance: $e');
      return false;
    }
  }

  Future<bool> insertTokenTransaction(
      String userId, double amount, String type, String status, bool success_first_payout) async {
    try {
     return await _tokenService.insertTokenTransaction(userId, amount, type, status, success_first_payout);
    } catch (e) {
      debugPrint('Error inserting token transaction: $e');
      return false;
    }
  }
  Future<double?> getLatestWithdrawAmount(String userId) async {
    try {
      return await _tokenService.getLatestWithdrawAmount(userId);
    } catch (e) {
      debugPrint('Error fetching latest withdrawal amount: $e');
      return null; // Return null if there's an error or no data
    }
  }

  /// ✅ Get Token Withdrawal History
  Future<List<Map<String, dynamic>>> getUserWithdrawalRequest(String userId) async {
    try {
      return await _tokenService.getUserWithdrawalRequest(userId);
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  /// ✅ Get Token Transaction History
  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
     return await _tokenService.getUserTransactions(userId);
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
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
  Future<double> getUserTokenBalance(String userId) async {
    try {
     return await _tokenService.getUserTokenBalance(userId);
    } catch (e) {
      debugPrint('Error fetching token balance: $e');
      return 0;
    }
  }
  Future<bool> redeemTokens(String userId, double amount,double requiredTokens,AuthProvider authProvider,BuildContext context) async {
    if (!await isPayoutDateReached()) {
      debugPrint("Payout date not reached.");
      showAuthDialog(context, type: "warning", "Warning",  "Payout date not reached.");
      return false;
    }
    if (_currentTokens < requiredTokens) {
      debugPrint("Insufficient tokens.");
      showAuthDialog(context, type: "warning", "Warning",  "Insufficient tokens.");
      return false;
    }
    try {
        modifyUserTokens(isIncrement: false, requiredTokens: requiredTokens); // Ensure _currentTokens is properly initialized
        await updateUserTokenBalance(userId, _currentTokens);
        await insertTokenTransaction(userId, requiredTokens, "spend", "completed", _isSuccessFullFirstPayout);
        await _tokenService.requestWithdrawal(userId, amount, payoutMethod == "GCash" ? gCashNumber : paypalEmail);
        showAuthDialog(context, type: "info", "Processing", "Your redemption request is under review.");



      return false; // Explicitly return false if withdrawal fails
    } catch (e) {
      debugPrint("Error redeeming tokens: $e");
      await insertTokenTransaction(userId, amount, "spend", "failed",_isSuccessFullFirstPayout);
      return false;
    }

  }
}
