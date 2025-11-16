import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color accentPrimary = Color(0xFF256AF4);

  // Textes
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  // Fonds et surfaces
  static const Color surfaceDark = Color(0xFF182134);
  static const Color backgroundDark = Color(0xFF101622);

  // Dégradé pour fond
  static const Color gradientStart = Color(0xFF314368);
  static const Color gradientEnd = Colors.black;

  // Couleurs supplémentaires
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;
  static  Color primaryBlue = Color(0xFF256af4);
  static  Color borderDark = Color(0xFF314368);

  // Dégradé principal HoopsCart
  static const LinearGradient hoopscartGradient = LinearGradient(
    colors: [Color(0xFF314368), Colors.black],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final Color appBar = Colors.black.withOpacity(0.2);



}
