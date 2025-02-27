import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flashi/util/helpers/widget/alert_dialog/show_update_dialog_alert_box.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CheckVersionProvider with ChangeNotifier {
  String currentVersion = "";
  String latestVersion = ""; // Will be fetched from API
  String downloadLink = "";
  String patchNote = "";

  // Function to get the current version of the app
  Future<void> checkAppVersion(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;

    // Fetch latest version from API
    await fetchLatestVersion();

    if (_isLatestVersionLower(currentVersion, latestVersion)) {
      showUpdateDialog(context, currentVersion, latestVersion, downloadLink, patchNote);
    }
  }

  Future<void> fetchLatestVersion() async {
    final response = await http.get(Uri.parse('https://curib123.github.io/flashi_/flashi.json'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      latestVersion = data['latest_version'];
      downloadLink = data['download_link'];
      patchNote = data['patch_note'];

      print("Latest Version: $latestVersion");
    } else {
      print("Failed to load version data");
      latestVersion = currentVersion;
    }
  }

  bool _isLatestVersionLower(String current, String latest) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length; i++) {
      if (i >= latestParts.length) return false; // If latest version has fewer parts, it's not newer
      if (latestParts[i] < currentParts[i]) return false; // Latest version is lower
      if (latestParts[i] > currentParts[i]) return true; // Latest version is higher
    }
    return false; // Versions are equal
  }
}
