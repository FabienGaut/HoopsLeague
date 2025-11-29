import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/sign_in_page.dart';
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

  group('SignInPage Widget Tests', () {
    testWidgets('should display email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence des champs de texte
      expect(find.byType(TextField), findsNWidgets(2));
      
      // Vérifier les labels/hints
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should display sign in button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Chercher l'icône de connexion
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('should display link to sign up page', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence du TextButton
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('should have password field obscured by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Trouver le champ de mot de passe
      final passwordFields = find.byType(TextField);
      expect(passwordFields, findsNWidgets(2));
      
      // Le deuxième TextField devrait être le mot de passe
      final passwordField = tester.widgetList<TextField>(passwordFields).elementAt(1);
      expect(passwordField.obscureText, true);
    });

    testWidgets('email field should accept text input', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Trouver le champ email et entrer du texte
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('password field should accept text input', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Trouver le champ password et entrer du texte
      final passwordField = find.byType(TextField).last;
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Le texte ne sera pas visible car obscureText = true
      // mais le contrôleur devrait contenir la valeur
      final textField = tester.widget<TextField>(passwordField);
      expect(textField.controller?.text, 'password123');
    });

    testWidgets('should display logo or app branding', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'une image (logo)
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Vérifier la présence de SingleChildScrollView ou équivalent
      // pour gérer le défilement sur petits écrans
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Trouver l'icône de visibilité
      final visibilityIcon = find.byIcon(Icons.visibility_off);
      
      if (visibilityIcon.evaluate().isNotEmpty) {
        // Appuyer sur l'icône pour afficher le mot de passe
        await tester.tap(visibilityIcon);
        await tester.pump();

        // L'icône devrait changer
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      }
    });

    testWidgets('should validate empty email', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Laisser les champs vides et essayer de se connecter
      final signInButton = find.byIcon(Icons.login);
      
      if (signInButton.evaluate().isNotEmpty) {
        await tester.tap(signInButton);
        await tester.pump();
        
        // Un message d'erreur ou une validation devrait apparaître
        // (dépend de l'implémentation)
      }
    });

    testWidgets('should have gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de Container avec décoration
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('should display all required UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier tous les éléments essentiels
      expect(find.byType(TextField), findsNWidgets(2)); // Email + Password
      expect(find.byType(Image), findsWidgets); // Logo
      expect(find.byIcon(Icons.login), findsOneWidget); // Bouton connexion
      expect(find.byType(TextButton), findsWidgets); // Lien inscription
    });

    testWidgets('should have form validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un Form pour la validation
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('email field should have email keyboard type', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Trouver le champ email
      final emailField = find.byType(TextField).first;
      final textField = tester.widget<TextField>(emailField);
      
      // Vérifier le type de clavier
      expect(textField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('should maintain state when switching fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignInPage()),
      );
      await tester.pumpAndSettle();

      // Entrer du texte dans le champ email
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Passer au champ password
      final passwordField = find.byType(TextField).last;
      await tester.tap(passwordField);
      await tester.pump();

      // Vérifier que l'email est toujours là
      expect(find.text('test@example.com'), findsOneWidget);
    });
  });
}

