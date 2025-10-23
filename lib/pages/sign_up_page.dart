import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:HoopsBets/pages/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../l10n/app_localizations.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 🔹 Les contrôleurs pour récupérer les valeurs des champs
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  // 🔹 Clé du formulaire pour valider
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {

    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();

  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => errorMessage = null); // si tu veux afficher les erreurs
    setState(() => isLoading = true);

    try {
      // 1️⃣ Créer l’utilisateur avec Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

      User? user = userCredential.user;

      if (user != null) {
        // 2️⃣ Ajouter les infos dans Firestore
        await FirebaseFirestore.instance
            .collection('UserData')
            .doc(user.uid)
            .set({
          'user_name': '',
          'email': user.email,
          'role': 'user',
          'points': 100,
          'timezone': 'Paris',
          'subscription_date': DateTime.now(),
          'status': 'active',
          'passed_bets': [],
          'daily_points_used': false,
          'current_bets': []
        });

        // 3️⃣ Message et navigation
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
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') errorMessage =  AppLocalizations.of(context)!.mailAlreadyUsed;
        else if (e.code == 'weak-password') errorMessage =  AppLocalizations.of(context)!.weakPassword;
        else if (e.code == 'invalid-email') errorMessage =  AppLocalizations.of(context)!.wrongEmail;
        else errorMessage = 'Error: ${e.code}';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

      ),
      body: Center(
        child: SingleChildScrollView( // 👈 permet de scroller si le clavier dépasse
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey, // lie le formulaire à la clé
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 0.5,
                    child: Image.asset("assets/images/logo.jpeg"),
                  ),
                  // 🧩 Champ Email
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
                  // 🧩 Champ Mot de passe
                  TextFormField(
                    controller: passwordController,
                    decoration:  InputDecoration(
                      labelText:  AppLocalizations.of(context)!.password,
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
                  const SizedBox(height: 12),
                  // 🧩 Champ Confirmation
                  TextFormField(
                    controller: confirmController,
                    decoration:  InputDecoration(
                      labelText:  AppLocalizations.of(context)!.confirmPassword,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return  AppLocalizations.of(context)!.confirmPasswordError;
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

                  // 🧠 Bouton d’inscription
                  ElevatedButton(
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child:  Text(
                      AppLocalizations.of(context)!.signUP,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
