import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';

/// Widget CAPTCHA réutilisable avec gestion propre du cycle de vie
class CaptchaWidget extends StatefulWidget {
  final Function(String) onTokenReceived;
  final Function(TurnstileException) onError;
  final VoidCallback onTokenExpired;

  const CaptchaWidget({
    super.key,
    required this.onTokenReceived,
    required this.onError,
    required this.onTokenExpired,
  });

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}
class _CaptchaWidgetState extends State<CaptchaWidget> {
  late final String _instanceId;
  late final TurnstileController _controller;

  @override
  void initState() {
    super.initState();
    // Créer un ID unique pour cette instance du widget
    _instanceId = 'captcha_${DateTime.now().microsecondsSinceEpoch}';
    // Initialiser le contrôleur pour gérer le cycle de vie du CAPTCHA
    _controller = TurnstileController();
    debugPrint('🔑 CaptchaWidget created with ID: $_instanceId');
  }

  @override
  void dispose() {
    debugPrint('🗑️ CaptchaWidget disposing with ID: $_instanceId');
    // Disposer le contrôleur pour nettoyer l'état DOM
    _controller.dispose();
    debugPrint('🗑️ CaptchaWidget disposed with ID: $_instanceId');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CloudflareTurnstile(
      key: ValueKey(_instanceId),
      controller: _controller,
      siteKey: const String.fromEnvironment('TURNSTILE_SITE_KEY', defaultValue: '1x00000000000000000000AA'),
      baseUrl: kIsWeb ? 'http://localhost' : 'https://hoopsleague.fr',
      onTokenReceived: widget.onTokenReceived,
      onError: widget.onError,
      onTokenExpired: widget.onTokenExpired,
    );
  }
}
