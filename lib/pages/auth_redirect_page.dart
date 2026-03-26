import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/first_connection_page.dart';
import '../pages/password_reset_page.dart';
import '../pages/sign_in_page.dart';
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
    final uri = Uri.base;
    final fragment = widget.initialFragment ?? uri.fragment;

    // Check for error in URL params (e.g. expired or invalid token)
    final error = uri.queryParameters['error'] ??
        uri.queryParameters['error_description'];
    if (error != null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SignInPage(emailConfirmed: true),
        ),
      );
      return;
    }

    final completer = Completer<AuthChangeEvent>();
    StreamSubscription<AuthState>? subscription;

    subscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!completer.isCompleted) {
        completer.complete(data.event);
      }
      subscription?.cancel();
    });

    bool sessionError = false;
    try {
      if (uri.queryParameters.containsKey('code') || fragment.isNotEmpty) {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      }
    } catch (e) {
      debugPrint('Error processing session from URL: $e');
      sessionError = true;
    }

    AuthChangeEvent? event;
    try {
      event = await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      debugPrint('Auth event timeout');
    } finally {
      await subscription.cancel();
    }

    if (!mounted) return;

    if (event == AuthChangeEvent.passwordRecovery) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PasswordResetPage()),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final userData = await Supabase.instance.client
            .from('usersdata')
            .select('user_name')
            .eq('id', user.id)
            .maybeSingle();

        if (!mounted) return;

        if (userData != null && userData['user_name'] != null && userData['user_name'].toString().isNotEmpty) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainNavigation(uid: user.id)),
          );
        } else {
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
      // No session — likely opened on a different device.
      // Email was confirmed server-side, redirect to sign-in.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SignInPage(emailConfirmed: sessionError),
        ),
      );
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
