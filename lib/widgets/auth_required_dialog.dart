import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';
import '../pages/sign_in_page.dart';
import '../pages/sign_up_page.dart';

class AuthRequiredDialog extends StatelessWidget {
  const AuthRequiredDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const AuthRequiredDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.tagBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lock_outline, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.authRequiredTitle,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: logScale(context, 18),
              ),
            ),
          ),
        ],
      ),
      content: Text(
        t.authRequiredMessage,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: logScale(context, 14),
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            t.cancel,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignInPage()),
            );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primaryBlue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            t.signIn,
            style: TextStyle(color: AppColors.primaryBlue),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SignUpPage(
                  refreshKey: DateTime.now().millisecondsSinceEpoch.toString(),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            t.signUP,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
