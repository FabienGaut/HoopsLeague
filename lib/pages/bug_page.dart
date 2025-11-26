import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/utils.dart';
import '../theme/app_colors.dart';

final supabase = Supabase.instance.client;

class BugPage extends StatefulWidget {
  final dynamic uid;

  const BugPage({super.key, required this.uid});

  @override
  State<BugPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugPage> {
  final TextEditingController _descController = TextEditingController();
  bool _loading = false;
  String? errorMessage;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitBug() async {
    final desc = _descController.text.trim();
    if (desc.isEmpty) {
      setState(() => errorMessage = "La description ne peut pas être vide.");
      return;
    }

    setState(() {
      _loading = true;
      errorMessage = null;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      final user = supabase.auth.currentUser;

      await supabase.from('bugs').insert({
        'user_id': user?.id,
        'description': desc,
        'title': 'Bug Report',
      });

      _descController.clear();

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text("Bug envoyé, merci !"),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    } catch (e) {
      setState(() => errorMessage = "Erreur : $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: kToolbarHeight * 0.6,
              ),
              SizedBox(width: kToolbarHeight * 0.2),
              Text(
                AppLocalizations.of(context)!.reportBug,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: kToolbarHeight * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background gradient - même style que games_page
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.backgroundDark,
                  AppColors.surfaceDark.withValues(alpha: 0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Container principal avec style glassmorphism
                    Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surfaceDark,
                            AppColors.surfaceDark.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // En-tête avec icône
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.black.withValues(alpha: 0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bug_report,
                                  color: AppColors.primaryBlue,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.describeBug,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: logScale(context, 18),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Champ de texte
                          TextField(
                            controller: _descController,
                            maxLength: 200,
                            maxLines: 7,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: logScale(context, 14),
                            ),
                            decoration: InputDecoration(
                              hintText: "Décrivez le bug rencontré...",
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: logScale(context, 14),
                              ),
                              filled: true,
                              fillColor: Colors.black.withValues(alpha: 0.3),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppColors.primaryBlue,
                                  width: 2,
                                ),
                              ),
                              counterStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: logScale(context, 12),
                              ),
                            ),
                          ),
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          // Bouton d'envoi - style games_page
                          _loading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryBlue,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryBlue,
                                        AppColors.primaryBlue.withValues(alpha: 0.8),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryBlue.withValues(alpha: 0.5),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: _submitBug,
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(context)!.send,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: logScale(context, 16),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Footer
                    Text(
                      AppLocalizations.of(context)!.allRightsReserved,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: logScale(context, 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
