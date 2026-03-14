import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';

import 'sign_in_page.dart';
import '../utils/no_special_characters_formatter.dart';
import '../utils/error_sanitizer.dart';
import 'legal_document_page.dart';
import 'email_confirmation_page.dart';

final supabase = Supabase.instance.client;

class SignUpPage extends StatefulWidget {
  final String? refreshKey;

  const SignUpPage({super.key, this.refreshKey});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isLoading = false;

  int selectedIndex = 0;
  final List<String> formats = ['FR', 'US', 'UK'];
  String selectedFormat = 'FR';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final redirectUrl = kIsWeb
          ? 'https://hoopsleague.fr/auth/callback'
          : 'io.hoopsleague.app://login-callback/';

      final AuthResponse res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        emailRedirectTo: redirectUrl,
      );

      final user = res.user;
      if (user != null) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailConfirmationPage(email: user.email ?? ''),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        final lowerMessage = e.message.toLowerCase();
        if (lowerMessage.contains('already registered') ||
            lowerMessage.contains('already in use') ||
            lowerMessage.contains('already exists') ||
            lowerMessage.contains('user already registered') ||
            lowerMessage.contains('email_exists') ||
            lowerMessage.contains('duplicate') ||
            lowerMessage.contains('taken') ||
            e.statusCode == '23505' ||
            e.code == 'email_exists' ||
            e.code == 'user_already_exists') {
          errorMessage = AppLocalizations.of(context)!.mailAlreadyUsed;
        } else {
          errorMessage = e.message.isNotEmpty ? e.message : ErrorSanitizer.getAuthErrorMessage(e);
        }
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = ErrorSanitizer.getSafeErrorMessage(e, context: 'la création du compte');
        isLoading = false;
      });
    }
  }

  Future<void> signUpWithGoogle() async {
    if (!mounted) return;
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final redirectUrl = kIsWeb
          ? 'https://hoopsleague.fr/auth/callback'
          : 'io.hoopsleague.app://login-callback/';

      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = ErrorSanitizer.getAuthErrorMessage(e);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = ErrorSanitizer.getSafeErrorMessage(e, context: 'l\'inscription avec Google');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double logoSize = ((screenWidth * 0.3).clamp(70, 140)).toDouble();
    final double fieldWidth = ((screenWidth * 0.85).clamp(280, 420)).toDouble();
    final double buttonWidth = ((screenWidth * 0.8).clamp(260, 400)).toDouble();
    final double buttonHeight = ((screenHeight * 0.065).clamp(48, 56)).toDouble();
    final double fontSize = ((screenWidth * 0.04).clamp(14, 16)).toDouble();
    final double spacing = ((screenHeight * 0.025).clamp(12, 20)).toDouble();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Image.asset(AppColors.logoAsset, width: logoSize, height: logoSize),
                SizedBox(height: spacing),

                AutoSizeText(
                  "Rejoignez HoopsLeague",
                  maxLines: 1,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  'Créez votre compte pour commencer',
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
                        // Email
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: [NoSpecialCharactersFormatter()],
                          style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 15)),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.email,
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryBlue, size: 20),
                            filled: true,
                            fillColor: AppColors.surfaceHover,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primaryBlue)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.enterEmail;
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return AppLocalizations.of(context)!.wrongEmail;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: spacing),

                        // Password
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          inputFormatters: [NoSpecialCharactersFormatter()],
                          style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 15)),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password,
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.lock_outlined, color: AppColors.primaryBlue, size: 20),
                            filled: true,
                            fillColor: AppColors.surfaceHover,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primaryBlue)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        SizedBox(height: spacing),

                        // Confirm Password
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          inputFormatters: [NoSpecialCharactersFormatter()],
                          style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 15)),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.confirmPassword,
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.lock_outlined, color: AppColors.primaryBlue, size: 20),
                            filled: true,
                            fillColor: AppColors.surfaceHover,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primaryBlue)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (value) {
                            if (value != passwordController.text) {
                              return AppLocalizations.of(context)!.confirmPasswordError;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing),

                if (errorMessage != null)
                  Container(
                    width: fieldWidth,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.tagRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(errorMessage!, style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                if (errorMessage != null) SizedBox(height: spacing),

                // Sign Up Button
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : signUp,
                    icon: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.person_add_outlined, color: Colors.white, size: 20),
                    label: Text(
                      AppLocalizations.of(context)!.signUP,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: fontSize),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(height: spacing),

                // Separator "or"
                SizedBox(
                  width: buttonWidth,
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.borderDark, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('ou', style: TextStyle(color: AppColors.textTertiary, fontSize: fontSize * 0.9)),
                      ),
                      Expanded(child: Divider(color: AppColors.borderDark, thickness: 1)),
                    ],
                  ),
                ),
                SizedBox(height: spacing),

                // Google Sign-Up Button
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : signUpWithGoogle,
                    icon: Image.asset(
                      'assets/images/google_logo_black.png',
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata, color: Color(0xFF4285F4), size: 20);
                      },
                    ),
                    label: Text(
                      'S\'inscrire avec Google',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: fontSize * 0.9),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceDark,
                      side: BorderSide(color: AppColors.borderDark),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(height: spacing * 1.5),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInPage()),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Déjà un compte ? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 14)),
                      children: [
                        TextSpan(
                          text: 'Se connecter',
                          style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing),

                // Legal links
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LegalDocumentPage(
                              documentPath: 'assets/legal_docs/cgu.md',
                              title: AppLocalizations.of(context)!.termsAndConditions,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.termsAndConditions,
                        style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 11)),
                      ),
                    ),
                    Text('•', style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 11))),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LegalDocumentPage(
                              documentPath: 'assets/legal_docs/privacy_policy.md',
                              title: AppLocalizations.of(context)!.privacyPolicy,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.privacyPolicy,
                        style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 11)),
                      ),
                    ),
                    Text('•', style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 11))),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LegalDocumentPage(
                              documentPath: 'assets/legal_docs/mentions_legales.md',
                              title: AppLocalizations.of(context)!.legalNotice,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.legalNotice,
                        style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 11)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
