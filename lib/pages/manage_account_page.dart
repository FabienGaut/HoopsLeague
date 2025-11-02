import 'package:HoopsBets/pages/password_change_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:HoopsBets/pages/password_change_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_state.dart';


final supabase = Supabase.instance.client;

class ManageAccountPage extends StatefulWidget {
  final String uid;

  const ManageAccountPage({super.key, required this.uid});

  @override
  State<ManageAccountPage> createState() => _ManageAccountPageState();
}

class _ManageAccountPageState extends State<ManageAccountPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final _usernameController = TextEditingController();
  String? _selectedLang;
  String? _selectedOddFormat;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await supabase.from('usersdata').select().eq('id', widget.uid).single();
      setState(() {
        userData = data;
        _usernameController.text = data['user_name'] ?? '';
        _selectedLang = data['language'] ?? 'fr';
        _selectedOddFormat = data['oddsformat'] ?? 'FR';
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('Erreur chargement utilisateur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserField(String field, dynamic value) async {
    try {
      await supabase.from('usersdata').update({field: value}).eq('id', widget.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modification enregistrée')),
      );
      await _loadUserData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur mise à jour: $e')),
      );
    }
  }

  Future<void> _clearCache() async {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache vidé avec succès')),
    );
  }

  void _openChangePasswordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChangePasswordPage()),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gérer mon compte')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Username field ---
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d’utilisateur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _updateUserField('user_name', _usernameController.text.trim()),
              icon: const Icon(Icons.save),
              label: const Text('Sauvegarder le nom'),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // --- Langue ---
            const Text('Langue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLang,
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedLang = v);
                _updateUserField('language', v);
                appState.setLocale(v); // <-- met à jour immédiatement la langue globale
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),


            const SizedBox(height: 24),
            const Divider(),

            // --- Format des cotes ---
            const Text('Format des cotes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedOddFormat,
              items: const [
                DropdownMenuItem(value: 'FR', child: Text('Français (décimal)')),
                DropdownMenuItem(value: 'US', child: Text('Américain')),
                DropdownMenuItem(value: 'UK', child: Text('Fractionnel')),
              ],
              onChanged: (v) {
                setState(() => _selectedOddFormat = v);
                _updateUserField('oddsformat', v);
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // --- Bouton changer mot de passe ---
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Changer le mot de passe'),
              onTap: _openChangePasswordPage,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),

            const Divider(),

            // --- Bouton vider le cache ---
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Vider le cache local'),
              onTap: _clearCache,
            ),
          ],
        ),
      ),
    );
  }
}
