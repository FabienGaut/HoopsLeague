import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  void setLocale(String langCode) {
    _locale = Locale(langCode);
    notifyListeners();
  }
}

// Instancier une seule fois pour l'utiliser globalement
final AppState appState = AppState();
