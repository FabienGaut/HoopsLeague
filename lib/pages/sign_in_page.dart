import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hoopsleague/pages/sign_up_page.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';
import 'first_connection_page.dart';
import 'main_navigation.dart';
import '../utils/no_special_characters_formatter.dart';
import '../utils/error_sanitizer.dart';
import 'legal_document_page.dart';

final supabase = Supabase.instance.client;

class SignInPage extends StatefulWidget {
  final bool emailConfirmed;

  const SignInPage({super.key, this.emailConfirmed = false});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen(_handleAuthStateChange);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthStateChange(AuthState data) async {
    if (!mounted) return;
    if (data.event == AuthChangeEvent.signedIn && data.session != null) {
      final user = data.session!.user;
      try {
        final userData = await supabase
            .from('usersdata')
            .select('user_name')
            .eq('id', user.id)
            .maybeSingle();

        if (!mounted) return;
        if (userData != null && userData['user_name'] != null && userData['user_name'].toString().isNotEmpty) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNavigation(uid: user.id)));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FirstConnectionPage()));
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FirstConnectionPage()));
      }
    }
  }

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = response.user;
      if (user != null) {
        try {
          final dataResponse = await supabase
              .from('usersdata')
              .select()
              .eq('id', user.id)
              .single();

          if (!mounted) return;

          final userName = dataResponse['user_name'];
          if (userName == null || userName == "") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => FirstConnectionPage()),
            );
            return;
          }
        } catch (e) {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => FirstConnectionPage()),
          );
          return;
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigation(uid: user.id)),
        );
      } else {
        if (!mounted) return;

        setState(() {
          errorMessage = AppLocalizations.of(context)!.noAccountForTheseId;
        });
      }
    } on AuthException catch (e) {
      setState(() {
        errorMessage = ErrorSanitizer.getAuthErrorMessage(e);
      });
    } catch (e) {
      setState(() {
        errorMessage = ErrorSanitizer.getSafeErrorMessage(e, context: 'la connexion');
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
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
      // signInWithOAuth ouvre le navigateur et retourne immédiatement.
      // La navigation se fait via _handleAuthStateChange.
      if (mounted) setState(() => isLoading = false);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = ErrorSanitizer.getAuthErrorMessage(e);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = ErrorSanitizer.getSafeErrorMessage(e, context: 'la connexion avec Google');
        isLoading = false;
      });
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final t = AppLocalizations.of(context)!;
    final emailResetController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        bool isSending = false;
        String? dialogError;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(
                t.resetPasswordTitle,
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.resetPasswordInstructions,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailResetController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryBlue),
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
                    ),
                  ),
                  if (dialogError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(dialogError!, style: TextStyle(color: AppColors.error)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(context),
                  child: Text(t.cancel, style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          final email = emailResetController.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            setState(() {
                              dialogError = t.wrongEmail;
                            });
                            return;
                          }

                          setState(() {
                            isSending = true;
                            dialogError = null;
                          });

                          try {
                            final redirectUrl = kIsWeb
                                ? 'https://hoopsleague.fr'
                                : 'io.hoopsleague.app://reset-password/';

                            await supabase.auth.resetPasswordForEmail(
                              email,
                              redirectTo: redirectUrl,
                            );

                            if (!context.mounted) return;

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t.resetEmailSent),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              dialogError = t.resetEmailError;
                              isSending = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, elevation: 0),
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(t.sendResetLink, style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
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
                  AppLocalizations.of(context)!.welcomeBack,
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
                  'Connectez-vous pour continuer',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 14)),
                ),
                SizedBox(height: spacing),

                if (widget.emailConfirmed)
                  Container(
                    width: fieldWidth,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.tagGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.emailConfirmationTitle,
                            style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: spacing * 0.5),

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
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: [NoSpecialCharactersFormatter()],
                          style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 15)),
                          decoration: InputDecoration(
                            labelText: 'Email',
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.enterPassword;
                            }
                            if (value.length < 6) {
                              return AppLocalizations.of(context)!.passwordTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            child: Text(
                              AppLocalizations.of(context)!.forgotPassword,
                              style: TextStyle(color: AppColors.primaryBlue, fontSize: logScale(context, 13)),
                            ),
                          ),
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

                // Sign In Button
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : signIn,
                    icon: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.login_outlined, color: Colors.white, size: 20),
                    label: Text(
                      AppLocalizations.of(context)!.signIn,
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

                // Google Sign-In Button
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : signInWithGoogle,
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata, color: Color(0xFF4285F4), size: 20);
                      },
                    ),
                    label: Text(
                      'Se connecter avec Google',
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
                      MaterialPageRoute(
                          builder: (_) => SignUpPage(
                                refreshKey: DateTime.now().millisecondsSinceEpoch.toString(),
                              )),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Pas encore de compte ? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 14)),
                      children: [
                        TextSpan(
                          text: 'Créer un compte',
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
