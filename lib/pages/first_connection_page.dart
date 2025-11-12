import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import 'games_page.dart';

final supabase = Supabase.instance.client;

class FirstConnectionPage extends StatefulWidget {
  @override
  _FirstConnectionPageState createState() => _FirstConnectionPageState();
}

class _FirstConnectionPageState extends State<FirstConnectionPage> {
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
      appBar: AppBar(
          title: Text(
          AppLocalizations.of(context)!.firstConnection
      )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: userNameController,
                decoration:  InputDecoration(
                  labelText: AppLocalizations.of(context)!.userName,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return AppLocalizations.of(context)!.enterUserName;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Text('Langue', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: Colors.blueAccent,
                color: Colors.black,
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

              DropdownButtonFormField<String>(
                initialValue: selectedFormat,
                decoration:  InputDecoration(
                  labelText: AppLocalizations.of(context)!.oddsFormat,
                  border: OutlineInputBorder(),
                ),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(AppLocalizations.of(context)!.save, style: TextStyle(fontSize: 18)),
                ),

              ),
              const SizedBox(height: 24),
              ExpansionTile(
                title: Text(
                  AppLocalizations.of(context)!.infosCotesCgu,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.formatsDesCotes,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(AppLocalizations.of(context)!.formatsDesCotesDescription),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.cgu,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(AppLocalizations.of(context)!.cguDescription),
                      ],
                    ),
                  ),
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }
}
