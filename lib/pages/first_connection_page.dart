import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import 'games_page.dart';
import 'package:hoopsleague/theme/app_colors.dart';
import 'package:hoopsleague/theme/utils.dart';
import 'package:hoopsleague/theme/widgets_theme.dart';
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
  List<bool> isSelected = [true, false]; // [FR, EN]
  String selectedLanguage = 'fr';
  String selectedFormat = 'FR'; // par défaut
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
        SnackBar(content: Text(AppLocalizations.of(context)!.userNotConnected)),
      );
      setState(() => isLoading = false);
      return;
    }

    final now = DateTime.now();
    final timezone = now.timeZoneName;

    try {
      await supabase.from('usersdata').upsert({
        'id': user.id,
        'user_name': userNameController.text.trim(),
        'email': user.email,
        'points': 100,
        'daily_points_used': false,
        'status': 'active',
        'timezone': timezone,
        'oddsformat': selectedFormat,
        'created_at': now.toIso8601String(),
        'language' : selectedLanguage,
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GamesPage(uid: user.id)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          AppLocalizations.of(context)!.firstConnection,
          style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 18)),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              HoopsCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: userNameController,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.userName,
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: AppColors.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return AppLocalizations.of(context)!.enterUserName;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Langue
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Langue', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: logScale(context, 14))),
                    ),
                    const SizedBox(height: 8),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.white,
                      fillColor: AppColors.accentPrimary,
                      color: AppColors.textPrimary,
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('FR'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('EN'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedFormat,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.oddsFormat,
                        labelStyle: TextStyle(color: AppColors.textPrimary),
                        border: OutlineInputBorder(),
                      ),
                        style: TextStyle(color: AppColors.textPrimary),
                      items: ['FR', 'US', 'UK']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedFormat = v!),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : saveUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(AppLocalizations.of(context)!.save, style: TextStyle(fontSize: logScale(context, 18), color:  Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              HoopsCard(
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    AppLocalizations.of(context)!.infosCotesCgu,
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: logScale(context, 16)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.formatsDesCotes,
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(AppLocalizations.of(context)!.formatsDesCotesDescription, style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.cgu,
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(AppLocalizations.of(context)!.cguDescription, style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
