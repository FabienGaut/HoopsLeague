import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/first_connection_page.dart';
import '../pages/password_reset_page.dart';
import '../pages/main_navigation.dart';
import '../theme/app_colors.dart';

class AuthRedirectPage extends StatefulWidget {
  final String? initialFragment;

  const AuthRedirectPage({super.key, this.initialFragment});

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
    bool hasRedirected = false;

    try {
      final uri = Uri.base;
      final fragment = widget.initialFragment ?? uri.fragment;

      debugPrint('=== AUTH REDIRECT DEBUG ===');
      debugPrint('Full URI: $uri');
      debugPrint('Initial Fragment: ${widget.initialFragment}');
      debugPrint('URI Fragment: ${uri.fragment}');
      debugPrint('Using Fragment: $fragment');
      debugPrint('Query params: ${uri.queryParameters}');

      final fragmentContainsReset = fragment.contains('reset');
      final fragmentContainsRecovery = fragment.contains('type=recovery');
      final queryContainsRecovery = uri.queryParameters['type'] == 'recovery';

      final isPasswordResetUrl = fragmentContainsReset ||
                                  fragmentContainsRecovery ||
                                  queryContainsRecovery;

      debugPrint('Fragment contains reset: $fragmentContainsReset');
      debugPrint('Fragment contains type=recovery: $fragmentContainsRecovery');
      debugPrint('Query type=recovery: $queryContainsRecovery');
      debugPrint('Is password reset URL: $isPasswordResetUrl');

      final subscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (!mounted || hasRedirected) return;

        debugPrint('Auth Event: ${data.event}');

        if (data.event == AuthChangeEvent.passwordRecovery) {
          hasRedirected = true;
          debugPrint('passwordRecovery event - redirecting to PasswordResetPage');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PasswordResetPage()),
          );
        }
      });

      if (uri.queryParameters.containsKey('code')) {
        debugPrint('Processing PKCE code...');
        try {
          await Supabase.instance.client.auth.getSessionFromUrl(uri);
        } catch (e) {
          debugPrint('Error processing PKCE code (will continue): $e');
        }
      } else if (fragment.isNotEmpty) {
        debugPrint('Processing fragment...');
        try {
          await Supabase.instance.client.auth.getSessionFromUrl(uri);
        } catch (e) {
          debugPrint('Error processing fragment (will continue): $e');
        }
      }

      await Future.delayed(const Duration(milliseconds: 1000));

      await subscription.cancel();

      if (!mounted || hasRedirected) return;

      hasRedirected = true;
      if (isPasswordResetUrl) {
        debugPrint('Password reset URL detected - redirecting to PasswordResetPage');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PasswordResetPage()),
        );
      } else {
        final user = Supabase.instance.client.auth.currentUser;
        debugPrint('Current user: ${user?.id}');

        if (user != null) {
          try {
            final userData = await Supabase.instance.client
                .from('usersdata')
                .select('user_name')
                .eq('id', user.id)
                .maybeSingle();

            debugPrint('User data: $userData');

            if (!mounted) return;

            if (userData != null && userData['user_name'] != null && userData['user_name'].toString().isNotEmpty) {
              debugPrint('User has profile - redirecting to MainNavigation');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => MainNavigation(uid: user.id)),
              );
            } else {
              debugPrint('New user - redirecting to FirstConnectionPage');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const FirstConnectionPage()),
              );
            }
          } catch (e) {
            debugPrint('Error checking user data: $e');
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const FirstConnectionPage()),
            );
          }
        } else {
          debugPrint('No user session - redirecting to FirstConnectionPage');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const FirstConnectionPage()),
          );
        }
      }

    } catch (e) {
      debugPrint('Error in auth redirect: $e');
      if (!mounted) return;

      final uri = Uri.base;
      final fragment = widget.initialFragment ?? uri.fragment;

      final isPasswordReset = fragment.contains('reset') ||
                              fragment.contains('type=recovery') ||
                              uri.queryParameters['type'] == 'recovery';

      debugPrint('Fragment in catch: $fragment');
      debugPrint('Is password reset in catch: $isPasswordReset');

      if (isPasswordReset) {
        debugPrint('Error during password reset - redirecting to PasswordResetPage');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PasswordResetPage()),
        );
      } else {
        debugPrint('Error during email confirmation - redirecting to FirstConnectionPage');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FirstConnectionPage()),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );
  }
}
