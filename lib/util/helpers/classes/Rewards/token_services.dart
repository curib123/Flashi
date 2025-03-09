import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TokenService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// ✅ Get User's Token Balance
  Future<int> getUserTokenBalance(String userId) async {
    try {
      final response = await _supabase
          .from('users_tokens')
          .select('token_balance')
          .eq('user_id', userId)
          .maybeSingle();

      return response?['token_balance'] ?? 0;
    } catch (e) {
      debugPrint('Error fetching token balance: $e');
      return 0;
    }
  }

  /// ✅ Update Token Balance (Increment or Decrement)
  Future<bool> updateTokens(String userId, int amount, String type) async {
    try {
      final int currentBalance = await getUserTokenBalance(userId);
      final int newBalance = currentBalance + amount;

      if (newBalance < 0) return false; // Prevents negative balance

      final response = await _supabase
          .from('users_tokens')
          .update({
        'token_balance': newBalance,
        'last_updated': DateTime.now().toIso8601String()
      })
          .eq('user_id', userId);

      if (response != null) {
        await _supabase.from('token_transactions').insert({
          'user_id': userId,
          'amount': amount,
          'transaction_type': type,
          'status': 'completed',
          'created_at': DateTime.now().toIso8601String(),
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating tokens: $e');
      return false;
    }
  }

  /// ✅ Get Token Transaction History
  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      final List response = await _supabase
          .from('token_transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  /// ✅ Request a Withdrawal
  Future<bool> requestWithdrawal(String userId, int amount) async {
    try {
      final int balance = await getUserTokenBalance(userId);
      if (balance < amount) return false; // Not enough tokens

      final response = await _supabase.from('withdraw_requests').insert({
        'user_id': userId,
        'amount': amount,
        'status': 'reviewing',
        'requested_at': DateTime.now().toIso8601String(),
      });

      if (response != null) {
        await updateTokens(userId, -amount, 'withdraw'); // Deduct tokens
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting withdrawal: $e');
      return false;
    }
  }

  /// ✅ Get Withdrawal Requests
  Future<List<Map<String, dynamic>>> getWithdrawRequests(String userId) async {
    try {
      final List response = await _supabase
          .from('withdraw_requests')
          .select('*')
          .eq('user_id', userId)
          .order('requested_at', ascending: false);

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching withdrawal requests: $e');
      return [];
    }
  }

  /// ✅ Admin: Approve or Reject a Withdrawal Request
  Future<bool> updateWithdrawStatus(String requestId, String status) async {
    try {
      final response = await _supabase
          .from('withdraw_requests')
          .update({'status': status})
          .eq('id', requestId);

      return response != null;
    } catch (e) {
      debugPrint('Error updating withdrawal status: $e');
      return false;
    }
  }



}
