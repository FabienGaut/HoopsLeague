import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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
          const SnackBar(
            content: Text('Account created successfully!'),
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
        if (e.code == 'email-already-in-use') errorMessage = 'Email déjà utilisé';
        else if (e.code == 'weak-password') errorMessage = 'Mot de passe trop faible';
        else if (e.code == 'invalid-email') errorMessage = 'Email invalide';
        else errorMessage = 'Erreur: ${e.code}';
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
                        return 'Please enter your e-mail';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Email incorrect';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // 🧩 Champ Mot de passe
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please type your password';
                      }
                      if (value.length < 6) {
                        return 'The password must be longer than 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // 🧩 Champ Confirmation
                  TextFormField(
                    controller: confirmController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm your password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return "The passwords aren't the same";
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
                    child: const Text(
                      'Sign Up',
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
