import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hoopsleague/pages/sign_in_page.dart';
import 'package:hoopsleague/pages/sign_up_page.dart';
import '../l10n/app_localizations.dart';
import '../theme/utils.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color accentPrimary = Color(0xFF6A0DAD);
  static const Color textPrimary = Colors.white;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double logoSize = ((screenWidth * 0.35).clamp(80, 180)).toDouble();
    final double buttonWidth = ((screenWidth * 0.7).clamp(160, 300)).toDouble();
    final double buttonHeight = ((screenHeight * 0.07).clamp(45, 60)).toDouble();
    final double titleFontSize = ((screenWidth * 0.08).clamp(22, 32)).toDouble();
    final double buttonFontSize = ((screenWidth * 0.045).clamp(14, 18)).toDouble();
    final double spacing = ((screenHeight * 0.03).clamp(10, 30)).toDouble();

    return Scaffold(
      body: Stack(
        children: [
          // --- Background dégradé moderne ---
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF314368), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // --- Overlay transparent pour effet glass ---
          Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
          // --- Contenu principal ---
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- Logo avec animation simple ---
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut,
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset("assets/images/logo.png"),
                  ),
                  SizedBox(height: spacing),

                  // --- Slogan accrocheur ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: AutoSizeText(
                      "Let's see if you know ball.",
                      maxLines: 2,
                      style: TextStyle(
                        color: textPrimary.withValues(alpha: 0.9),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: spacing * 2),

                  // --- Boutons Sign In / Sign Up ---
                  _buildGlassButton(
                    context,
                    label: AppLocalizations.of(context)!.signIn,
                    icon: Icons.login,
                    width: buttonWidth,
                    height: buttonHeight,
                    fontSize: buttonFontSize,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInPage()),
                    ),
                  ),
                  SizedBox(height: spacing),
                  _buildGlassButton(
                    context,
                    label: AppLocalizations.of(context)!.signUP,
                    icon: Icons.person_add,
                    width: buttonWidth,
                    height: buttonHeight,
                    fontSize: buttonFontSize,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    ),
                  ),
                  SizedBox(height: spacing * 2),

                  // --- Footer petit texte ---
                  Text(
                    "© 2025 HoopsLeague. All rights reserved.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: logScale(context, 12),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required double width,
        required double height,
        required double fontSize,
        required VoidCallback onPressed,
      }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15), // effet glass
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: fontSize * 1.2),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(height / 2)),
        ),
      ),
    );
  }
}
