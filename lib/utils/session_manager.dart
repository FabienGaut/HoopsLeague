import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

class SessionManager {
  static DateTime _lastActivity = DateTime.now();
  static const Duration _timeout = Duration(minutes: 30);
  static final _supabase = Supabase.instance.client;

  static void recordActivity() {
    _lastActivity = DateTime.now();
  }

  static bool isSessionExpired() {
    return DateTime.now().difference(_lastActivity) > _timeout;
  }

  static Duration getTimeRemaining() {
    final elapsed = DateTime.now().difference(_lastActivity);
    final remaining = _timeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static Future<void> checkAndLogout(BuildContext context) async {
    if (isSessionExpired()) {
      await _supabase.auth.signOut();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.sessionExpired),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  static void resetSession() {
    _lastActivity = DateTime.now();
  }

  static DateTime getLastActivity() {
    return _lastActivity;
  }
}
