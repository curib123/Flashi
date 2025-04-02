import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flashi/provider/auth_provider.dart';

void fetchDataTokens(BuildContext context, Function(AuthProvider)? checkInternet) {
  final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  print(tokenProvider.generateReferralCode(tokenProvider.getDeviceId()));

  // Ensure checkInternet is not null before calling it
  if (checkInternet != null) {
    checkInternet(authProvider);
  }

  Future.microtask(() async {
    await tokenProvider.fetchReferralCode(authProvider.user_id);
    await tokenProvider.fetchUpdateTotalInvite(authProvider.user_id);
    await tokenProvider.fetchUpdateTotalInviteToken(authProvider.user_id);
    await tokenProvider.insertUserTokenBalanceIfEmpty(authProvider.user_id);
    await tokenProvider.fetchTokens(authProvider.user_id);
    await tokenProvider.updateIsReviewing(authProvider.user_id);
    await tokenProvider.fetchPayoutDate();
    await tokenProvider.updateIsRedeemAvailable();
  });
}
