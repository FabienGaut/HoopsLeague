import 'package:flutter/foundation.dart'; // 👈 pour kIsWeb
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import '../l10n/app_localizations.dart';
import '../theme/utils.dart';

import 'sign_in_page.dart';
import '../utils/no_special_characters_formatter.dart';
import '../utils/error_sanitizer.dart';
import 'legal_document_page.dart';

final supabase = Supabase.instance.client;


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isLoading = false;
  String? _captchaToken;

  // Sélecteur de format de cote
  int selectedIndex = 0;
  final List<String> formats = ['FR', 'US', 'UK'];
  String selectedFormat = 'FR';
  
  // Check if Turnstile is supported on this platform
  bool get _isCaptchaSupported {
    if (kIsWeb) return true;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

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

    // Check if captcha is completed (only on supported platforms)
    if (_isCaptchaSupported && (_captchaToken == null || _captchaToken!.isEmpty)) {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.captchaRequired;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final redirectUrl = kIsWeb
          ? 'https://hoopsleague.fr/#/auth/' // 👈 ton callback web Supabase
          : 'io.hoopsbets.app://login-callback/'; // 👈 ton deep link mobile


      final AuthResponse res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        emailRedirectTo: redirectUrl,
      );

      final user = res.user;
      if (user != null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.accountCreated),
            backgroundColor: Colors.green,
          ),
        );


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        if (e.message.contains('already registered')) {
          errorMessage = AppLocalizations.of(context)!.mailAlreadyUsed;
        } else {
          errorMessage = ErrorSanitizer.getAuthErrorMessage(e);
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = ErrorSanitizer.getSafeErrorMessage(e, context: 'la création du compte');
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildGlassButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required double fontSize,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double logoSize = ((screenWidth * 0.35).clamp(80, 160)).toDouble();
    final double fieldWidth = ((screenWidth * 0.75).clamp(200, 340)).toDouble();
    final double buttonWidth = ((screenWidth * 0.7).clamp(160, 300)).toDouble();
    final double buttonHeight = ((screenHeight * 0.07).clamp(45, 60)).toDouble();
    final double fontSize = ((screenWidth * 0.045).clamp(14, 18)).toDouble();
    final double spacing = ((screenHeight * 0.03).clamp(10, 25)).toDouble();

    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé violet-noir
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF314368), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Effet assombri
          Container(color: Colors.black.withValues(alpha: 0.3)),

          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/logo.png", // ton logo blanc transparent
                    width: logoSize,
                    height: logoSize,
                  ),
                  SizedBox(height: spacing),

                  AutoSizeText(
                    "Join HoopsLeague Today",
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: logScale(context, 24),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: spacing * 1.5),

                  // Conteneur semi-transparent du formulaire
                  Container(
                    width: fieldWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle:
                              TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                              prefixIcon:
                              const Icon(Icons.email, color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Colors.white),
                              ),
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

                          // Mot de passe
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            inputFormatters: [NoSpecialCharactersFormatter()],
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.password,
                              labelStyle:
                              TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                              prefixIcon:
                              const Icon(Icons.lock, color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: spacing),

                          // Confirmation
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            inputFormatters: [NoSpecialCharactersFormatter()],
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText:
                              AppLocalizations.of(context)!.confirmPassword,
                              labelStyle:
                              TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                              prefixIcon:
                              const Icon(Icons.lock, color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Colors.white),
                              ),
                            ),
                            validator: (value) {
                              if (value != passwordController.text) {
                                return AppLocalizations.of(context)!
                                    .confirmPasswordError;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),

                  // Cloudflare Turnstile (only on mobile and web)
                  if (_isCaptchaSupported)
                    Container(
                      width: fieldWidth,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: CloudflareTurnstile(
                        siteKey: dotenv.env['TURNSTILE_SITE_KEY'] ?? '1x00000000000000000000AA',
                        baseUrl: kIsWeb ? 'http://localhost' : 'https://hoopsleague.fr',
                        onTokenReceived: (token) {
                          setState(() {
                            _captchaToken = token;
                            errorMessage = null;
                          });
                        },
                        onError: (error) {
                          setState(() {
                            _captchaToken = null;
                            errorMessage = AppLocalizations.of(context)!.captchaError;
                          });
                        },
                        onTokenExpired: () {
                          setState(() {
                            _captchaToken = null;
                          });
                        },
                      ),
                    ),
                  if (_isCaptchaSupported) SizedBox(height: spacing),

                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  SizedBox(height: spacing),

                  _buildGlassButton(
                    label: AppLocalizations.of(context)!.signUP,
                    icon: Icons.person_add,
                    fontSize: fontSize,
                    width: buttonWidth,
                    height: buttonHeight,
                    onPressed: isLoading ? () {} : signUp,
                  ),

                  SizedBox(height: spacing),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInPage()),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.alreadyHaveAccount,
                      style:  TextStyle(
                        color: Colors.white70,
                        fontSize: logScale(context, 14),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  SizedBox(height: spacing * 2),

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
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: logScale(context, 11),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        '•',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: logScale(context, 11),
                        ),
                      ),
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
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: logScale(context, 11),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        '•',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: logScale(context, 11),
                        ),
                      ),
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
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: logScale(context, 11),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
