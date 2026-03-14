import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/utils.dart';
import '../theme/app_colors.dart';
import '../utils/no_special_characters_formatter.dart';

final supabase = Supabase.instance.client;

class BugPage extends StatefulWidget {
  final dynamic uid;
  final VoidCallback? onClose;

  const BugPage({super.key, required this.uid, this.onClose});

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
          SnackBar(content: const Text("Bug envoyé, merci !"), backgroundColor: AppColors.success),
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
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textSecondary),
          onPressed: () {
            if (widget.onClose != null) {
              widget.onClose!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Image.asset(AppColors.logoAsset, height: kToolbarHeight * 0.5),
              SizedBox(width: kToolbarHeight * 0.15),
              Text(
                AppLocalizations.of(context)!.reportBug,
                style: TextStyle(color: AppColors.textPrimary, fontSize: kToolbarHeight * 0.38, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark, width: 1),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHover,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.tagRed, borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.bug_report_outlined, color: AppColors.error, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.describeBug,
                                style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 16), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _descController,
                        maxLength: 200,
                        maxLines: 7,
                        inputFormatters: [NoSpecialCharactersFormatter()],
                        style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 14)),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.describeBug,
                          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 14)),
                          filled: true,
                          fillColor: AppColors.surfaceHover,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.borderDark, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primaryBlue, width: 1),
                          ),
                          counterStyle: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 12)),
                        ),
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.tagRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(errorMessage!, style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      _loading
                          ? Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _submitBug,
                                icon: const Icon(Icons.send_outlined, color: Colors.white, size: 20),
                                label: Text(
                                  AppLocalizations.of(context)!.send,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: logScale(context, 16)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.allRightsReserved,
                  style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
