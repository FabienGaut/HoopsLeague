import 'package:supabase_flutter/supabase_flutter.dart';

/// Security utilities for validating user authorization
class SecurityUtils {
  static final _supabase = Supabase.instance.client;
  
  /// Validates that the provided UID matches the current authenticated user
  /// Returns true if the UID matches the current user, false otherwise
  static bool validateCurrentUser(String uid) {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return false;
    return currentUser.id == uid;
  }
  
  /// Throws SecurityException if UID doesn't match current user
  /// Use this before any database operation that modifies user data
  static void requireCurrentUser(String uid) {
    if (!validateCurrentUser(uid)) {
      throw SecurityException('Unauthorized: User ID mismatch');
    }
  }
  
  /// Gets the current authenticated user's ID
  /// Returns null if no user is authenticated
  static String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }
  
  /// Validates that the current user is authenticated
  /// Throws SecurityException if not authenticated
  static void requireAuthenticated() {
    if (_supabase.auth.currentUser == null) {
      throw SecurityException('Unauthorized: No authenticated user');
    }
  }
}

/// Custom exception for security-related errors
class SecurityException implements Exception {
  final String message;
  
  SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}
