import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hoopsleague/theme/app_colors.dart';
import 'package:hoopsleague/theme/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hoopsleague/pages/password_change_page.dart';
import 'package:hoopsleague/pages/main_navigation.dart';
import 'package:hoopsleague/pages/home_page.dart';
import 'package:hoopsleague/pages/about_page.dart';
import '../l10n/app_localizations.dart';
import 'app_state.dart';
import 'package:provider/provider.dart';
import '../utils/no_special_characters_formatter.dart';
import '../utils/security_utils.dart';
import 'package:google_fonts/google_fonts.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(t.loadingError(t.unauthorizedAccess))));
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final data = await supabase.from('usersdata').select().eq('id', widget.uid).single();
      if (!mounted) return;
      setState(() {
        userData = data;
        _usernameController.text = data['user_name'] ?? '';
        _selectedLang = data['language'] ?? 'fr';
        _selectedOddFormat = data['oddsformat'] ?? 'FR';
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('Erreur chargement utilisateur: $e');
      messenger.showSnackBar(SnackBar(content: Text(t.loadingError(e.toString()))));
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserField(String field, dynamic value) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(t.updateError(t.unauthorizedAccess))));
      return;
    }

    try {
      await supabase.from('usersdata').update({field: value}).eq('id', widget.uid);
      messenger.showSnackBar(SnackBar(content: Text(t.updateSuccess), backgroundColor: AppColors.success));
      await _loadUserData();
      if (mounted) context.read<AppState>().refreshUserData();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(t.updateError(e.toString()))));
    }
  }

  void _openChangePasswordPage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordPage()));
  }

  void _openBugReportPage() {
    MainNavigation.of(context)?.showBugReportPage();
  }

  void _openAboutPage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
  }

  Future<void> _logout() async {
    final t = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(t.logoutTitle, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        content: Text(t.logoutConfirmation, style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.cancel, style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, elevation: 0),
            child: Text(t.logout, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.logoutSuccess), backgroundColor: AppColors.success, duration: const Duration(seconds: 2)),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.logoutError(e.toString())), backgroundColor: AppColors.error, duration: const Duration(seconds: 3)),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final t = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning_outlined, color: AppColors.error, size: 24),
            const SizedBox(width: 12),
            Text(t.deleteAccountTitle, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(t.deleteAccountWarning, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel, style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, elevation: 0),
            child: Text(t.deleteAccount, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final finalConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(t.areYouSure, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        content: Text(t.deleteAccountFinalWarning, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel, style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, elevation: 0),
            child: Text(t.deleteAccountPermanently, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (finalConfirm != true) return;

    try {
      SecurityUtils.requireCurrentUser(widget.uid);
      await supabase.rpc('delete_user_account');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.accountDeletedSuccess), backgroundColor: AppColors.success, duration: const Duration(seconds: 3)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.deleteAccountError(e.toString())), backgroundColor: AppColors.error, duration: const Duration(seconds: 4)),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.tagBlue, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primaryBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 16), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow({required IconData icon, required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 13), fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildEmojiRow(BuildContext context, String? emoji, String label, {bool isTank = false, bool isLast = false}) {
    final double emojiSize = logScale(context, 22);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Center(
              child: isTank
                  ? Image.asset('assets/images/tank.png', width: emojiSize, height: emojiSize, fit: BoxFit.contain)
                  : Text(
                      emoji!,
                      style: TextStyle(fontSize: emojiSize, fontFamily: GoogleFonts.notoColorEmoji().fontFamily),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 13)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Image.asset('assets/images/logo_black.png', height: kToolbarHeight * 0.5),
              SizedBox(width: kToolbarHeight * 0.15),
              Text(t.manageAccount, style: TextStyle(color: AppColors.textPrimary, fontSize: kToolbarHeight * 0.38, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    _sectionHeader(Icons.person_outlined, t.usernameLabel),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.badge_outlined, color: AppColors.primaryBlue, size: 18),
                              const SizedBox(width: 8),
                              Text(t.usernameLabel, style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 13), fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _usernameController,
                            maxLength: 20,
                            inputFormatters: [NoSpecialCharactersFormatter()],
                            style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 16)),
                            decoration: InputDecoration(
                              hintText: t.usernameHint,
                              hintStyle: TextStyle(color: AppColors.textTertiary),
                              filled: true,
                              fillColor: AppColors.surfaceHover,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primaryBlue)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _updateUserField('user_name', _usernameController.text.trim()),
                              icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
                              label: Text(t.saveButton, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Preferences Section
                    _sectionHeader(Icons.tune_outlined, 'Preferences'),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildPreferenceRow(
                            icon: Icons.language_outlined,
                            label: t.languageLabel,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedLang,
                              items: [
                                DropdownMenuItem(value: 'fr', child: Text(t.french, style: TextStyle(color: AppColors.textPrimary))),
                                DropdownMenuItem(value: 'en', child: Text(t.english, style: TextStyle(color: AppColors.textPrimary))),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _selectedLang = v);
                                _updateUserField('language', v);
                                context.read<AppState>().setLocale(v);
                              },
                              dropdownColor: AppColors.surfaceElevated,
                              iconEnabledColor: AppColors.primaryBlue,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surfaceHover,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          Divider(color: AppColors.borderDark, height: 32),
                          _buildPreferenceRow(
                            icon: Icons.show_chart_outlined,
                            label: t.oddsFormatLabel,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedOddFormat,
                              items: [
                                DropdownMenuItem(value: 'FR', child: Text(t.oddsFormatFrench, style: TextStyle(color: AppColors.textPrimary))),
                                DropdownMenuItem(value: 'US', child: Text(t.oddsFormatUS, style: TextStyle(color: AppColors.textPrimary))),
                                DropdownMenuItem(value: 'UK', child: Text(t.oddsFormatUK, style: TextStyle(color: AppColors.textPrimary))),
                              ],
                              onChanged: (v) {
                                setState(() => _selectedOddFormat = v);
                                _updateUserField('oddsformat', v);
                              },
                              dropdownColor: AppColors.surfaceElevated,
                              iconEnabledColor: AppColors.primaryBlue,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surfaceHover,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Emoji Legend Section
                    _sectionHeader(Icons.emoji_emotions_outlined, t.emojiLegendTitle),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.emojiLegendSubtitle,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 12)),
                          ),
                          const SizedBox(height: 12),
                          _buildEmojiRow(context, null, t.emojiTank, isTank: true),
                          _buildEmojiRow(context, '\u{1F4A3}', t.emojiBomb),
                          _buildEmojiRow(context, '\u{1F976}', t.emojiCold),
                          _buildEmojiRow(context, '\u{1F525}', t.emojiFire),
                          _buildEmojiRow(context, '\u{1F947}', t.emojiGold),
                          _buildEmojiRow(context, '\u{1F948}', t.emojiSilver),
                          _buildEmojiRow(context, '\u{1F949}', t.emojiBronze),
                          _buildEmojiRow(context, '\u{1F3E5}', t.emojiHospital),
                          _buildEmojiRow(context, '\u{1F3C0}', t.emojiDefault, isLast: true),
                        ],
                      ),
                    ),

                    // Security Section
                    _sectionHeader(Icons.security_outlined, 'Security'),
                    _buildCard(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.tagBlue, borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.lock_outline, color: AppColors.primaryBlue, size: 20),
                            ),
                            title: Text(t.changePassword, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
                            onTap: _openChangePasswordPage,
                          ),
                          Divider(color: AppColors.borderDark, height: 8),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.tagOrange, borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.logout_outlined, color: AppColors.warning, size: 20),
                            ),
                            title: Text(t.logout, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),

                    // Support Section
                    _sectionHeader(Icons.support_outlined, 'Support & Actions'),
                    _buildCard(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.tagOrange, borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.bug_report_outlined, color: AppColors.warning, size: 20),
                            ),
                            title: Text(t.bugReport, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
                            onTap: _openBugReportPage,
                          ),
                          Divider(color: AppColors.borderDark, height: 8),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.tagBlue, borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
                            ),
                            title: Text(t.about, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
                            onTap: _openAboutPage,
                          ),
                        ],
                      ),
                    ),

                    // Danger Zone
                    _sectionHeader(Icons.warning_outlined, 'Danger Zone'),
                    _buildCard(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.tagRed, borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.delete_forever_outlined, color: AppColors.error, size: 20),
                        ),
                        title: Text(t.deleteAccount, style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
                        subtitle: Text('Action irréversible', style: TextStyle(color: AppColors.error.withValues(alpha: 0.6), fontSize: logScale(context, 12))),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.error),
                        onTap: _deleteAccount,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
