import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'pages/games_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/home_page.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final envPath = File('${Directory.current.path}/.env').path;
  await dotenv.load(fileName: envPath);

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception("Supabase URL ou ANON KEY manquante dans le .env");
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  final session = Supabase.instance.client.auth.currentSession;

  runApp(MyApp(initialSession: session));
}

class MyApp extends StatefulWidget {
  final Session? initialSession;

  const MyApp({super.key, required this.initialSession});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.initialSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
      locale: const Locale('fr'),
      home: session != null
          ? GamesPage(uid: session.user.id) // user déjà connecté
          : Scaffold(
        backgroundColor: Colors.white,

        body: HomePage(),
      ), // sinon page avec Sign in / Sign up
    );
  }
}
