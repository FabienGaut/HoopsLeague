import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';
import '../utils/no_special_characters_formatter.dart';
import '../utils/error_sanitizer.dart';

final supabase = Supabase.instance.client;

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> changePassword() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    final user = supabase.auth.currentUser;
    if (user == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.userNotConnected), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: user.email!,
        password: oldPasswordController.text.trim(),
      );

      if (authResponse.user == null) {
        throw t.wrongOldPassword;
      }

      if (newPasswordController.text.trim() != confirmPasswordController.text.trim()) {
        throw t.passwordsDoNotMatch;
      }

      await supabase.auth.updateUser(
        UserAttributes(password: newPasswordController.text.trim()),
      );

      messenger.showSnackBar(
        SnackBar(content: Text(t.passwordUpdated), backgroundColor: AppColors.success),
      );

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      final errorMessage = e is String ? e : ErrorSanitizer.getSafeErrorMessage(e, context: 'changement de mot de passe');
      messenger.showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double fieldWidth = ((screenWidth * 0.85).clamp(280, 420)).toDouble();
    final double buttonWidth = ((screenWidth * 0.8).clamp(260, 400)).toDouble();
    final double buttonHeight = ((screenHeight * 0.065).clamp(48, 56)).toDouble();
    final double fontSize = ((screenWidth * 0.04).clamp(14, 16)).toDouble();
    final double spacing = ((screenHeight * 0.025).clamp(12, 20)).toDouble();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Image.asset(AppColors.logoAsset, height: kToolbarHeight * 0.5),
              SizedBox(width: kToolbarHeight * 0.15),
              Text(t.hoopsLeagueTitle, style: TextStyle(color: AppColors.textPrimary, fontSize: kToolbarHeight * 0.38, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.tagBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_reset_outlined, size: 48, color: AppColors.primaryBlue),
                ),
                SizedBox(height: spacing),

                Text(
                  t.changePasswordTitle,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  'Modifiez votre mot de passe',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 14)),
                ),
                SizedBox(height: spacing * 1.5),

                // Form Card
                Container(
                  width: fieldWidth,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark, width: 1),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: oldPasswordController,
                          obscureText: true,
                          inputFormatters: [NoSpecialCharactersFormatter()],
                          style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 15)),
                          decoration: InputDecoration(
                            labelText: t.oldPasswordLabel,
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryBlue, size: 20),
                            filled: true,
                            fillColor: AppColors.surfaceHover,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primaryBlue)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? t.oldPasswordEmpty : null,
                        ),
                        SizedBox(height: spacing),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: true,
                          inputFormatters: [NoSpecialCharactersFormatter()],
                          style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 15)),
                          decoration: InputDecoration(
                            labelText: t.newPasswordLabel,
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.lock_outlined, color: AppColors.primaryBlue, size: 20),
                            filled: true,
                            fillColor: AppColors.surfaceHover,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primaryBlue)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? t.passwordTooShort : null,
                        ),
                        SizedBox(height: spacing),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          inputFormatters: [NoSpecialCharactersFormatter()],
                          style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 15)),
                          decoration: InputDecoration(
                            labelText: t.confirmPasswordLabel,
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.lock_outlined, color: AppColors.primaryBlue, size: 20),
                            filled: true,
                            fillColor: AppColors.surfaceHover,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primaryBlue)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? t.passwordTooShort : null,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing * 1.5),

                // Save Button
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : changePassword,
                    icon: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined, color: Colors.white, size: 20),
                    label: Text(t.save, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: fontSize)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(height: spacing * 2),

                Text(
                  AppLocalizations.of(context)!.allRightsReserved,
                  style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
