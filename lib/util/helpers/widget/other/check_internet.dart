import 'dart:io';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

Future<bool> isHaveInternet() async {
  bool hasConnection = await InternetConnection().hasInternetAccess;

  if (hasConnection) {
    // Make an actual request to confirm internet access
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  return false;
}
