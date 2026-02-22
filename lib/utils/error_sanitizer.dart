class ErrorSanitizer {
  static String getSafeErrorMessage(dynamic error, {String? context}) {
    return context != null
        ? 'Erreur lors de l\'opération suivante : $context'
        : 'Une erreur est survenue';
  }

  static String getAuthErrorMessage(dynamic error) {
    return 'Identifiants invalides';
  }

  static String getNetworkErrorMessage(dynamic error) {
    return 'Problème de connexion';
  }

  static String getDatabaseErrorMessage(dynamic error) {
    return 'Erreur d\'enregistrement';
  }
}
