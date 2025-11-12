import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hoopsleague/pages/sign_up_page.dart';
import '../l10n/app_localizations.dart';
import 'first_connection_page.dart';
import 'games_page.dart';

final supabase = Supabase.instance.client;

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;

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

          if (dataResponse != null) {
            final userName = dataResponse['user_name'];
            if (userName == null || userName == "") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) =>  FirstConnectionPage()),
              );
              return;
            }
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) =>  FirstConnectionPage()),
            );
            return;
          }
        } catch (e) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) =>  FirstConnectionPage()),
          );
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GamesPage(uid: user.id)),
        );
      } else {
        setState(() {
          errorMessage = AppLocalizations.of(context)!.noAccountForTheseId;
        });
      }
    } on AuthException catch (e) {
      setState(() {
        if (e.message.contains('Invalid login credentials')) {
          errorMessage = AppLocalizations.of(context)!.wrongPassword;
        } else if (e.message.contains('email')) {
          errorMessage = AppLocalizations.of(context)!.wrongEmail;
        } else {
          errorMessage = 'Error : ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error : $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🔹 Bouton “verre” réutilisable (même que HomePage)
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
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
          // Effet glass
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    width: logoSize,
                    height: logoSize,
                  ),
                  SizedBox(height: spacing),

                  AutoSizeText(
                    "Welcome back to HoopsLeague",
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: spacing * 1.5),

                  // Formulaire dans un container semi-transparent
                  Container(
                    width: fieldWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle:
                              TextStyle(color: Colors.white.withOpacity(0.8)),
                              prefixIcon:
                              const Icon(Icons.email, color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3)),
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

                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText:
                              AppLocalizations.of(context)!.password,
                              labelStyle:
                              TextStyle(color: Colors.white.withOpacity(0.8)),
                              prefixIcon:
                              const Icon(Icons.lock, color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Colors.white),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .enterPassword;
                              }
                              if (value.length < 6) {
                                return AppLocalizations.of(context)!
                                    .passwordTooShort;
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
                    label: AppLocalizations.of(context)!.signIn,
                    icon: Icons.login,
                    fontSize: fontSize,
                    width: buttonWidth,
                    height: buttonHeight,
                    onPressed: isLoading ? () {} : signIn,
                  ),
                  SizedBox(height: spacing),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SignUpPage()),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.createAccount,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing * 2),

                  Text(
                    "© 2025 HoopsLeague. All rights reserved.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
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
