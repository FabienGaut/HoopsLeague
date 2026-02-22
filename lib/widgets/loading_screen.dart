import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo_black.png',
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 20),
            // Nom de l'app - style Notion
            Text(
              "HoopsLeague",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            // Indicateur de chargement - style minimaliste
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
