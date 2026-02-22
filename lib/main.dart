import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hoopsleague/pages/first_connection_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/main_navigation.dart';
import 'pages/games_preview_page.dart';
import 'pages/auth_redirect_page.dart';
import 'l10n/app_localizations.dart';
import 'pages/app_state.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter/foundation.dart';
import 'services/clock.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'widgets/loading_screen.dart';

Future<void> main() async {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode || kIsWeb) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await Hive.initFlutter();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('PUBLISHABLE_KEY');

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw Exception("Supabase URL ou PUBLISHABLE_KEY manquante (--dart-define)");
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  final clock = Clock();

  String? uid;
  final hasFragment = kIsWeb && (Uri.base.fragment.isNotEmpty || Uri.base.queryParameters.containsKey('code'));

  if (!hasFragment) {
    uid = Supabase.instance.client.auth.currentSession?.user.id;
    if (uid != null) {
      await appState.loadUserData(uid);
      final lang = appState.userData?['language'] ?? 'fr';
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
    if (kIsWeb && (Uri.base.fragment.isNotEmpty || Uri.base.queryParameters.containsKey('code'))) {
      return AuthRedirectPage(initialFragment: Uri.base.fragment);
    }

    if (uid == null) {
      return const GamesPreviewPage();
    }

    try {
      final userData = await Supabase.instance.client
          .from('usersdata')
          .select('user_name')
          .eq('id', uid as Object)
          .maybeSingle();

      if (userData != null && userData['user_name'] != null && userData['user_name'].isNotEmpty) {
        return MainNavigation(uid: uid!);
      } else {
        return FirstConnectionPage();
      }
    } catch (e) {
      return const GamesPreviewPage();
    }
  }
 @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, AppState state, _) => MaterialApp(
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
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
          },
          scrollbars: false,
          physics: const BouncingScrollPhysics(),
        ),
        showPerformanceOverlay: false,
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
              return const LoadingScreen();
            }
            return snapshot.data!;
          },
        ),
      ),
    );
  }
}