import 'package:flutter/material.dart';

/// Stub implementation of WebAdBannerWidget for non-web platforms
/// This file is used when compiling for mobile or desktop platforms
class WebAdBannerWidget extends StatelessWidget {
  const WebAdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Return empty widget on non-web platforms
    return const SizedBox.shrink();
  }
}
