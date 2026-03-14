import 'package:flutter/material.dart';

class AppColors {
  static bool isDarkMode = false;

  // Logo asset based on theme
  static String get logoAsset => isDarkMode ? 'assets/images/logo.png' : 'assets/images/logo_black.png';

  static Color get backgroundDark => isDarkMode ? const Color(0xFF191919) : const Color(0xFFFFFFFF);
  static Color get surfaceDark => isDarkMode ? const Color(0xFF222222) : const Color(0xFFF7F6F3);
  static Color get surfaceElevated => isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF);
  static Color get surfaceHover => isDarkMode ? const Color(0xFF333333) : const Color(0xFFEFEFEF);

  static Color get textPrimary => isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF37352F);
  static Color get textSecondary => isDarkMode ? const Color(0xFF9B9B9B) : const Color(0xFF787774);
  static Color get textTertiary => isDarkMode ? const Color(0xFF666666) : const Color(0xFFA5A5A3);
  static const Color textOnAccent = Colors.white;

  static Color primaryBlue = const Color(0xFF2383E2);
  static const Color accentPrimary = Color(0xFF2383E2);
  static const Color accentSecondary = Color(0xFF9065B0);
  static const Color accentTertiary = Color(0xFFD9730D);

  static Color get borderDark => isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE9E9E7);
  static Color get borderLight => isDarkMode ? const Color(0xFF2F2F2F) : const Color(0xFFF1F1EF);
  static const Color borderFocus = Color(0xFF2383E2);

  static const Color success = Color(0xFF0F7B6C);
  static const Color error = Color(0xFFE03E3E);
  static const Color warning = Color(0xFFD9730D);
  static const Color info = Color(0xFF529CCA);

  static Color get gradientStart => isDarkMode ? const Color(0xFF191919) : const Color(0xFFFFFFFF);
  static Color get gradientEnd => isDarkMode ? const Color(0xFF222222) : const Color(0xFFF7F6F3);

  static LinearGradient get hoopscartGradient => LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF2383E2), Color(0xFF1A6BC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color get appBar => isDarkMode ? const Color(0xFF191919) : const Color(0xFFFFFFFF);
  static Color get navigationBar => isDarkMode ? const Color(0xFF191919) : const Color(0xFFFFFFFF);
  static final Color overlay = Colors.black.withValues(alpha: 0.4);
  static Color get divider => isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE9E9E7);

  static Color get tagRed => isDarkMode ? const Color(0xFF3D2020) : const Color(0xFFFFE2DD);
  static Color get tagOrange => isDarkMode ? const Color(0xFF3D2E14) : const Color(0xFFFDECC8);
  static Color get tagYellow => isDarkMode ? const Color(0xFF3D2E14) : const Color(0xFFFDECC8);
  static Color get tagGreen => isDarkMode ? const Color(0xFF1C3326) : const Color(0xFFDBEDDB);
  static Color get tagBlue => isDarkMode ? const Color(0xFF1A2E3D) : const Color(0xFFD3E5EF);
  static Color get tagPurple => isDarkMode ? const Color(0xFF2D2040) : const Color(0xFFE8DEEE);
  static Color get tagPink => isDarkMode ? const Color(0xFF3D1A2E) : const Color(0xFFF5E0E9);
  static Color get tagGray => isDarkMode ? const Color(0xFF333333) : const Color(0xFFE9E9E7);

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
                color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }
}
