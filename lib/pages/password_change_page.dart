import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ChangePasswordPage extends StatefulWidget {
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
    if (!_formKey.currentState!.validate()) return;

    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ Ré-authentifier l’utilisateur avec l’ancien mot de passe
      final authResponse = await supabase.auth.signInWithPassword(
        email: user.email!,
        password: oldPasswordController.text.trim(),
      );

      if (authResponse.user == null) {
        throw 'Ancien mot de passe incorrect';
      }

      // 2️⃣ Vérifier que le nouveau mot de passe correspond à la confirmation
      if (newPasswordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        throw 'Les nouveaux mots de passe ne correspondent pas';
      }

      // 3️⃣ Mettre à jour le mot de passe
      await supabase.auth.updateUser(
        UserAttributes(password: newPasswordController.text.trim()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe mis à jour avec succès')),
      );

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Changer mot de passe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Ancien mot de passe',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Veuillez entrer l’ancien mot de passe' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.length < 6) ? 'Minimum 6 caractères' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le nouveau mot de passe',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.length < 6) ? 'Minimum 6 caractères' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : changePassword,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Changer le mot de passe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
