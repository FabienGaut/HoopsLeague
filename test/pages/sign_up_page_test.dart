import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/sign_up_page.dart';
import 'package:hoopsleague/l10n/app_localizations.dart';

void main() {
  Widget createTestApp(Widget child) {
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
      home: child,
    );
  }

  group('SignUpPage Widget Tests', () {
    testWidgets('should display email, password and confirm password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence des 3 champs de texte
      expect(find.byType(TextField), findsNWidgets(3));

      // Vérifier les labels
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should display sign up button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Chercher le bouton d'inscription
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('should display link to sign in page',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence du lien vers la connexion
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('should have password fields obscured by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Trouver les champs de texte
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(3));

      // Les 2e et 3e TextField devraient être obscurés (password et confirm)
      final allTextFields = tester.widgetList<TextField>(textFields).toList();
      expect(allTextFields[1].obscureText, true); // Password
      expect(allTextFields[2].obscureText, true); // Confirm password
    });

    testWidgets('email field should accept text input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Trouver le champ email et entrer du texte
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'newuser@example.com');
      await tester.pump();

      expect(find.text('newuser@example.com'), findsOneWidget);
    });

    testWidgets('password fields should accept text input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Entrer le mot de passe
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Vérifier que le contrôleur contient la valeur
      final textField = tester.widget<TextField>(passwordField);
      expect(textField.controller?.text, 'password123');
    });

    testWidgets('should display logo', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'une image (logo)
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should have proper layout structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);

      // Vérifier la présence de SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsWidgets);

      // Vérifier la présence d'un Form pour la validation
      expect(find.byType(Form), findsOneWidget);
    });
  });
}

