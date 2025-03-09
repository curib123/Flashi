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

      if (response == null) return 0;
      return response['token_balance'] ?? 0;
    } catch (e) {
      print('Error fetching token balance: $e');
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
          .update({'token_balance': newBalance, 'last_updated': DateTime.now()})
          .eq('user_id', userId);

      if (response.error == null) {
        await _supabase.from('token_transactions').insert({
          'user_id': userId,
          'amount': amount,
          'transaction_type': type,
          'status': 'completed',
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating tokens: $e');
      return false;
    }
  }

  /// ✅ Get Token Transaction History
  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      final response = await _supabase
          .from('token_transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.isNotEmpty ? response as List<Map<String, dynamic>> : [];
    } catch (e) {
      print('Error fetching transactions: $e');
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
        'requested_at': DateTime.now(),
      });

      if (response.error == null) {
        await updateTokens(userId, -amount, 'withdraw'); // Deduct tokens
        return true;
      }
      return false;
    } catch (e) {
      print('Error requesting withdrawal: $e');
      return false;
    }
  }

  /// ✅ Get Withdrawal Requests
  Future<List<Map<String, dynamic>>> getWithdrawRequests(String userId) async {
    try {
      final response = await _supabase
          .from('withdraw_requests')
          .select('*')
          .eq('user_id', userId)
          .order('requested_at', ascending: false);

      return response.isNotEmpty ? response as List<Map<String, dynamic>> : [];
    } catch (e) {
      print('Error fetching withdrawal requests: $e');
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

      return response.error == null;
    } catch (e) {
      print('Error updating withdrawal status: $e');
      return false;
    }
  }
}
