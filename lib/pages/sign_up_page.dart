import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:HoopsBets/pages/sign_in_page.dart';
import '../l10n/app_localizations.dart';

final supabase = Supabase.instance.client;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isLoading = false;

  // Sélecteur de format de cote
  int selectedIndex = 0;
  final List<String> formats = ['FR', 'US', 'UK'];
  String selectedFormat = 'FR';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final redirectUrl = Platform.isAndroid || Platform.isIOS
          ? 'io.hoopsbets.app://login-callback/'
          : 'http://localhost:3000';

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

        // 👉 Ici tu pourrais aussi sauvegarder le format choisi dans Supabase si tu veux
        print("Format de cote choisi : $selectedFormat");

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
          errorMessage = 'Erreur: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur inattendue: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 0.5,
                    child: Image.asset("assets/images/logo.jpeg"),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'ex: example@gmail.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
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

                  const SizedBox(height: 12),

                  // Mot de passe
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),

                  const SizedBox(height: 12),

                  // Confirmation mot de passe
                  TextFormField(
                    controller: confirmController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.confirmPassword,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return AppLocalizations.of(context)!.confirmPasswordError;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  ElevatedButton(
                    onPressed: isLoading ? null : signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      AppLocalizations.of(context)!.signUP,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
