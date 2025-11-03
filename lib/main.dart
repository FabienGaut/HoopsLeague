import 'dart:io' show Platform, File, Directory;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/games_page.dart';
import 'pages/home_page.dart';
import 'l10n/app_localizations.dart';
import 'pages/app_state.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

late tz.Location localLocation;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  String localTz = 'UTC'; // valeur par défaut
  await Hive.initFlutter();
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows)) {
    try {
      localTz = await FlutterNativeTimezone.getLocalTimezone();
    } catch (_) {}
  } else if (Platform.isLinux || kIsWeb) {
    localTz = 'Europe/Paris'; // ou détecte via user param
  }
  localLocation = tz.getLocation(localTz);

  final envPath = File('${Directory.current.path}/.env').path;
  await dotenv.load(fileName: envPath);

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception("Supabase URL ou ANON KEY manquante dans le .env");
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  final session = Supabase.instance.client.auth.currentSession;
  String? uid = session?.user.id;

  // Récupérer la langue depuis Supabase si utilisateur connecté
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
    ChangeNotifierProvider<AppState>.value(
      value: appState,
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
        home: widget.uid != null
            ? GamesPage(uid: widget.uid!)
            : const HomePage(),
      ),
    );
  }
}
