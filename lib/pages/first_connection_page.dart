import 'package:flutter/material.dart';
import 'package:hoopsleague/services/clock.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import 'main_navigation.dart';
import '../utils/no_special_characters_formatter.dart';
import 'package:hoopsleague/theme/app_colors.dart';
import 'package:hoopsleague/theme/utils.dart';

final supabase = Supabase.instance.client;

class FirstConnectionPage extends StatefulWidget {
  const FirstConnectionPage({super.key});

  @override
  FirstConnectionPageState createState() => FirstConnectionPageState();
}

class FirstConnectionPageState extends State<FirstConnectionPage> {
  final _formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  List<bool> isSelected = [true, false];
  String selectedLanguage = 'fr';
  String selectedFormat = 'FR';
  bool isLoading = false;

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.userNotConnected), backgroundColor: AppColors.error),
      );
      setState(() => isLoading = false);
      return;
    }

    final now = context.read<Clock>().now();
    final timezone = now.timeZoneName;

    try {
      await supabase.from('usersdata').upsert({
        'id': user.id,
        'user_name': userNameController.text.trim(),
        'points': 100,
        'daily_points_used': false,
        'timezone': timezone,
        'oddsformat': selectedFormat,
        'language': selectedLanguage,
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigation(uid: user.id, showTutorial: true)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => isLoading = false);
    }
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
              Text(
                t.firstConnection,
                style: TextStyle(color: AppColors.textPrimary, fontSize: kToolbarHeight * 0.38, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _sectionHeader(Icons.person_outlined, t.userName),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.badge_outlined, color: AppColors.primaryBlue, size: 18),
                          const SizedBox(width: 8),
                          Text(t.userName, style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 13), fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: userNameController,
                        maxLength: 20,
                        inputFormatters: [NoSpecialCharactersFormatter()],
                        style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 16)),
                        decoration: InputDecoration(
                          hintText: t.userName,
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
                        label: 'Langue',
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHover,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ToggleButtons(
                            borderRadius: BorderRadius.circular(8),
                            selectedColor: Colors.white,
                            fillColor: AppColors.primaryBlue,
                            color: AppColors.textSecondary,
                            borderColor: AppColors.borderDark,
                            selectedBorderColor: AppColors.primaryBlue,
                            isSelected: isSelected,
                            onPressed: (index) {
                              setState(() {
                                for (int i = 0; i < isSelected.length; i++) {
                                  isSelected[i] = i == index;
                                }
                                selectedLanguage = index == 0 ? 'fr' : 'en';
                              });
                            },
                            children: const [
                              Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('FR')),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('EN')),
                            ],
                          ),
                        ),
                      ),
                      Divider(color: AppColors.borderDark, height: 32),
                      _buildPreferenceRow(
                        icon: Icons.show_chart_outlined,
                        label: t.oddsFormat,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedFormat,
                          items: ['FR', 'US', 'UK']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: AppColors.textPrimary))))
                              .toList(),
                          onChanged: (v) => setState(() => selectedFormat = v!),
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

                // Disclaimer
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.tagBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.oddsDisclaimer,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 12), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

                // Odds Format Info
                _buildCard(
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      iconColor: AppColors.primaryBlue,
                      collapsedIconColor: AppColors.textSecondary,
                      title: Text(
                        t.formatsDesCotes,
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: logScale(context, 16)),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(t.formatsDesCotesDescription, style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Save Button
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : saveUserData,
                    icon: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_outlined, color: Colors.white, size: 20),
                    label: Text(t.save, style: TextStyle(fontSize: logScale(context, 16), color: Colors.white, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
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
}
