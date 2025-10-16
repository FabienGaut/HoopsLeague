import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../l10n/app_localizations.dart';
import 'games_page.dart';
import 'home_page.dart';

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
    super.dispose();
    passwordController.dispose();
    emailController.dispose();
  }

  Future<void> signIn() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      // ✅ Authentification Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // ✅ Si tout est OK → navigation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GamesPage(uid: userCredential.user!.uid)),
      );
    } on FirebaseAuthException catch (e) {
      // ⚠️ Gestion des erreurs courantes
      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage =  AppLocalizations.of(context)!.noAccountForTheseId;
        } else if (e.code == 'wrong-password') {
          errorMessage =  AppLocalizations.of(context)!.wrongPassword;
        } else if (e.code == 'invalid-email') {
          errorMessage =  AppLocalizations.of(context)!.wrongEmail;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
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
                        return  AppLocalizations.of(context)!.enterEmail;
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return  AppLocalizations.of(context)!.wrongEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Mot de passe
                  TextFormField(
                    controller: passwordController,
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return  AppLocalizations.of(context)!.enterPassword;
                      }
                      if (value.length < 6) {
                        return  AppLocalizations.of(context)!.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(padding: EdgeInsets.all(5)),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Bouton Sign In
                  ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child:  Text(
                      AppLocalizations.of(context)!.signIn,
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔸 Lien vers la page d’inscription
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpPage()),
                      );
                      FocusScope.of(context).requestFocus((FocusNode()));
                    },
                    child:  Text(
                      AppLocalizations.of(context)!.createAccount,
                      style: TextStyle(color: Colors.blue),
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