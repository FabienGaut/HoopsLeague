// ignore_for_file: avoid_web_libraries_in_flutter
// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Widget for displaying Google AdSense banner ads on Flutter Web
/// This widget is only used on web platform
class WebAdBannerWidget extends StatefulWidget {
  const WebAdBannerWidget({super.key});

  @override
  State<WebAdBannerWidget> createState() => _WebAdBannerWidgetState();
}

class _WebAdBannerWidgetState extends State<WebAdBannerWidget> {
  static int _adCounter = 0;
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'adsense-banner-${_adCounter++}';
    _registerAdView();
  }

  void _registerAdView() {
    final publisherId = dotenv.env['ADSENSE_PUBLISHER_ID'] ?? 'ca-pub-0000000000000000';
    final adSlot = dotenv.env['ADSENSE_AD_SLOT'] ?? '0000000000';

    // Create the ad container
    final adContainer = html.DivElement()
      ..id = _viewId
      ..style.width = '100%'
      ..style.height = '90px'
      ..style.margin = '0 0 16px 0'
      ..style.display = 'flex'
      ..style.justifyContent = 'center'
      ..style.alignItems = 'center';

    // Create the ins element for AdSense
    final insElement = html.Element.tag('ins')
      ..className = 'adsbygoogle'
      ..style.display = 'inline-block'
      ..style.width = '728px'
      ..style.height = '90px'
      ..setAttribute('data-ad-client', publisherId)
      ..setAttribute('data-ad-slot', adSlot);

    adContainer.append(insElement);

    // Register the view
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => adContainer,
    );

    // Push the ad after a short delay to ensure DOM is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        // Call AdSense push function
        final script = html.ScriptElement()
          ..text = '(adsbygoogle = window.adsbygoogle || []).push({});'
          ..async = true;
        html.document.body!.append(script);
      } catch (e) {
        debugPrint('AdSense error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Enable AdSense after site deployment and configuration
    // Temporarily disabled until AdSense account is set up
    return const SizedBox.shrink();
    
    /* Uncomment when ready to enable AdSense:
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 90,
      child: HtmlElementView(
        viewType: _viewId,
      ),
    );
    */
  }
}
