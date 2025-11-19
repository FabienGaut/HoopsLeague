import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/sign_in_page.dart';
import 'package:hoopsleague/pages/sign_up_page.dart';
import 'package:hoopsleague/l10n/app_localizations.dart';

void main() {
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
      final signUpButton = find.byType(TextButton);
      expect(signUpButton, findsWidgets);

      // Taper sur le premier TextButton (lien vers inscription)
      await tester.tap(signUpButton.first);
      await tester.pumpAndSettle();

      // Vérifier qu'on est sur la page SignUp
      expect(find.byType(SignUpPage), findsOneWidget);
    });

    testWidgets('should navigate from SignUp to SignIn page',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Trouver le bouton/lien vers la connexion
      final signInButton = find.byType(TextButton);
      expect(signInButton, findsWidgets);

      // Taper sur le bouton
      await tester.tap(signInButton.first);
      await tester.pumpAndSettle();

      // Vérifier qu'on est sur la page SignIn
      expect(find.byType(SignInPage), findsOneWidget);
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
      expect(find.byIcon(Icons.login), findsOneWidget);
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
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('should handle multiple navigation cycles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Cycle 1: SignIn → SignUp
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      expect(find.byType(SignUpPage), findsOneWidget);

      // Cycle 2: SignUp → SignIn
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      expect(find.byType(SignInPage), findsOneWidget);

      // Cycle 3: SignIn → SignUp again
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      expect(find.byType(SignUpPage), findsOneWidget);
    });
  });
}

