import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hoopsleague/pages/first_connection_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/games_page.dart';
import 'pages/home_page.dart';
import 'pages/auth_redirect_page.dart'; // page que tu as créée
import 'l10n/app_localizations.dart';
import 'pages/app_state.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter/foundation.dart';
import 'services/clock.dart';

Future<void> main() async {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await dotenv.load(fileName: 'assets/.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception("Supabase URL ou ANON KEY manquante dans le .env");
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  final clock = Clock();

  // Détermination du user ID uniquement si pas sur web avec fragment
  String? uid;
  if (!(kIsWeb && Uri.base.fragment.isNotEmpty)) {
    uid = Supabase.instance.client.auth.currentSession?.user.id;
    if (uid != null) {
      final userData = await Supabase.instance.client
          .from('usersdata')
          .select('language')
          .eq('id', uid)
          .maybeSingle();
      final lang = userData?['language'] ?? 'fr';
      appState.setLocale(lang);
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        Provider<Clock>.value(value: clock),
      ],
      child: MyApp(uid: uid),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? uid;

  const MyApp({super.key, this.uid});


  Future<Widget> _determineHome() async {
    if (uid == null) return const HomePage(); // pas connecté

    try {
      final userData = await Supabase.instance.client
          .from('usersdata')
          .select('user_name')
          .eq('id', uid as Object)
          .maybeSingle();

      if (userData != null && userData['user_name'] != null && userData['user_name'].isNotEmpty) {
        return GamesPage(uid: uid!);
      } else {
        return FirstConnectionPage();
      }
    } catch (e) {
      debugPrint('Erreur récupération user_data: $e');
      return const HomePage();
    }
  }
 @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: state.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', ''),
          Locale('en', ''),
        ],
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: const [
            Breakpoint(start: 0, end: 450, name: MOBILE),
            Breakpoint(start: 451, end: 800, name: TABLET),
            Breakpoint(start: 801, end: 1920, name: DESKTOP),
            Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
        home: FutureBuilder<Widget>(
          future: _determineHome(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snapshot.data!;
          },
        ),
      ),
    );
  }
}