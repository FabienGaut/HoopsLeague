import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Mobile-specific Ad Banner Widget using Google AdMob
/// This widget is used on Android and iOS platforms
class AdBannerWidgetMobile extends StatefulWidget {
  const AdBannerWidgetMobile({super.key});

  @override
  State<AdBannerWidgetMobile> createState() => _AdBannerWidgetMobileState();
}

class _AdBannerWidgetMobileState extends State<AdBannerWidgetMobile> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  /// Get the appropriate Ad Unit ID based on the platform
  String? get _adUnitId {
    // Get Ad Unit ID from environment variables based on platform
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_BANNER_ANDROID'];
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_BANNER_IOS'];
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Don't load ads if Ad Unit ID is not configured
    if (_adUnitId == null) {
      debugPrint('AdMob: Ad Unit ID not configured for this platform');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: _adUnitId!,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return empty widget if ad is not loaded
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
