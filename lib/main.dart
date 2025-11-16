import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/games_page.dart';
import 'pages/home_page.dart';
import 'l10n/app_localizations.dart';
import 'pages/app_state.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:responsive_framework/responsive_framework.dart';

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

  final session = Supabase.instance.client.auth.currentSession;
  String? uid = session?.user.id;

  if (uid != null) {
    final userData = await Supabase.instance.client
        .from('usersdata')
        .select('language')
        .eq('id', uid)
        .single();

    final lang = userData['language'] ?? 'fr';
    appState.setLocale(lang);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        Provider<Clock>(create: (_) => Clock()),
      ],
      child: MyApp(initialSession: session, uid: uid),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Session? initialSession;
  final String? uid;

  const MyApp({super.key, required this.initialSession, this.uid});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

        // 🔹 ResponsiveFramework juste pour breakpoints
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: const [
            Breakpoint(start: 0, end: 450, name: MOBILE),
            Breakpoint(start: 451, end: 800, name: TABLET),
            Breakpoint(start: 801, end: 1920, name: DESKTOP),
            Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),

        home: widget.uid != null
            ? GamesPage(uid: widget.uid!)
            : const HomePage(),
      ),
    );
  }
}
