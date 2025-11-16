import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/utils.dart';

final supabase = Supabase.instance.client;

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});


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
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    final user = supabase.auth.currentUser;
    if (user == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.userNotConnected)),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: user.email!,
        password: oldPasswordController.text.trim(),
      );

      if (authResponse.user == null) {
        throw t.wrongOldPassword;
      }

      if (newPasswordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        throw t.passwordsDoNotMatch;
      }

      await supabase.auth.updateUser(
        UserAttributes(password: newPasswordController.text.trim()),
      );

      messenger.showSnackBar(
        SnackBar(content: Text(t.passwordUpdated)),
      );

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      messenger.showSnackBar(
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

  Widget _buildGlassButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required double fontSize,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: fontSize * 1.2),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double fieldWidth = ((screenWidth * 0.75).clamp(220, 360)).toDouble();
    final double buttonWidth = ((screenWidth * 0.7).clamp(160, 300)).toDouble();
    final double buttonHeight = ((screenHeight * 0.07).clamp(45, 60)).toDouble();
    final double fontSize = ((screenWidth * 0.045).clamp(14, 18)).toDouble();
    final double spacing = ((screenHeight * 0.03).clamp(10, 25)).toDouble();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 8),
            Text(
              t.hoopsLeagueTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Fond dégradé violet → noir
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

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  const Icon(Icons.lock_reset, color: Colors.white, size: 80),
                  SizedBox(height: spacing),

                  Text(
                    t.changePasswordTitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: logScale(context, 24),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),

                  SizedBox(height: spacing * 1.5),

                  // Bloc semi-transparent
                  Container(
                    width: fieldWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: oldPasswordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: t.oldPasswordLabel,
                              labelStyle:
                              TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            validator: (v) =>
                            (v == null || v.isEmpty) ? t.oldPasswordEmpty : null,
                          ),
                          SizedBox(height: spacing),
                          TextFormField(
                            controller: newPasswordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: t.newPasswordLabel,
                              labelStyle:
                              TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                              prefixIcon:
                              const Icon(Icons.lock, color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            validator: (v) =>
                            (v == null || v.length < 6) ? t.passwordTooShort : null,
                          ),
                          SizedBox(height: spacing),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: t.confirmPasswordLabel,
                              labelStyle:
                              TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                              prefixIcon:
                              const Icon(Icons.lock, color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            validator: (v) =>
                            (v == null || v.length < 6) ? t.passwordTooShort : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: spacing * 1.5),

                  _buildGlassButton(
                    label: t.save,
                    icon: Icons.save,
                    onPressed: isLoading ? () {} : changePassword,
                    fontSize: fontSize,
                    width: buttonWidth,
                    height: buttonHeight,
                  ),

                  SizedBox(height: spacing * 2),

                  Text(
                    "© 2025 HoopsLeague",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: logScale(context, 12),
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
