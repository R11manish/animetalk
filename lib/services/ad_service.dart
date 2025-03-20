import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:animetalk/core/network/api_client.dart';
import 'package:animetalk/core/network/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final ApiClient _apiClient = ApiClient();
  static String? _cachedAdUnitId;
  static DateTime? _lastFetchTime;
  static const _cacheValidityDuration =
      Duration(hours: 24); // Cache for 24 hours

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static Future<String?> _getAdUnitId() async {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID during development
    }

    if (_cachedAdUnitId != null && _lastFetchTime != null) {
      final isCacheValid =
          DateTime.now().difference(_lastFetchTime!) < _cacheValidityDuration;
      if (isCacheValid) {
        return _cachedAdUnitId;
      }
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.adUnitId);
      if (response.statusCode == 200 && response.data != null) {
        final adUnitId = response.data['adUnitId'] as String;
        // Update cache
        _cachedAdUnitId = adUnitId;
        _lastFetchTime = DateTime.now();
        return adUnitId;
      }
      throw Exception('Failed to load ad unit ID');
    } catch (e) {
      return null;
    }
  }

  static Future<BannerAd?> createBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) async {
    final adUnitId = await _getAdUnitId();
    if (adUnitId == null) return null;

    return BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
