import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/games_page.dart';
import '../pages/first_connection_page.dart';

class AuthRedirectPage extends StatefulWidget {
  const AuthRedirectPage({super.key});

  @override
  State<AuthRedirectPage> createState() => _AuthRedirectPageState();
}

class _AuthRedirectPageState extends State<AuthRedirectPage> {
  @override
  void initState() {
    super.initState();
    _handleRedirect();
  }

  Future<void> _handleRedirect() async {
    try {
      // Récupérer la session depuis l'URL
      final res = await Supabase.instance.client.auth.getSessionFromUrl(Uri.base);
      final user = res.session.user;

      if (mounted) {
        final uid = user.id;
        final navigator = Navigator.of(context);

        // Vérifier si l'utilisateur a un username dans la base de données
        final userData = await Supabase.instance.client
            .from('usersdata')
            .select('user_name')
            .eq('id', uid)
            .maybeSingle();

        final userName = userData?['user_name'];
        final hasUsername = userName != null && 
                           userName is String && 
                           userName.trim().isNotEmpty;

        // Redirection selon la présence d'un username
        if (!mounted) return;
        if (hasUsername) {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => GamesPage(uid: uid)),
          );
        } else {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const FirstConnectionPage()),
          );
        }
      }
    } catch (e) {
      // En cas d'erreur, rediriger vers FirstConnectionPage par sécurité
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FirstConnectionPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
