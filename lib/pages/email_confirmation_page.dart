import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';
import 'sign_in_page.dart';

class EmailConfirmationPage extends StatelessWidget {
  final String email;

  const EmailConfirmationPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double cardWidth = ((screenWidth * 0.85).clamp(300, 500)).toDouble();
    final double buttonWidth = ((screenWidth * 0.7).clamp(200, 300)).toDouble();
    final double buttonHeight = ((screenHeight * 0.065).clamp(48, 56)).toDouble();
    final double fontSize = ((screenWidth * 0.04).clamp(14, 16)).toDouble();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDark, width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.tagGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mark_email_read_outlined, size: 48, color: AppColors.success),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  AppLocalizations.of(context)!.emailConfirmationTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: logScale(context, 22),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  AppLocalizations.of(context)!.emailConfirmationMessage(email),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: logScale(context, 15),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Button
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInPage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_back_outlined, color: Colors.white, size: 20),
                    label: Text(
                      AppLocalizations.of(context)!.backToSignIn,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: fontSize),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
