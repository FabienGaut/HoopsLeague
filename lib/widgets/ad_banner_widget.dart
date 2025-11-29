import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'ad_banner_widget_mobile.dart';
// Conditional import: use web implementation on web, stub on other platforms
import 'web_ad_banner_widget_stub.dart'
    if (dart.library.html) 'web_ad_banner_widget.dart';

/// Universal Ad Banner Widget that automatically selects the right implementation
/// - Web: Uses Google AdSense via WebAdBannerWidget
/// - Mobile (Android/iOS): Uses Google AdMob via AdBannerWidgetMobile
class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Use AdSense for web
      return WebAdBannerWidget();
    } else {
      // Use AdMob for mobile
      return AdBannerWidgetMobile();
    }
  }
}
