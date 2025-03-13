import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TokenService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<double> getUserTokenBalance(String userId) async {
    try {
      final response = await _supabase
          .from('users_tokens')
          .select('token_balance')
          .eq('user_id', userId)
          .maybeSingle();

      // Explicitly cast the value to double
      return (response?['token_balance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('Error fetching token balance: $e');
      return 0.0;
    }
  }

  Future<bool> updateUserTokenBalance(String userId, double tokenBalance) async {
    try {
      final response = await _supabase
          .from('users_tokens')
          .update({
        'token_balance': tokenBalance.toDouble(), // Ensure it's properly formatted
        'last_updated': DateTime.now().toIso8601String()
      })
          .eq('user_id', userId)
          .select(); // Ensure update worked

      return response.isNotEmpty; // Returns true if update was successful
    } catch (e) {
      debugPrint('Error updating token balance: $e');
      return false;
    }
  }

  Future<String> getSaveGenerateReferralCode(String userId) async {
    try {
      final response = await _supabase
          .from('users_tokens')
          .select('referral_code')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null || response['referral_code'] == null) {
        return ''; // Return an empty string if no referral code is found
      }

      return response['referral_code']; // Return the referral code if found
    } catch (e) {
      debugPrint('Error fetching referral code: $e');
      return ''; // Return empty string in case of an error
    }
  }


  Future<bool> SaveGenerateReferralCode(String userId, String code) async {
    try {
      // Fetch the current referral code for the user
      final response = await _supabase
          .from('users_tokens')
          .select('referral_code')
          .eq('user_id', userId)
          .single();

      // Check if the referral_code already exists
      if (response.isNotEmpty && response['referral_code'] != null && response['referral_code'].isNotEmpty) {
        return false; // Do not update if referral code already exists
      }

      // If empty, update the referral_code
      final updateResponse = await _supabase
          .from('users_tokens')
          .update({
        'referral_code': code,
        'last_updated': DateTime.now().toIso8601String(),
      })
          .eq('user_id', userId);

      return updateResponse.isNotEmpty; // Return true if update was successful
    } catch (e) {
      debugPrint('Error in generating code: $e');
      return false;
    }
  }


  Future<bool> insertTokenTransaction(
      String userId, double amount, String type, String status,bool success_first_payout) async {
    try {
      final response = await _supabase.from('token_transactions').insert({
        'user_id': userId,
        'amount': amount.toDouble(),
        'transaction_type': type,
        'success_first_payout' : success_first_payout,
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
      });

      return response != null; // Returns true if the insert was successful
    } catch (e) {
      debugPrint('Error inserting token transaction: $e');
      return false;
    }
  }




  /// fetch payout
  Future<String?> fetchPayoutDate() async {

    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('payouts')
          .select('payout_date')
          .single(); // Fetches only one row

      if (response.isEmpty) return null; // No data found

      return DateTime.parse(response['payout_date']).toIso8601String(); // Convert to DateTime
    } catch (e) {
      print('Error fetching payout date: $e');
      return null; // Handle errors
    }
  }


  Future<bool?> hasUserSuccessfulFirstPayout(String userId) async {
    try {
      final response = await _supabase
          .from('token_transactions')
          .select('success_first_payout')
          .eq('user_id', userId)
          .order('created_at', ascending: true) // Ensure getting the oldest first
          .limit(1)
          .maybeSingle(); // Fetch a single record, returns null if not found

      print("successfully first payouts");

      return response?['success_first_payout'] as bool?;
    } catch (e) {
      debugPrint('Error checking first payout: $e');
      return null; // Returning null to indicate an error or no data
    }
  }

  Future<bool> updateUserSuccessfulFirstPayout(String userId, bool success) async {
    try {
      final response = await _supabase
          .from('token_transactions')
          .update({'success_first_payout': success})
          .eq('user_id', userId)
          .order('created_at', ascending: true) // Ensure updating the oldest record
          .limit(1)
          .select(); // Ensure a response is returned

      return response.isNotEmpty; // Check if update was successful
    } catch (e) {
      debugPrint('Error updating first payout: $e');
      return false; // Return false in case of error
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

  /// ✅ Get Token Transaction History
  Future<List<Map<String, dynamic>>> getUserWithdrawalRequest(String userId) async {
    try {
      final List response = await _supabase
          .from('withdraw_requests')
          .select('*')
          .eq('user_id', userId)
          .order('requested_at', ascending: false);

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }


  /// ✅ Request a Withdrawal
  Future<bool> requestWithdrawal(String userId, double amount,String payment_receiver) async {
    try {
      final double balance = await getUserTokenBalance(userId);

      if (balance < amount) return false; // Not enough tokens
      await _supabase.from('withdraw_requests').insert({
        'user_id': userId,
        'amount': amount.toDouble(),
        'status': 'reviewing',
        'payment_method' : payment_receiver,
        'requested_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error requesting withdrawal: $e');
      return false;
    }
  }

  Future<double?> getLatestWithdrawAmount(String userId) async {
    try {
      final response = await _supabase
          .from('withdraw_requests')
          .select('amount')
          .eq('user_id', userId)
          .order('requested_at', ascending: false)
          .limit(1)
          .maybeSingle(); // Safer than `.single()`, returns null if no data

      return response?['amount'] as double?;
    } catch (e) {
      debugPrint('Error fetching latest withdrawal amount: $e');
      return null; // Return null if there's an error or no data
    }
  }

  Future<String?> getFirstReviewingWithdrawStatus(String userId) async {
    try {
      final response = await _supabase
          .from('withdraw_requests')
          .select('status') // Only select the 'status' column
          .eq('user_id', userId) // Filter by user ID
          .eq('status', 'reviewing') // Ensure the status is 'reviewing'
          .order('requested_at', ascending: true) // Get the oldest first
          .limit(1)
          .maybeSingle(); // Fetch only the first matching row

      return response?['status'] as String?;
    } catch (e) {
      debugPrint('Error fetching first reviewing withdrawal status: $e');
      return null; // Return null if there's an error
    }
  }



  Future<String?> getFirstWithdrawStatus(String userId) async {
    try {
      final response = await _supabase
          .from('withdraw_requests')
          .select('status') // Only select the 'status' column
          .eq('user_id', userId) // Filter by user ID
          .order('requested_at', ascending: true) // Get the oldest first
          .limit(1)
          .maybeSingle(); // Fetch only the first row

      return response?['status'] as String?;
    } catch (e) {
      debugPrint('Error fetching first withdrawal status: $e');
      return null; // Return null if there's an error
    }


  }





}
