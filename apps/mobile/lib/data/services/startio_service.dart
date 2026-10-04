import 'package:flashi/data/services/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:startapp_sdk/startapp.dart';

class StartIoService {
  final StartAppSdk _sdk = StartAppSdk();

  bool enabled = false;
  bool libraryBannerEnabled = false;
  String? appId;

  Future<void> configureFromBackend(ApiClient api) async {
    try {
      final config = await api.get('/api/v1/config');
      final rawAds = config['ads'];
      if (rawAds is! Map) return;
      final ads = Map<String, dynamic>.from(rawAds);
      enabled = ads['enabled'] == true;
      libraryBannerEnabled = enabled && ads['libraryBanner'] == true;
      appId = ads['appId']?.toString();
      await _sdk.setTestAdsEnabled(ads['testMode'] != false);
    } catch (error) {
      enabled = false;
      libraryBannerEnabled = false;
      debugPrint('Start.io config unavailable: $error');
    }
  }
}
