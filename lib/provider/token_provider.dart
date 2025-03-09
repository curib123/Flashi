import 'package:flashi/util/helpers/classes/Rewards/token_services.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenProvider extends ChangeNotifier {
  int _currentTokens = 0;
  final double _conversionRate = 0.01;
  final String _payoutDate = "2025-03-12"; // YYYY-MM-DD
  bool _isRedeemAvailable = false; // Dynamically updated

  final TokenService _tokenService = TokenService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  int get currentTokens => _currentTokens;
  double get convertedValue => _currentTokens * _conversionRate;
  String get payoutDate => _payoutDate;
  bool get isRedeemAvailable => _isRedeemAvailable;

  /// Fetch user's token balance
  Future<void> fetchTokens(String userId) async {
    try {
      // First, try to load the tokens from local storage
      String? storedTokens = await _secureStorage.read(key: 'tokens');
      String? storedRedeemStatus = await _secureStorage.read(key: 'redeemAvailable');

      if (storedTokens != null) {
        _currentTokens = int.parse(storedTokens);
      }

      if (storedRedeemStatus != null) {
        _isRedeemAvailable = storedRedeemStatus == 'true';
      } else {
        _isRedeemAvailable = await isPayoutDateReached();
      }

      // If online, fetch from the server to sync the data
      _currentTokens = await _tokenService.getUserTokenBalance(userId);
      _isRedeemAvailable = await isPayoutDateReached();

      // Save the fetched values to local storage
      await _secureStorage.write(key: 'tokens', value: _currentTokens.toString());
      await _secureStorage.write(key: 'redeemAvailable', value: _isRedeemAvailable.toString());

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching tokens: $e");
    }
  }

  /// Update tokens (earn/spend)
  Future<bool> updateTokens(String userId, int amount, String type) async {
    try {
      bool success = await _tokenService.updateTokens(userId, amount, type);
      if (success) {
        _currentTokens += amount;

        // Save updated token balance to local storage
        await _secureStorage.write(key: 'tokens', value: _currentTokens.toString());

        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint("Error updating tokens: $e");
      return false;
    }
  }

  /// Check if the payout date is reached
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

  /// Redeem tokens
  Future<bool> redeemTokens(String userId, int amount) async {
    if (!await isPayoutDateReached()) {
      debugPrint("Payout date not reached.");
      return false;
    }
    if (_currentTokens < amount) {
      debugPrint("Insufficient tokens.");
      return false;
    }
    try {
      bool success = await _tokenService.requestWithdrawal(userId, amount);
      if (success) {
        _currentTokens -= amount;

        // Save updated token balance to local storage
        await _secureStorage.write(key: 'tokens', value: _currentTokens.toString());

        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint("Error redeeming tokens: $e");
      return false;
    }
  }
}
