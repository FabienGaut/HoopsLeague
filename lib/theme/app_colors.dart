import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundDark = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFF7F6F3);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFEFEFEF);

  static const Color textPrimary = Color(0xFF37352F);
  static const Color textSecondary = Color(0xFF787774);
  static const Color textTertiary = Color(0xFFA5A5A3);
  static const Color textOnAccent = Colors.white;

  static Color primaryBlue = const Color(0xFF2383E2);
  static const Color accentPrimary = Color(0xFF2383E2);
  static const Color accentSecondary = Color(0xFF9065B0);
  static const Color accentTertiary = Color(0xFFD9730D);

  static Color borderDark = const Color(0xFFE9E9E7);
  static const Color borderLight = Color(0xFFF1F1EF);
  static const Color borderFocus = Color(0xFF2383E2);

  static const Color success = Color(0xFF0F7B6C);
  static const Color error = Color(0xFFE03E3E);
  static const Color warning = Color(0xFFD9730D);
  static const Color info = Color(0xFF529CCA);

  static const Color gradientStart = Color(0xFFFFFFFF);
  static const Color gradientEnd = Color(0xFFF7F6F3);

  static const LinearGradient hoopscartGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF7F6F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF2383E2), Color(0xFF1A6BC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final Color appBar = const Color(0xFFFFFFFF);
  static const Color navigationBar = Color(0xFFFFFFFF);
  static final Color overlay = Colors.black.withValues(alpha: 0.4);
  static const Color divider = Color(0xFFE9E9E7);

  static const Color tagRed = Color(0xFFFFE2DD);
  static const Color tagOrange = Color(0xFFFDECC8);
  static const Color tagYellow = Color(0xFFFDECC8);
  static const Color tagGreen = Color(0xFFDBEDDB);
  static const Color tagBlue = Color(0xFFD3E5EF);
  static const Color tagPurple = Color(0xFFE8DEEE);
  static const Color tagPink = Color(0xFFF5E0E9);
  static const Color tagGray = Color(0xFFE9E9E7);

  static const Color tagTextRed = Color(0xFFE03E3E);
  static const Color tagTextOrange = Color(0xFFD9730D);
  static const Color tagTextYellow = Color(0xFFCB912F);
  static const Color tagTextGreen = Color(0xFF0F7B6C);
  static const Color tagTextBlue = Color(0xFF2383E2);
  static const Color tagTextPurple = Color(0xFF9065B0);
  static const Color tagTextPink = Color(0xFFAD1A72);

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static BoxDecoration cardDecoration({
    double borderRadius = 12,
    bool hasBorder = true,
    bool hasElevation = true,
  }) {
    return BoxDecoration(
      color: surfaceElevated,
      borderRadius: BorderRadius.circular(borderRadius),
      border: hasBorder ? Border.all(color: borderDark, width: 1) : null,
      boxShadow: hasElevation
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }
}
