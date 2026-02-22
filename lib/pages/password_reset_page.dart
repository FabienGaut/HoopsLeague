import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';
import '../utils/no_special_characters_formatter.dart';
import 'sign_in_page.dart';

final supabase = Supabase.instance.client;

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    if (newPasswordController.text.trim() != confirmPasswordController.text.trim()) {
      setState(() {
        errorMessage = t.passwordsDoNotMatch;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPasswordController.text.trim()),
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(t.passwordResetSuccess),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      final errorMsg = e.message.toLowerCase();
      setState(() {
        if (errorMsg.contains('same_password') || errorMsg.contains('same password')) {
          errorMessage = t.samePasswordError;
        } else {
          errorMessage = t.passwordResetError;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = t.passwordResetError;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double logoSize = ((screenWidth * 0.25).clamp(60, 120)).toDouble();
    final double fieldWidth = ((screenWidth * 0.85).clamp(280, 400)).toDouble();
    final double buttonWidth = ((screenWidth * 0.7).clamp(160, 300)).toDouble();
    final double buttonHeight = ((screenHeight * 0.07).clamp(45, 60)).toDouble();
    final double fontSize = ((screenWidth * 0.045).clamp(14, 18)).toDouble();
    final double spacing = ((screenHeight * 0.03).clamp(10, 25)).toDouble();

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
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo_black.png", width: logoSize, height: logoSize),
                SizedBox(height: spacing),

                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.tagBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_reset_outlined, color: AppColors.primaryBlue, size: 30),
                ),
                SizedBox(height: spacing),

                Text(
                  t.resetPasswordPageTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: logScale(context, 24),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: spacing / 2),

                Text(
                  t.resetPasswordPageInstructions,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: logScale(context, 14),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: spacing * 1.5),

                Container(
                  width: fieldWidth,
                  padding: const EdgeInsets.all(20),
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
                          controller: newPasswordController,
                          obscureText: true,
                          inputFormatters: [NoSpecialCharactersFormatter()],
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: t.newPassword,
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.lock_outlined, color: AppColors.textTertiary),
                            filled: true,
                            fillColor: AppColors.surfaceHover,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.borderDark),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.primaryBlue),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.error),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.error),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? t.passwordTooShort : null,
                        ),
                        SizedBox(height: spacing),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          inputFormatters: [NoSpecialCharactersFormatter()],
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: t.confirmNewPassword,
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.lock_outlined, color: AppColors.textTertiary),
                            filled: true,
                            fillColor: AppColors.surfaceHover,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.borderDark),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.primaryBlue),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.error),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.error),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? t.passwordTooShort : null,
                        ),
                      ],
                    ),
                  ),
                ),

                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.tagRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: AppColors.error, fontSize: logScale(context, 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: spacing * 1.5),

                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : resetPassword,
                    icon: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.check_outlined, color: Colors.white, size: 20),
                    label: Text(
                      t.setNewPassword,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: fontSize,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),

                SizedBox(height: spacing),

                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInPage()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    t.backToLogin,
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: logScale(context, 14),
                    ),
                  ),
                ),

                SizedBox(height: spacing * 2),

                Text(
                  "© 2025 HoopsLeague",
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: logScale(context, 12),
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
