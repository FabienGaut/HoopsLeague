import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

/// Session manager for handling user session timeout and inactivity detection
/// 
/// Automatically logs out users after 30 minutes of inactivity
class SessionManager {
  static DateTime _lastActivity = DateTime.now();
  static const Duration _timeout = Duration(minutes: 30);
  static final _supabase = Supabase.instance.client;
  
  /// Records user activity to reset the inactivity timer
  static void recordActivity() {
    _lastActivity = DateTime.now();
  }
  
  /// Checks if the current session has expired
  /// Returns true if more than 30 minutes have passed since last activity
  static bool isSessionExpired() {
    return DateTime.now().difference(_lastActivity) > _timeout;
  }
  
  /// Gets the time remaining before session expires
  static Duration getTimeRemaining() {
    final elapsed = DateTime.now().difference(_lastActivity);
    final remaining = _timeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  /// Checks session and logs out if expired
  /// Should be called periodically or on important actions
  static Future<void> checkAndLogout(BuildContext context) async {
    if (isSessionExpired()) {
      await _supabase.auth.signOut();
      
      if (context.mounted) {
        // Show timeout message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.sessionExpired),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
        
        // Navigate to login page
        // Note: This should be customized based on your app's navigation structure
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
  
  /// Resets the session timer
  static void resetSession() {
    _lastActivity = DateTime.now();
  }
  
  /// Gets the last activity timestamp
  static DateTime getLastActivity() {
    return _lastActivity;
  }
}
