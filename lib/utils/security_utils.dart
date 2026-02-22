import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityUtils {
  static final _supabase = Supabase.instance.client;

  static bool validateCurrentUser(String uid) {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return false;
    return currentUser.id == uid;
  }

  static void requireCurrentUser(String uid) {
    if (!validateCurrentUser(uid)) {
      throw SecurityException('Unauthorized: User ID mismatch');
    }
  }

  static String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  static void requireAuthenticated() {
    if (_supabase.auth.currentUser == null) {
      throw SecurityException('Unauthorized: No authenticated user');
    }
  }
}

class SecurityException implements Exception {
  final String message;

  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
