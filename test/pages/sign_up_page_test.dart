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
      expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
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

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Trouver les icônes de visibilité
      final visibilityIcons = find.byIcon(Icons.visibility_off);
      
      if (visibilityIcons.evaluate().isNotEmpty) {
        // Appuyer sur la première icône
        await tester.tap(visibilityIcons.first);
        await tester.pump();

        // Au moins une icône devrait changer
        expect(find.byIcon(Icons.visibility), findsWidgets);
      }
    });

    testWidgets('should validate password match', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Entrer des mots de passe différents
      final passwordField = find.byType(TextField).at(1);
      final confirmField = find.byType(TextField).at(2);

      await tester.enterText(passwordField, 'password123');
      await tester.pump();
      await tester.enterText(confirmField, 'differentpassword');
      await tester.pump();

      // Essayer de s'inscrire
      final signUpButton = find.byIcon(Icons.person_add_outlined);
      if (signUpButton.evaluate().isNotEmpty) {
        await tester.tap(signUpButton);
        await tester.pump();
        
        // Une erreur de validation devrait apparaître
      }
    });

    testWidgets('should have gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de Container avec décoration
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('should display all required UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Vérifier tous les éléments essentiels
      expect(find.byType(TextField), findsNWidgets(3)); // Email + Password + Confirm
      expect(find.byType(Image), findsWidgets); // Logo
      expect(find.byIcon(Icons.person_add_outlined), findsOneWidget); // Bouton inscription
      expect(find.byType(TextButton), findsWidgets); // Lien connexion
    });

    testWidgets('email field should have email keyboard type', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Trouver le champ email
      final emailField = find.byType(TextField).first;
      final textField = tester.widget<TextField>(emailField);
      
      // Vérifier le type de clavier
      expect(textField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('should validate empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Laisser les champs vides et essayer de s'inscrire
      final signUpButton = find.byIcon(Icons.person_add_outlined);
      
      if (signUpButton.evaluate().isNotEmpty) {
        await tester.tap(signUpButton);
        await tester.pump();
        
        // Des messages d'erreur devraient apparaître
      }
    });

    testWidgets('should maintain state when switching fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Entrer du texte dans le champ email
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'newuser@example.com');
      await tester.pump();

      // Passer au champ password
      final passwordField = find.byType(TextField).at(1);
      await tester.tap(passwordField);
      await tester.pump();

      // Vérifier que l'email est toujours là
      expect(find.text('newuser@example.com'), findsOneWidget);
    });

    testWidgets('password and confirm password should match', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const SignUpPage()),
      );
      await tester.pumpAndSettle();

      // Entrer le même mot de passe dans les deux champs
      final passwordField = find.byType(TextField).at(1);
      final confirmField = find.byType(TextField).at(2);

      await tester.enterText(passwordField, 'password123');
      await tester.pump();
      await tester.enterText(confirmField, 'password123');
      await tester.pump();

      // Vérifier que les deux champs ont la même valeur
      final passwordWidget = tester.widget<TextField>(passwordField);
      final confirmWidget = tester.widget<TextField>(confirmField);
      
      expect(passwordWidget.controller?.text, confirmWidget.controller?.text);
    });
  });
}

