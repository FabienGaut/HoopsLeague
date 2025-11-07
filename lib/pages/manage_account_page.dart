import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:HoopsBets/pages/password_change_page.dart';
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

  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color accentPrimary = Colors.deepPurple;
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);

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

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text('Gérer mon compte'),
        backgroundColor: cardBg,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: accentPrimary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nom d’utilisateur', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nom d’utilisateur',
                      hintStyle: TextStyle(color: textSecondary),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cardBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _updateUserField('user_name', _usernameController.text.trim()),
                    icon: const Icon(Icons.save),
                    label: const Text('Sauvegarder'),
                    style: ElevatedButton.styleFrom(backgroundColor: accentPrimary),
                  ),
                ],
              ),
            ),

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Langue', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
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
                      appState.setLocale(v);
                    },
                    dropdownColor: cardBg,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cardBorder),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Format des cotes', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
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
                    dropdownColor: cardBg,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cardBorder),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildCard(
              child: ListTile(
                leading: const Icon(Icons.lock_outline, color: accentPrimary),
                title: const Text('Changer le mot de passe', style: TextStyle(color: textPrimary)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: textSecondary),
                onTap: _openChangePasswordPage,
              ),
            ),

            _buildCard(
              child: ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Vider le cache local', style: TextStyle(color: textPrimary)),
                onTap: _clearCache,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
