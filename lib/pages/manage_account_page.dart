import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hoopsleague/pages/password_change_page.dart';
import '../l10n/app_localizations.dart';
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
        SnackBar(content: Text(AppLocalizations.of(context)!.loadingError(e.toString()))),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserField(String field, dynamic value) async {
    try {
      await supabase.from('usersdata').update({field: value}).eq('id', widget.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.updateSuccess)),
      );
      await _loadUserData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.updateError(e.toString()))),
      );
    }
  }

  Future<void> _clearCache() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.cacheCleared)),
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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: Text(t.manageAccountTitle),
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
                  Text(t.usernameLabel,
                      style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: t.usernameHint,
                      hintStyle: const TextStyle(color: textPrimary),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: cardBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _updateUserField('user_name', _usernameController.text.trim()),
                    icon: const Icon(Icons.save, color: textPrimary,),
                    label: Text(t.saveButton, style: TextStyle(color: textPrimary),),
                    style: ElevatedButton.styleFrom(backgroundColor: accentPrimary),
                  ),
                ],
              ),
            ),

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.languageLabel,
                      style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedLang,
                    items: [
                      DropdownMenuItem(value: 'fr', child: Text(t.french)),
                      DropdownMenuItem(value: 'en', child: Text(t.english)),
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
                        borderSide: const BorderSide(color: cardBorder),
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
                  Text(t.oddsFormatLabel,
                      style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedOddFormat,
                    items: [
                      DropdownMenuItem(value: 'FR', child: Text(t.oddsFormatFrench)),
                      DropdownMenuItem(value: 'US', child: Text(t.oddsFormatUS)),
                      DropdownMenuItem(value: 'UK', child: Text(t.oddsFormatUK)),
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
                        borderSide: const BorderSide(color: cardBorder),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildCard(
              child: ListTile(
                leading: const Icon(Icons.lock_outline, color: accentPrimary),
                title: Text(t.changePassword,
                    style: const TextStyle(color: textPrimary)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: textPrimary),
                onTap: _openChangePasswordPage,
              ),
            ),

            _buildCard(
              child: ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(t.clearCache,
                    style: const TextStyle(color: textPrimary)),
                onTap: _clearCache,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
