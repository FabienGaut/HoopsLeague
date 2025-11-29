import 'package:flutter/foundation.dart';

/// Utility class for sanitizing error messages in production
/// 
/// In debug mode, shows full error details for debugging
/// In production mode, shows generic user-friendly messages
class ErrorSanitizer {
  /// Returns a safe error message suitable for displaying to users
  /// 
  /// In debug mode: Returns the full error message
  /// In production: Returns a generic error message
  static String getSafeErrorMessage(dynamic error, {String? context}) {
    if (kDebugMode) {
      // In debug mode, show full error for debugging
      return context != null 
          ? '$context: $error' 
          : error.toString();
    }
    
    // In production, show generic message
    return context != null
        ? 'Une erreur est survenue lors de $context. Veuillez réessayer.'
        : 'Une erreur est survenue. Veuillez réessayer.';
  }
  
  /// Returns a safe error message for authentication errors
  static String getAuthErrorMessage(dynamic error) {
    if (kDebugMode) {
      return 'Erreur d\'authentification: $error';
    }
    return 'Identifiants invalides. Veuillez vérifier vos informations.';
  }
  
  /// Returns a safe error message for network errors
  static String getNetworkErrorMessage(dynamic error) {
    if (kDebugMode) {
      return 'Erreur réseau: $error';
    }
    return 'Problème de connexion. Vérifiez votre connexion internet.';
  }
  
  /// Returns a safe error message for database errors
  static String getDatabaseErrorMessage(dynamic error) {
    if (kDebugMode) {
      return 'Erreur base de données: $error';
    }
    return 'Erreur lors de l\'enregistrement. Veuillez réessayer.';
  }
}
