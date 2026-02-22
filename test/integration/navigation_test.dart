import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/sign_in_page.dart';
import 'package:hoopsleague/pages/sign_up_page.dart';
import 'package:hoopsleague/l10n/app_localizations.dart';
import '../helpers/supabase_test_helper.dart';

void main() {
  setUpAll(() async {
    await initializeSupabaseForTest();
  });

  Widget createTestApp(Widget home) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
      home: home,
    );
  }

  group('Navigation Integration Tests', () {
    testWidgets('should navigate from SignIn to SignUp page',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Trouver le bouton/lien vers l'inscription
      // Le texte est dans un TextSpan, donc on utilise textContaining
      final signUpText = find.textContaining('Créer un compte');
      expect(signUpText, findsOneWidget);

      // Faire défiler jusqu'au bouton (il peut être en dehors de l'écran)
      await tester.ensureVisible(signUpText);
      await tester.pumpAndSettle();

      // Taper sur le texte pour naviguer
      await tester.tap(signUpText);
      await tester.pumpAndSettle();

      // Vérifier qu'on est sur la page SignUp
      expect(find.byType(SignUpPage), findsOneWidget);
    });

    testWidgets('should display correct widgets on SignIn page',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la structure de la page
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byIcon(Icons.login_outlined), findsOneWidget);
    });

    testWidgets('should display correct widgets on SignUp page',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la structure de la page
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
    });
  });
}
