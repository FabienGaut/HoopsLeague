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

  // 🎨 Palette cohérente avec LeaderboardPage
  static const Color accentPrimary = Color(0xFF256af4);
  static const Color accentGlow = Color(0xFF9C9CFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final data =
      await supabase.from('usersdata').select().eq('id', widget.uid).single();
      setState(() {
        userData = data;
        _usernameController.text = data['user_name'] ?? '';
        _selectedLang = data['language'] ?? 'fr';
        _selectedOddFormat = data['oddsformat'] ?? 'FR';
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('Erreur chargement utilisateur: $e');
      messenger.showSnackBar(
        SnackBar(
          content:
          Text(t.loadingError(e.toString())),
        ),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserField(String field, dynamic value) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await supabase.from('usersdata').update({field: value}).eq('id', widget.uid);
      messenger.showSnackBar(
        SnackBar(content: Text(t.updateSuccess)),
      );
      await _loadUserData();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
            content:
            Text(t.updateError(e.toString()))),
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

  Widget _glassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          t.manageAccountTitle,
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 🌌 Dégradé violet → noir
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF314368), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.3)),

          SafeArea(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(color: accentPrimary))
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.usernameLabel,
                          style: const TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: TextField(
                            controller: _usernameController,
                            style:
                            const TextStyle(color: textPrimary),
                            decoration: InputDecoration(
                              hintText: t.usernameHint,
                              hintStyle:
                              const TextStyle(color: textSecondary),
                              border: InputBorder.none,
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _updateUserField(
                            'user_name',
                            _usernameController.text.trim(),
                          ),
                          icon: const Icon(Icons.save,
                              color: textPrimary),
                          label: Text(
                            t.saveButton,
                            style:
                            const TextStyle(color: textPrimary),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            accentPrimary.withValues(alpha: 0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.languageLabel,
                          style: const TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLang,
                          items: [
                            DropdownMenuItem(
                              value: 'fr',
                              child: Text(t.french,
                                  style: const TextStyle(
                                      color: textPrimary)),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(t.english,
                                  style: const TextStyle(
                                      color: textPrimary)),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _selectedLang = v);
                            _updateUserField('language', v);
                            appState.setLocale(v);
                          },
                          dropdownColor:
                          Colors.black.withValues(alpha: 0.8),
                          iconEnabledColor: accentGlow,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.oddsFormatLabel,
                          style: const TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedOddFormat,
                          items: [
                            DropdownMenuItem(
                                value: 'FR',
                                child: Text(t.oddsFormatFrench,
                                    style: const TextStyle(
                                        color: textPrimary))),
                            DropdownMenuItem(
                                value: 'US',
                                child: Text(t.oddsFormatUS,
                                    style: const TextStyle(
                                        color: textPrimary))),
                            DropdownMenuItem(
                                value: 'UK',
                                child: Text(t.oddsFormatUK,
                                    style: const TextStyle(
                                        color: textPrimary))),
                          ],
                          onChanged: (v) {
                            setState(() => _selectedOddFormat = v);
                            _updateUserField('oddsformat', v);
                          },
                          dropdownColor:
                          Colors.black.withValues(alpha: 0.8),
                          iconEnabledColor: accentGlow,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _glassCard(
                    child: ListTile(
                      leading: const Icon(Icons.lock_outline,
                          color: accentPrimary),
                      title: Text(
                        t.changePassword,
                        style:
                        const TextStyle(color: textPrimary),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: textPrimary),
                      onTap: _openChangePasswordPage,
                    ),
                  ),

                  _glassCard(
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      title: Text(
                        t.clearCache,
                        style:
                        const TextStyle(color: textPrimary),
                      ),
                      onTap: _clearCache,
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
