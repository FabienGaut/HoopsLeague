import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_required_dialog.dart';
import 'games_page.dart';
import 'home_page.dart';

class GamesPreviewPage extends StatelessWidget {
  const GamesPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo_black.png', height: 28),
            const SizedBox(width: 8),
            Text(
              "HoopsLeague",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Sign In button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              ),
              icon: Icon(Icons.login_outlined, color: AppColors.primaryBlue, size: 18),
              label: Text(
                t.signIn,
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.tagBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: GamesPage(
        uid: null,
        onAuthRequired: () => AuthRequiredDialog.show(context),
      ),
    );
  }
}
