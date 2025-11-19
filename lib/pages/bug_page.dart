import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../l10n/app_localizations.dart';
import '../theme/utils.dart';

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

    try {
      final user = supabase.auth.currentUser;

      await supabase.from('bugs').insert({
        'user_id': user?.id,
        'description': desc,
        'title': 'Bug Report',
      });

      _descController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bug envoyé, merci !")),
      );
    } catch (e) {
      setState(() => errorMessage = "Erreur : $e");
    } finally {
      setState(() => _loading = false);
    }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double fieldWidth = ((screenWidth * 0.75).clamp(200, 340)).toDouble();
    final double buttonWidth = ((screenWidth * 0.7).clamp(160, 300)).toDouble();
    final double buttonHeight = ((screenHeight * 0.07).clamp(45, 60)).toDouble();
    final double fontSize = ((screenWidth * 0.045).clamp(14, 18)).toDouble();
    final double spacing = ((screenHeight * 0.03).clamp(10, 25)).toDouble();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(

        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown, // rétrécit si nécessaire
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: kToolbarHeight * 0.6, // proportion de l’AppBar
              ),
              SizedBox(width: kToolbarHeight * 0.2),
              Text(
                AppLocalizations.of(context)!.reportBug,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: kToolbarHeight * 0.4, // proportion de l’AppBar
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
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
              child: Column(
                children: [
                  SizedBox(height: spacing * 2),
                  Container(
                    width: fieldWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _descController,
                          maxLines: 6,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.describeBug,
                            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(height: spacing),
                        _loading
                            ? const CircularProgressIndicator()
                            : _buildGlassButton(
                          label: AppLocalizations.of(context)!.send,
                          icon: Icons.send,
                          fontSize: fontSize,
                          width: buttonWidth,
                          height: buttonHeight,
                          onPressed: _submitBug,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  Text(
                    "© 2025 HoopsLeague. All rights reserved.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: logScale(context, 12),
                    ),
                  ),
                  SizedBox(height: spacing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
